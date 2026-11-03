extends Node

func _ready() -> void:
	print("==================================================")
	print("🧪 RUNNING TEST SUITE: FORFEIT CONFIRMATION & QUICK BATTLE MODES")
	print("==================================================")
	
	test_quick_battle_modes()
	test_battle_forfeit_modal()
	test_online_translations()
	
	print("==================================================")
	print("✅ ALL TESTS PASSED SUCCESSFULLY! (0 ERRORS)")
	print("==================================================")
	get_tree().quit(0)

func test_quick_battle_modes() -> void:
	print("\n--- 1. Testing Quick Battle Modes ---")
	var menu_scene = load("res://scenes/main_menu.tscn").instantiate()
	add_child(menu_scene)
	
	menu_scene._setup_team_select_pvp_controls()
	var qb_row = menu_scene.qb_mode_row
	assert(qb_row != null, "Quick battle row must exist")
	
	# Check children of qb_row
	var child_names = []
	for c in qb_row.get_children():
		child_names.append(c.text)
	
	print("Quick battle buttons: ", child_names)
	assert("🤖 VS AI" in child_names, "VS AI button must exist")
	assert("👥 Pass & Play" in child_names, "Pass & Play button must exist")
	assert(not ("🌐 En Línea" in child_names), "En Línea must NOT be in Quick Battle")
	assert(not ("🌐 Online" in child_names), "Online must NOT be in Quick Battle")
	assert(qb_row.get_child_count() == 2, "Quick battle row must only have 2 options (AI & PVP)")
	
	# Test setting quick battle mode
	menu_scene._set_quick_battle_mode("AI")
	assert(menu_scene.qb_selected_mode == "AI", "Mode should be AI")
	assert(not GameData.is_pvp_mode, "is_pvp_mode should be false for AI")
	assert(not GameData.is_online_pvp, "is_online_pvp should be false for AI")
	
	menu_scene._set_quick_battle_mode("PVP")
	assert(menu_scene.qb_selected_mode == "PVP", "Mode should be PVP")
	assert(GameData.is_pvp_mode, "is_pvp_mode should be true for PVP")
	assert(not GameData.is_online_pvp, "is_online_pvp should be false for PVP")
	
	# Online should not be selectable in quick battle
	menu_scene._set_quick_battle_mode("ONLINE")
	assert(menu_scene.qb_selected_mode == "AI", "Setting ONLINE should fallback to AI")
	assert(not GameData.is_online_pvp, "is_online_pvp should remain false")
	
	menu_scene.queue_free()
	print("✓ Quick battle modes test passed.")

func test_battle_forfeit_modal() -> void:
	print("\n--- 2. Testing Battle Forfeit Modal ---")
	var battle_scene = load("res://scenes/battle.tscn").instantiate()
	add_child(battle_scene)
	
	# Initialize battle scene setup
	battle_scene._setup_forfeit_confirmation_modal()
	assert(battle_scene.forfeit_modal != null, "Forfeit modal must exist")
	assert(not battle_scene.forfeit_modal.visible, "Forfeit modal must start hidden")
	
	# Test 1: During ongoing battle, pressing back menu shows modal
	battle_scene.is_battle_over = false
	GameData.is_online_pvp = true
	GameData.online_rival_name = "Gary"
	
	battle_scene._on_back_menu_pressed()
	assert(battle_scene.forfeit_modal.visible, "Forfeit modal should be visible after back pressed during battle")
	assert("🏳️ FORFEIT MATCH?" in battle_scene.forfeit_title_lbl.text, "Title should show forfeit match for online")
	assert("Gary" in battle_scene.forfeit_body_lbl.text, "Body should mention opponent name")
	
	# Test cancel button hides modal
	battle_scene.btn_cancel_forfeit.pressed.emit()
	assert(not battle_scene.forfeit_modal.visible, "Forfeit modal should hide on cancel")
	
	# Test 2: Campaign mode forfeit
	GameData.is_online_pvp = false
	GameData.is_campaign_mode = true
	GameData.campaign_submode = "ADVENTURE"
	
	battle_scene._show_forfeit_confirmation_modal()
	assert(battle_scene.forfeit_modal.visible, "Forfeit modal should be visible")
	assert("RETREAT" in battle_scene.forfeit_title_lbl.text, "Title should mention RETREAT for adventure")
	assert("Retreat" in battle_scene.btn_confirm_forfeit.text, "Confirm button should say Retreat")
	battle_scene.forfeit_modal.visible = false
	
	# Cleanup
	GameData.is_campaign_mode = false
	GameData.is_online_pvp = false
	battle_scene.queue_free()
	print("✓ Battle forfeit confirmation modal test passed.")

func test_online_translations() -> void:
	print("\n--- 3. Testing Online Modal Translations ---")
	var menu_scene = load("res://scenes/main_menu.tscn").instantiate()
	add_child(menu_scene)
	
	var online_title = menu_scene.get_node("OnlineLobbyModal/OnlineCenter/OnlineCard/OnlineMargin/OnlineVBox/OnlineTitle")
	assert(online_title.text == "🌐 ONLINE POKÉMON BATTLE", "Online title must be in English: got " + online_title.text)
	
	var btn_create = menu_scene.get_node("OnlineLobbyModal/OnlineCenter/OnlineCard/OnlineMargin/OnlineVBox/OnlineModeSelector/BtnTabCreateRoom")
	assert(btn_create.text == "🏠 Create Room", "Create room button must be in English: got " + btn_create.text)
	
	var btn_join = menu_scene.get_node("OnlineLobbyModal/OnlineCenter/OnlineCard/OnlineMargin/OnlineVBox/OnlineModeSelector/BtnTabJoinRoom")
	assert(btn_join.text == "🔑 Join Room", "Join room button must be in English: got " + btn_join.text)
	
	var btn_close = menu_scene.get_node("OnlineLobbyModal/OnlineCenter/OnlineCard/OnlineMargin/OnlineVBox/BtnCloseOnlineLobby")
	assert(btn_close.text == "⬅ Cancel & Return", "Close button must be in English: got " + btn_close.text)
	
	var btn_ready = menu_scene.get_node("OnlineLobbyModal/OnlineCenter/OnlineCard/OnlineMargin/OnlineVBox/JoinPanel/GuestLobbySection/BtnGuestReadyToggle")
	assert(btn_ready.text == "✅ READY FOR BATTLE", "Guest ready button must be in English: got " + btn_ready.text)
	
	menu_scene.queue_free()
	print("✓ Online translations test passed.")
