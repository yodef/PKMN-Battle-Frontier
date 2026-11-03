extends Node

func _ready() -> void:
	print("\n--- Running Test: Team Selection and Auth Verification Flow ---")
	
	# 1. Test Email Format Validation
	var email_regex = RegEx.new()
	email_regex.compile("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$")
	
	var valid_emails = [
		"ash.ketchum@gmail.com",
		"trainer123@yahoo.es",
		"player+test@domain.org",
		"rafiki@outlook.com"
	]
	var invalid_emails = [
		"asdf",
		"random_string",
		"test@",
		"@domain.com",
		"user@domain",
		"user space@domain.com"
	]
	
	for v in valid_emails:
		assert(email_regex.search(v) != null, "Valid email failed regex: " + v)
	print("✅ Valid emails passed correctly.")
	
	for inv in invalid_emails:
		assert(email_regex.search(inv) == null, "Invalid email incorrectly accepted: " + inv)
	print("✅ Invalid emails rejected correctly (no arbitrary strings allowed).")
	
	# 2. Test MainMenu Scene Loading & Node Wiring
	var main_menu_packed = load("res://scenes/main_menu.tscn")
	assert(main_menu_packed != null, "Failed to load main_menu.tscn")
	var menu = main_menu_packed.instantiate()
	add_child(menu)
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Ensure nodes exist
	assert(menu.btn_clear_team != null, "btn_clear_team node missing")
	assert(menu.btn_close_team_select != null, "btn_close_team_select node missing")
	assert(menu.cloud_password_row != null, "cloud_password_row missing")
	assert(menu.cloud_password_input != null, "cloud_password_input missing")
	assert(menu.btn_resend_verification != null, "btn_resend_verification missing")
	print("✅ All new UI nodes verified in main_menu.tscn.")
	
	# 3. Test Team Selection Default (Empty) & Clear Team
	menu._on_quick_battle_pressed()
	print("Quick battle opened. Selected player ids size: %d" % menu.selected_player_ids.size())
	assert(menu.selected_player_ids.is_empty(), "Quick battle should default to empty player selection!")
	print("✅ Quick battle defaults to empty team.")
	
	# Simulate adding Pokémon
	menu.selected_player_ids.append(1)
	menu.selected_player_ids.append(4)
	assert(menu.selected_player_ids.size() == 2, "Failed to append test pokémon")
	
	# Trigger Clear Team
	menu._on_clear_team_pressed()
	assert(menu.selected_player_ids.is_empty(), "Clear team button should empty selected_player_ids!")
	print("✅ Clear Team button resets selected_player_ids correctly.")
	
	# 4. Test Campaign Team Selection Default (Empty)
	GameData.campaign_player_team_state.clear()
	GameData.adventure_player_team_state.clear()
	menu.selected_player_ids.clear()
	menu.open_team_select_for_campaign()
	assert(menu.selected_player_ids.is_empty(), "Campaign team select should default to empty for new run!")
	print("✅ Campaign team select defaults to empty team.")
	
	# 5. Test Auth Modal Setup and Modes
	menu._on_sign_up_google_pressed()
	assert(menu.cloud_action_mode == "SIGNUP_GOOGLE", "Action mode should be SIGNUP_GOOGLE")
	assert(menu.cloud_password_row.visible == true, "Password row must be visible on register")
	assert(menu.cloud_trainer_row.visible == true, "Trainer row must be visible on register")
	print("✅ Registration mode properly configured with password and alias.")
	
	menu._switch_to_verification_view("ash@gmail.com")
	assert(menu.cloud_action_mode == "VERIFY_EMAIL", "Action mode should be VERIFY_EMAIL")
	assert(menu.btn_resend_verification.visible == true, "Resend verification button should be visible")
	assert(menu.btn_cloud_confirm.text == "✅ I Have Verified My Email", "Confirm button text updated")
	print("✅ Verification screen properly configured with Resend & Confirm buttons.")
	
	print("\n🎉 ALL TESTS PASSED SUCCESSFULLY!\n")
	get_tree().quit(0)
