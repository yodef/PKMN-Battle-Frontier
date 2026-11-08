extends Control

func _ready() -> void:
	print("========================================")
	print("--- TEST ALL COMBAT INSTANCES START ---")
	print("========================================")
	
	# TEST 1: Tutorial Phase 1
	print("\n>>> Testing Tutorial Phase 1...")
	GameData.is_tutorial_mode = true
	GameData.is_campaign_mode = false
	GameData.is_pvp_mode = false
	GameData.is_online_pvp = false
	GameData.tutorial_combat_phase = 1
	GameData.set_tutorial_starter(1) # Charmander
	
	var b1 = load("res://scenes/battle.tscn").instantiate()
	add_child(b1)
	print("B1 Title: ", b1.battle_title_lbl.text)
	assert(b1.player_team.size() == 1, "Player team should be 1")
	assert(b1.enemy_team.size() == 1, "Enemy team should be 1")
	b1.execute_round_turn()
	print("B1 can_player_act: ", b1.can_player_act)
	# Dismiss tutorial callouts if shown
	if b1.tutorial_callout_modal and b1.tutorial_callout_modal.visible:
		print("Dismissing B1 tutorial callout...")
		b1._on_tutorial_callout_next_pressed()
	b1.queue_free()
	
	# TEST 2: Tutorial Phase 2
	print("\n>>> Testing Tutorial Phase 2...")
	GameData.is_tutorial_mode = true
	GameData.is_campaign_mode = false
	GameData.tutorial_combat_phase = 2
	GameData.tutorial_stage1_id = 6 # Charmeleon
	GameData.tutorial_rival_stage1_id = 4 # Ivysaur
	
	var b2 = load("res://scenes/battle.tscn").instantiate()
	add_child(b2)
	print("B2 Title: ", b2.battle_title_lbl.text)
	assert(b2.player_team.size() == 2, "Player team should be 2 in Phase 2")
	assert(b2.enemy_team.size() == 2, "Enemy team should be 2 in Phase 2")
	b2.execute_round_turn()
	if b2.tutorial_callout_modal and b2.tutorial_callout_modal.visible:
		print("Dismissing B2 tutorial callout...")
		b2._on_tutorial_callout_next_pressed()
	b2.queue_free()
	
	# TEST 3: Quick Battle
	print("\n>>> Testing Quick Battle...")
	GameData.is_tutorial_mode = false
	GameData.is_campaign_mode = false
	GameData.is_pvp_mode = false
	GameData.is_online_pvp = false
	GameData.player_team_ids = [0, 1, 2]
	GameData.enemy_team_ids = [3, 4, 5]
	
	var b3 = load("res://scenes/battle.tscn").instantiate()
	add_child(b3)
	print("B3 Title: ", b3.battle_title_lbl.text)
	assert(b3.player_team.size() == 3, "Player team should be 3")
	assert(b3.enemy_team.size() == 3, "Enemy team should be 3")
	b3.execute_round_turn()
	print("B3 player active: ", b3.get_active_player().name)
	print("B3 controls enabled: ", b3._is_turn_action_allowed())
	b3.queue_free()
	
	# TEST 4: Adventure Mode Episode 1
	print("\n>>> Testing Adventure Mode Episode 1...")
	GameData.is_tutorial_mode = false
	GameData.is_campaign_mode = true
	GameData.campaign_submode = "ADVENTURE"
	GameData.adventure_current_episode = 1
	GameData.adventure_current_stage = 1
	GameData.init_adventure_team(1, [0, 1, 2])
	
	var b4 = load("res://scenes/battle.tscn").instantiate()
	add_child(b4)
	print("B4 Title: ", b4.battle_title_lbl.text)
	b4.execute_round_turn()
	print("B4 can_player_act: ", b4.can_player_act)
	b4.queue_free()
	
	# TEST 5: Tournament Mode
	print("\n>>> Testing Tournament Mode...")
	GameData.is_tutorial_mode = false
	GameData.is_campaign_mode = true
	GameData.campaign_submode = "TOURNAMENT"
	GameData.campaign_match_number = 1
	GameData.init_campaign_team([0, 1, 2])
	
	var b5 = load("res://scenes/battle.tscn").instantiate()
	add_child(b5)
	print("B5 Title: ", b5.battle_title_lbl.text)
	b5.execute_round_turn()
	print("B5 can_player_act: ", b5.can_player_act)
	b5.queue_free()
	
	print("\n========================================")
	print("ALL COMBAT INSTANCES PASSED WITHOUT ERRORS!")
	print("========================================")
	get_tree().quit(0)
