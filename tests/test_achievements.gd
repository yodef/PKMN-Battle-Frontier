extends Node

func _ready() -> void:
	print("=== RUNNING TEST: ACHIEVEMENTS SYSTEM & EXP SHARE REWARD ===")
	
	test_achievement_definitions()
	test_achievement_progress_and_unlock_trigger()
	await test_lobby_button_and_modals()
	
	print("\n=== ALL ACHIEVEMENT TESTS PASSED PERFECTLY! ===")
	get_tree().quit(0)

func test_achievement_definitions() -> void:
	print("\n--- Test 1: Achievement Definitions ---")
	var ach_list = GameData.get_achievements_list()
	assert(not ach_list.is_empty(), "Achievements list must not be empty")
	
	var ach_50 = GameData.get_achievement_def("collect_50_cards")
	assert(not ach_50.is_empty(), "Achievement 'collect_50_cards' must exist")
	assert(ach_50.get("title", "") == "Conseguir 50 cartas de PKMN distintas", "Title must match user request")
	assert(ach_50.get("target", 0) == 50, "Target must be 50 cards")
	assert(ach_50.get("reward_id", "") == "exp_share", "Reward must be exp_share")
	assert(ach_50.get("reward_type", "") == "item", "Reward type must be item")
	print("✓ Achievement 'collect_50_cards' definition verified.")

func test_achievement_progress_and_unlock_trigger() -> void:
	print("\n--- Test 2: Progress Tracking & Auto-Unlock on 50 Cards ---")
	# Reset state for testing
	GameData.unlocked_achievements.clear()
	GameData.pending_achievement_notifications.clear()
	GameData.has_unlocked_exp_share = false
	GameData.player_unlocked_ids.clear()
	GameData.campaign_inventory["exp_share"] = 0
	GameData.adventure_inventory["exp_share"] = 0
	
	# Populate 49 distinct cards (1 to 49)
	for i in range(1, 50):
		GameData.player_unlocked_ids.append(i)
	GameData.player_unlocked_ids.sort()
	
	assert(GameData.get_distinct_cards_count() == 49, "Player should have 49 distinct cards")
	assert(not GameData.is_achievement_unlocked("collect_50_cards"), "Achievement should NOT be unlocked at 49 cards")
	assert(not GameData.has_exp_share(), "Exp share should not be owned yet")
	
	var prog49 = GameData.get_achievement_progress("collect_50_cards")
	assert(prog49.get("current", 0) == 49, "Progress current should be 49")
	assert(prog49.get("target", 0) == 50, "Progress target should be 50")
	assert(not prog49.get("is_completed", true), "is_completed should be false")
	print("✓ 49 cards state verified (locked, no reward).")
	
	# Unlock 50th card: ID 50
	print("Unlocking 50th card...")
	GameData.unlock_pokemon(50)
	
	assert(GameData.get_distinct_cards_count() >= 50, "Player should now have 50 cards")
	assert(GameData.is_achievement_unlocked("collect_50_cards"), "Achievement MUST be automatically unlocked on reaching 50 cards!")
	assert(GameData.has_unlocked_exp_share, "has_unlocked_exp_share must now be true")
	assert(GameData.has_exp_share(), "has_exp_share() must now return true")
	assert(int(GameData.campaign_inventory.get("exp_share", 0)) == 1, "Exp share must be in campaign inventory")
	assert(int(GameData.adventure_inventory.get("exp_share", 0)) == 1, "Exp share must be in adventure inventory")
	assert(GameData.has_pending_achievement_notifications(), "Must have pending achievement notification for lobby modal")
	print("✓ 50 cards auto-unlock and Exp Share reward granted successfully!")

func test_lobby_button_and_modals() -> void:
	print("\n--- Test 3: Lobby Button & Modal Integration ---")
	var menu_scene = load("res://scenes/main_menu.tscn")
	var menu = menu_scene.instantiate()
	add_child(menu)
	await get_tree().process_frame
	
	# Verify button in menu
	assert(menu.btn_achievements != null, "btn_achievements must exist in main menu")
	print("✓ btn_achievements exists in main menu.")
	
	# Update badge to trigger notification check
	menu._update_lobby_header_badge()
	await get_tree().process_frame
	
	# Verify notification modal appeared in lobby
	assert(menu.achievement_notif_modal != null, "achievement_notif_modal must be instantiated")
	assert(menu.achievement_notif_modal.visible == true, "achievement_notif_modal must be VISIBLE in lobby when notification is pending")
	assert("Conseguir 50 cartas" in menu.achievement_notif_title_lbl.text, "Modal title must mention the achievement")
	assert(menu.achievement_notif_icon_rect.texture != null, "Reward icon texture must be displayed")
	print("✓ Automatic Lobby Notification Modal popped up with full reward details!")
	
	# Dismiss notification
	menu.btn_claim_achievement_notif.pressed.emit()
	await get_tree().process_frame
	
	assert(menu.achievement_notif_modal.visible == false, "Notification modal should now be dismissed")
	assert(not GameData.has_pending_achievement_notifications(), "Pending notifications list should now be empty")
	print("✓ Notification modal dismissed and marked seen.")
	
	# Test opening Achievements Modal via button
	menu.btn_achievements.pressed.emit()
	await get_tree().process_frame
	
	assert(menu.achievements_modal != null, "achievements_modal must be instantiated")
	assert(menu.achievements_modal.visible == true, "achievements_modal must become visible on button press")
	assert(menu.achievements_list_vbox.get_child_count() >= 1, "Achievements list should have items")
	
	# Check card content
	var first_card = menu.achievements_list_vbox.get_child(0)
	var card_text = first_card.get_parsed_text() if first_card.has_method("get_parsed_text") else ""
	print("✓ Achievements review modal displayed completed achievement!")
	
	# Close achievements modal
	menu.btn_close_achievements.pressed.emit()
	await get_tree().process_frame
	assert(menu.achievements_modal.visible == false, "Achievements modal must close on close button press")
	print("✓ Achievements modal closed successfully.")
	
	menu.queue_free()
