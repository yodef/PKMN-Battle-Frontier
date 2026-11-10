extends Node

func _ready() -> void:
	print("=== RUNNING TEST: LAKE OF RAGE FLOW & NAVIGATION ===")
	
	# Ensure profile has 0 Johto badges
	for ep in [101, 102, 103, 104, 105, 106, 107, 108]:
		GameData.adventure_completed_episodes.erase(ep)
	GameData.lake_of_rage_completed = false
	
	# Test 1: Lake of rage locked when badges < 8
	assert(not GameData.is_lake_of_rage_unlocked(), "Lake of Rage should be locked when Johto is incomplete")
	print("✓ Test 1 Passed: Lake of Rage is locked when Johto badges < 8.")
	
	# Test 2: Lake of rage unlocks ONLY with all 8 Johto badges
	for ep in [101, 102, 103, 104, 105, 106, 107, 108]:
		GameData.adventure_completed_episodes.append(ep)
	assert(GameData.has_all_johto_gym_badges(), "All 8 Johto badges present")
	assert(GameData.is_lake_of_rage_unlocked(), "Lake of rage unlocked with 8 Johto badges")
	print("✓ Test 2 Passed: Lake of Rage unlocks when all 8 Johto badges are earned.")
	
	# Test 3: Lake of rage locks permanently once completed (not repeatable)
	GameData.lake_of_rage_completed = true
	assert(not GameData.is_lake_of_rage_unlocked(), "Lake of Rage locked once completed")
	print("✓ Test 3 Passed: Lake of Rage cannot be re-entered after defeat.")
	
	# Reset state
	GameData.lake_of_rage_completed = false
	
	# Test 4: MainMenu team select & exit flow for Lake of Rage
	print("\n--- Test 4: Main Menu Lake of Rage Navigation ---")
	var main_menu_scene = load("res://scenes/main_menu.tscn")
	var main_menu = main_menu_scene.instantiate()
	add_child(main_menu)
	await get_tree().process_frame
	
	# Trigger Lake of Rage
	main_menu._start_lake_of_rage_event()
	assert(GameData.campaign_submode == "LAKE_OF_RAGE", "Submode should be LAKE_OF_RAGE")
	assert(main_menu.team_select_modal.visible == true, "Team select modal should be open")
	
	# Now press CLOSE / EXIT on team select modal
	main_menu._on_close_team_select_pressed()
	assert(main_menu.team_select_modal.visible == false, "Team select modal should be hidden")
	assert(main_menu.campaign_modal.visible == false, "Campaign modal (Camp) MUST NOT be open!")
	assert(main_menu.johto_episodes_modal.visible == true, "Johto episodes modal MUST be open!")
	assert(GameData.campaign_submode == "ADVENTURE", "Submode should revert to ADVENTURE")
	print("✓ Test 4 Passed: Exiting team select cleanly returns to Johto modal without launching Camp or other modes!")
	
	# Test 5: Starting battle for Lake of Rage
	print("\n--- Test 5: Battle Initialization for Lake of Rage ---")
	GameData.campaign_submode = "LAKE_OF_RAGE"
	GameData.is_campaign_mode = true
	GameData.player_team_ids = [130] # Player Gyarados
	GameData.enemy_team_ids = [GameData.RED_GYARADOS_BOSS_ID]
	
	var battle_scene = load("res://scenes/battle.tscn")
	var battle = battle_scene.instantiate()
	add_child(battle)
	await get_tree().process_frame
	
	assert(battle.enemy_team.size() == 1, "Enemy team should have 1 boss")
	assert(battle.enemy_team[0].name.contains("Red Gyarados"), "Enemy should be Red Gyarados")
	assert(battle.enemy_team[0].max_hp == 600, "Red Gyarados Boss HP should be 600")
	assert(battle.battle_title_lbl.text.contains("GYARADOS ROJO"), "Battle title should name Red Gyarados Boss")
	print("✓ Test 5 Passed: Battle properly spawns Red Gyarados Boss (600 HP) and NOT a tournament battle!")
	
	# Cleanup
	battle.queue_free()
	main_menu.queue_free()
	for ep in [101, 102, 103, 104, 105, 106, 107, 108]:
		GameData.adventure_completed_episodes.erase(ep)
	GameData.lake_of_rage_completed = false
	GameData.campaign_submode = "TOURNAMENT"
	GameData.is_campaign_mode = false
	GameData.save_profile()
	
	print("\n=== ALL LAKE OF RAGE TESTS PASSED PERFECTLY! ===")
	get_tree().quit(0)
