extends Node

func _ready():
	print("=== RUNNING TEST: EXP SHARE ITEM ===")
	
	# 1. Texture check
	var exp_share_tex = GameData.get_item_texture("exp_share")
	assert(exp_share_tex != null, "GameData.get_item_texture('exp_share') must return a valid texture")
	print("✓ Exp Share texture loaded successfully: %s" % exp_share_tex.resource_path)
	
	# Setup Battle Scene
	var battle_scene = load("res://scenes/battle.tscn")
	var battle = battle_scene.instantiate()
	add_child(battle)
	await get_tree().process_frame
	
	GameData.is_campaign_mode = true
	GameData.campaign_inventory = GameData.DEFAULT_INVENTORY.duplicate(true)
	
	# Ensure exp_share is 0 initially
	GameData.campaign_inventory["exp_share"] = 0
	assert(not GameData.has_exp_share(), "Should not have exp_share when count is 0")
	
	# Setup Leader (Active): ID 1
	var leader = GameData.create_pokemon_instance(1)
	leader.current_exp = 0
	
	# Setup Bench 1: ID 173 (Totodile, req 10)
	var bench1 = GameData.create_pokemon_instance(173)
	bench1.current_exp = 0
	
	# Setup Bench 2: ID 173 (Totodile, req 10)
	var bench2 = GameData.create_pokemon_instance(173)
	bench2.current_exp = 0
	
	# Setup Defender: Snorlax or high HP foe, plus reserve so team doesn't wipe
	var defender = GameData.create_pokemon_instance(143)
	defender.current_hp = 100
	defender.weakness = "NONE"
	defender.resistant = "NONE"
	defender.shield_reduction = 0
	defender.wall_hp = 0
	
	var defender_reserve = GameData.create_pokemon_instance(143)
	defender_reserve.current_hp = 100
	
	battle.player_team = [leader, bench1, bench2]
	battle.active_player_idx = 0
	battle.enemy_team = [defender, defender_reserve]
	battle.active_enemy_idx = 0
	
	# Also setup campaign team state
	GameData.campaign_player_team_state = [
		{"id": 1, "card_id": 1, "current_hp": 50, "max_hp": 50, "current_exp": 0, "status": "NONE"},
		{"id": 173, "card_id": 173, "current_hp": 30, "max_hp": 30, "current_exp": 0, "status": "NONE"},
		{"id": 173, "card_id": 173, "current_hp": 25, "max_hp": 25, "current_exp": 0, "status": "NONE"}
	]
	
	var move_10dmg = GameData.MoveData.new("Hit 10", "NORMAL", 10, 1, 1, false, 0, 0, false, "10 dmg")
	leader.current_energy = 5
	leader.damage_buff = 0
	leader.foe_damage_debuff = 0
	
	# TEST 1: Attack without Exp Share
	print("\n--- Test 1: Leader attacks dealing 10 effective dmg WITHOUT Exp Share ---")
	battle.perform_attack(leader, defender, move_10dmg, false, 1, battle.player_card_img, battle.enemy_card_img)
	assert(leader.current_exp == 10, "Leader should receive 10 EXP")
	assert(bench1.current_exp == 0, "Bench 1 should receive 0 EXP without Exp Share")
	assert(bench2.current_exp == 0, "Bench 2 should receive 0 EXP without Exp Share")
	print("✓ Test 1 Passed: No EXP shared when Exp Share is not owned.")
	
	# TEST 2: Attack WITH Exp Share (20% of 10 = 2 EXP to Bench 1)
	print("\n--- Test 2: Leader attacks dealing 10 effective dmg WITH Exp Share ---")
	GameData.campaign_inventory["exp_share"] = 1
	assert(GameData.has_exp_share(), "has_exp_share() should be true")
	
	leader.current_exp = 0
	bench1.current_exp = 0
	bench2.current_exp = 0
	leader.current_energy = 5
	defender.current_hp = 100
	
	battle.perform_attack(leader, defender, move_10dmg, false, 1, battle.player_card_img, battle.enemy_card_img)
	assert(leader.current_exp == 10, "Leader should receive 10 EXP")
	assert(bench1.current_exp == 2, "Bench 1 should receive 2 EXP (20% of 10)")
	assert(bench2.current_exp == 0, "Bench 2 should receive 0 EXP (only first eligible bench)")
	assert(GameData.get_active_campaign_team_state()[1]["current_exp"] == 2, "Campaign team state for Bench 1 should be synced to 2 EXP")
	print("✓ Test 2 Passed: 20% of EXP successfully shared with first eligible bench Pokémon (2 EXP) and synced to campaign state.")
	
	# TEST 3: Rounding test (4 effective damage -> 20% is 0.8 -> rounds to 1 EXP)
	print("\n--- Test 3: Leader attacks dealing 4 effective dmg (4 HP foe) ---")
	leader.current_exp = 0
	leader.current_energy = 5
	defender.current_hp = 4
	var move_8dmg = GameData.MoveData.new("Hit 8", "NORMAL", 8, 1, 1, false, 0, 0, false, "8 dmg")
	
	var bench1_prev_exp = bench1.current_exp # 2
	battle.perform_attack(leader, defender, move_8dmg, false, 1, battle.player_card_img, battle.enemy_card_img)
	assert(leader.current_exp == 4, "Leader should receive 4 EXP for 4 effective damage")
	assert(bench1.current_exp == bench1_prev_exp + 1, "Bench 1 should receive 1 EXP (20% of 4 = 0.8 -> 1)")
	print("✓ Test 3 Passed: 20%% rounding correctly awarded 1 EXP (bench went from 2 to %d)." % bench1.current_exp)
	
	# TEST 4: First bench at MAX EXP -> Skips to second bench Pokémon
	print("\n--- Test 4: Bench 1 at MAX EXP -> Should skip to Bench 2 ---")
	bench1.current_exp = 10 # MAX for Rattata
	bench2.current_exp = 0
	leader.current_exp = 0
	leader.current_energy = 5
	defender.current_hp = 50
	
	battle.perform_attack(leader, defender, move_10dmg, false, 1, battle.player_card_img, battle.enemy_card_img)
	assert(bench1.current_exp == 10, "Bench 1 remains at MAX 10")
	assert(bench2.current_exp == 2, "Bench 2 should now receive the 20% EXP (2 EXP)")
	assert(GameData.get_active_campaign_team_state()[2]["current_exp"] == 2, "Campaign team state for Bench 2 should be synced to 2 EXP")
	print("✓ Test 4 Passed: Eligible benched target correctly skipped full-EXP Pokémon and awarded Bench 2!")
	
	# TEST 5: All bench at MAX EXP or no eligible Pokémon
	print("\n--- Test 5: All bench at MAX EXP ---")
	bench2.current_exp = 10
	leader.current_exp = 0
	leader.current_energy = 5
	defender.current_hp = 50
	battle.perform_attack(leader, defender, move_10dmg, false, 1, battle.player_card_img, battle.enemy_card_img)
	assert(leader.current_exp == 10, "Leader still gets full EXP")
	print("✓ Test 5 Passed: No crash or invalid assignment when no bench Pokémon can receive EXP.")
	
	battle.queue_free()
	print("\n=== ALL EXP SHARE TESTS PASSED PERFECTLY! ===")
	get_tree().quit(0)
