extends Node

func _ready() -> void:
	print("==================================================")
	print("🕒 TESTING PROFILE ACTIVITY STATUS & PRIVACY FIX")
	print("==================================================")
	
	# 1. Test UTC Time & Touch
	print("\n>>> 1. Testing touch_profile_activity and relative time formats...")
	GameData.set_language("es", false)
	GameData.touch_profile_activity()
	assert(not GameData.profile_last_activity_at.is_empty(), "Last activity at should not be empty")
	assert(GameData.profile_last_active_unix > 0, "Last active unix should be > 0")
	
	var rel_now = GameData.format_relative_activity_time(GameData.profile_last_activity_at)
	print("Relative time now (ES): ", rel_now)
	assert(rel_now == "Hace un momento", "Expected 'Hace un momento', got: %s" % rel_now)
	assert(GameData.is_trainer_active(GameData.profile_last_activity_at) == true, "Should be active now")
	
	# English test
	GameData.set_language("en", false)
	var rel_now_en = GameData.format_relative_activity_time(GameData.profile_last_activity_at)
	print("Relative time now (EN): ", rel_now_en)
	assert(rel_now_en == "Just now", "Expected 'Just now', got: %s" % rel_now_en)
	
	# 2. Test relative time intervals
	print("\n>>> 2. Testing past intervals...")
	var now_u = int(Time.get_unix_time_from_system())
	
	# 5 minutes ago (300s) -> Active
	var past_5m = now_u - 300
	GameData.set_language("es", false)
	assert(GameData.format_relative_activity_time(past_5m) == "Hace 5 min", "Expected 'Hace 5 min'")
	assert(GameData.is_trainer_active(past_5m) == true, "5m should be active")
	
	# 20 minutes ago (1200s) -> Inactive
	var past_20m = now_u - 1200
	assert(GameData.format_relative_activity_time(past_20m) == "Hace 20 min", "Expected 'Hace 20 min'")
	assert(GameData.is_trainer_active(past_20m) == false, "20m should be inactive")
	
	# 3 hours ago (10800s) -> Inactive
	var past_3h = now_u - 10800
	assert(GameData.format_relative_activity_time(past_3h) == "Hace 3 h", "Expected 'Hace 3 h'")
	assert(GameData.is_trainer_active(past_3h) == false, "3h should be inactive")
	
	# 1 day ago (86400s) -> Inactive
	var past_1d = now_u - 86400
	assert(GameData.format_relative_activity_time(past_1d) == "Hace 1 día", "Expected 'Hace 1 día'")
	assert(GameData.is_trainer_active(past_1d) == false, "1d should be inactive")
	
	# 4 days ago
	var past_4d = now_u - (86400 * 4)
	assert(GameData.format_relative_activity_time(past_4d) == "Hace 4 días", "Expected 'Hace 4 días'")
	
	# 3. Test Serialization & Deserialization
	print("\n>>> 3. Testing get_save_dict & apply_save_dict...")
	GameData.profile_last_activity_at = "2026-11-09T00:00:00"
	GameData.profile_last_active_unix = 1794182400
	var s_dict = GameData.get_save_dict()
	assert(s_dict["profile"]["last_activity_at"] == "2026-11-09T00:00:00", "Serialized last_activity_at match")
	assert(s_dict["profile"]["last_active_unix"] == 1794182400, "Serialized last_active_unix match")
	
	GameData.profile_last_activity_at = ""
	GameData.profile_last_active_unix = 0
	GameData.apply_save_dict(s_dict)
	assert(GameData.profile_last_activity_at == "2026-11-09T00:00:00", "Deserialized last_activity_at match")
	assert(GameData.profile_last_active_unix == 1794182400, "Deserialized last_active_unix match")
	
	# 4. Test UI Component Generation
	print("\n>>> 4. Testing Main Menu UI Components...")
	var menu_scene = load("res://scenes/main_menu.tscn").instantiate()
	add_child(menu_scene)
	
	# Test activity button creation
	var btn_active = menu_scene._create_activity_status_button(true)
	var btn_inactive = menu_scene._create_activity_status_button(false)
	print("Button active text: ", btn_active.text)
	print("Button inactive text: ", btn_inactive.text)
	assert(btn_active.text.contains("Activo") or btn_active.text.contains("Active"), "Should say Activo/Active")
	assert(btn_inactive.text.contains("Inactivo") or btn_inactive.text.contains("Inactive"), "Should say Inactivo/Inactive")
	
	# Test Profile Modal
	print("\n>>> 5. Testing Player Profile Modal...")
	GameData.profile_email = "secret_trainer@example.com"
	GameData.profile_auth_provider = "Google Cloud"
	menu_scene._on_profile_pressed()
	
	print("Trainer prompt text: ", menu_scene.trainer_email_prompt.text)
	print("Trainer value text: ", menu_scene.trainer_email_value.text)
	print("Account status text: ", menu_scene.account_status_lbl.text)
	
	assert(not menu_scene.trainer_email_value.text.contains("@"), "Email MUST NOT be exposed in trainer_email_value!")
	assert(not menu_scene.account_status_lbl.text.contains("@"), "Email MUST NOT be exposed in account_status_lbl!")
	assert(menu_scene.trainer_email_row.has_node("BtnTrainerStatus"), "BtnTrainerStatus must exist in TrainerEmailRow")
	var status_btn = menu_scene.trainer_email_row.get_node("BtnTrainerStatus") as Button
	assert(status_btn.text.contains("Activo") or status_btn.text.contains("Active"), "Player should be Active")
	
	# Test Friend Card
	print("\n>>> 6. Testing Friend Card...")
	var f_data = {
		"alias": "RedChampion",
		"email": "red@pallet.town",
		"id": "PKMN-999888",
		"last_activity_at": Time.get_datetime_string_from_system(true)
	}
	var f_card = menu_scene._create_friend_card(f_data)
	assert(f_card != null, "Friend card must be created")
	var card_text = ""
	for c in f_card.find_children("*", "Label", true, false):
		card_text += (c as Label).text + "\n"
	print("Friend Card Labels:\n", card_text)
	assert(not card_text.contains("red@pallet.town"), "Email MUST NOT be displayed on Friend Card!")
	assert(card_text.contains("PKMN-999888"), "ID should be displayed on Friend Card")
	assert(card_text.contains("🕒"), "Last activity clock should be displayed on Friend Card")
	
	# Test Search Result Card
	print("\n>>> 7. Testing Search Result Card...")
	var s_res = {
		"alias": "BlueRival",
		"email": "blue@pallet.town",
		"id": "PKMN-777666",
		"last_activity_at": Time.get_datetime_string_from_system(true),
		"is_self": false
	}
	var s_card = menu_scene._create_search_result_card(s_res)
	var s_card_text = ""
	for c in s_card.find_children("*", "Label", true, false):
		s_card_text += (c as Label).text + "\n"
	print("Search Result Card Labels:\n", s_card_text)
	assert(not s_card_text.contains("blue@pallet.town"), "Email MUST NOT be displayed on Search Result Card!")
	assert(s_card_text.contains("PKMN-777666"), "ID should be displayed on Search Result Card")
	
	# Test Friend Profile Modal
	print("\n>>> 8. Testing Friend Profile Modal...")
	menu_scene._show_friend_profile_modal_loading("BlueRival", "blue@pallet.town", "PKMN-777666")
	menu_scene._render_friend_profile_data({ "profile": { "trainer_alias": "BlueRival", "email": "blue@pallet.town", "id": "PKMN-777666" } }, s_res)
	var fp_text = ""
	for c in menu_scene.friend_profile_modal.find_children("*", "Label", true, false):
		fp_text += (c as Label).text + "\n"
	print("Friend Profile Modal Labels:\n", fp_text)
	assert(not fp_text.contains("blue@pallet.town"), "Email MUST NOT be displayed on Friend Profile Modal!")
	assert(fp_text.contains("PKMN-777666"), "ID should be displayed on Friend Profile Modal")
	assert(fp_text.contains("🕒"), "Last activity clock should be displayed on Friend Profile Modal")
	
	print("\n==================================================")
	print("🎉 ALL PROFILE ACTIVITY & PRIVACY TESTS PASSED!")
	print("==================================================")
	get_tree().quit(0)
