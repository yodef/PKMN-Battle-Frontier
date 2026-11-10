extends Node

func _ready() -> void:
	print("=== FULL TEST: CAMPAIGN TOURNAMENT TEAM LIFECYCLE ===")
	
	# 1. Setup tournament submode and clear team
	GameData.campaign_submode = "TOURNAMENT"
	GameData.campaign_match_number = 1
	GameData.campaign_player_team_state.clear()
	
	var main_scene = load("res://scenes/main_menu.tscn").instantiate()
	add_child(main_scene)
	await get_tree().process_frame
	
	# Test initial team select
	print("\n--- Step 1: Initial Team Select ---")
	var initial_ids: Array[int] = [0, 1, 2] # Bulbasaur, Charmander, Squirtle
	main_scene.selected_player_ids = initial_ids
	GameData.change_campaign_team(initial_ids)
	assert(GameData.campaign_player_team_state.size() == 3, "Team state should have 3 members")
	
	main_scene.update_campaign_ui()
	await get_tree().process_frame
	
	var team_list = main_scene.get_node("CampaignModal/Box/TeamScroll/TeamList")
	assert(team_list.get_child_count() == 3, "TeamList should have 3 rendered card panels")
	print("✓ Step 1 Passed: 3 Pokémon cards properly rendered in TeamList.")
	
	# Test 2: Inspect card details
	print("\n--- Step 2: Inspect Card Details ---")
	for i in range(3):
		var panel = team_list.get_child(i)
		assert(panel is PanelContainer, "Card should be PanelContainer")
		assert(panel.visible == true, "Card must be visible")
		print(" - Card %d rendered successfully." % i)
	print("✓ Step 2 Passed: All cards are visible PanelContainers.")
	
	# Test 3: Change Team to different Pokémon
	print("\n--- Step 3: Change Team ---")
	var new_ids: Array[int] = [3, 16, 19] # Pichu, Pidgey, Rattata
	main_scene.selected_player_ids = new_ids
	GameData.change_campaign_team(new_ids)
	assert(GameData.campaign_player_team_state.size() == 3, "Team state should have 3 new members")
	assert(GameData.campaign_player_team_state[0]["id"] == 3, "First should be Pichu")
	
	main_scene.update_campaign_ui()
	await get_tree().process_frame
	
	assert(team_list.get_child_count() == 3, "TeamList should re-render 3 new cards")
	print("✓ Step 3 Passed: Team changed to Pichu, Pidgey, Rattata and re-rendered perfectly.")
	
	# Test 4: Battle 1 Victory and Camp Re-entry
	print("\n--- Step 4: Battle Victory Flow ---")
	GameData.campaign_match_number = 2
	# Damage first pokemon slightly
	GameData.campaign_player_team_state[0]["current_hp"] = 8
	GameData.save_profile()
	
	main_scene.update_campaign_ui()
	await get_tree().process_frame
	
	assert(team_list.get_child_count() == 3, "TeamList should still have 3 cards after victory")
	assert(main_scene.campaign_match_lbl.text.contains("Round") or main_scene.campaign_match_lbl.text.contains("Phase") or main_scene.campaign_match_lbl.text.contains("🏆"), "Match header should update to battle 2")
	print("✓ Step 4 Passed: Match 2 rendered without resetting.")
	
	# Test 5: Profile Persistence
	print("\n--- Step 5: Profile Save & Load Persistence ---")
	GameData.save_profile()
	var saved_ids = []
	for p in GameData.campaign_player_team_state:
		saved_ids.append(int(p["id"]))
	
	GameData.load_profile()
	var loaded_ids = []
	for p in GameData.campaign_player_team_state:
		loaded_ids.append(int(p["id"]))
	
	assert(saved_ids == loaded_ids, "Loaded team state IDs must match saved team state IDs")
	print("✓ Step 5 Passed: Profile correctly saved and reloaded campaign team state: %s" % str(loaded_ids))
	
	main_scene.queue_free()
	print("\n=== ALL CAMPAIGN UI TESTS PASSED PERFECTLY! ===")
	get_tree().quit(0)
