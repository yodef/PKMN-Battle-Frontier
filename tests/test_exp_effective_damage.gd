extends Node

func _ready():
	print("=== RUNNING TEST: EXP GAINED BY EFFECTIVE DAMAGE INFLICTED ===")
	var battle_scene = load("res://scenes/battle.tscn")
	var battle = battle_scene.instantiate()
	add_child(battle)
	await get_tree().process_frame
	
	GameData.is_campaign_mode = true
	
	# Create Attacker: Bulbasaur (ID 1, req_exp = 10)
	var attacker = GameData.create_pokemon_instance(1)
	attacker.current_exp = 0
	var req_exp = attacker.get_required_exp()
	assert(req_exp == 10, "Bulbasaur req_exp should be 10")
	
	# Create Defender: Rattata (ID 19)
	var defender = GameData.create_pokemon_instance(19)
	
	battle.player_team = [attacker]
	battle.active_player_idx = 0
	battle.enemy_team = [defender]
	battle.active_enemy_idx = 0
	
	# Prepare a Move with base_damage = 8 (cost = 1)
	var test_move_8dmg = GameData.MoveData.new("Tackle 8", "NORMAL", 8, 1, 1, false, 0, 0, false, "Deals 8 damage.")
	attacker.current_energy = 5
	attacker.damage_buff = 0
	attacker.foe_damage_debuff = 0
	defender.weakness = "NONE"
	defender.resistant = "NONE"
	defender.shield_reduction = 0
	defender.wall_hp = 0
	
	# TEST 1: Enemy has only 4 HP left. Move deals 8 DMG.
	# Effective damage inflicted is 4. Attacker should receive 4 EXP, NOT 8!
	defender.current_hp = 4
	attacker.current_exp = 0
	
	print("--- Test 1: Enemy has 4 HP, Move deals 8 DMG ---")
	battle.perform_attack(attacker, defender, test_move_8dmg, false, 1, battle.player_card_img, battle.enemy_card_img)
	
	assert(defender.current_hp == 0, "Defender HP should be 0")
	print("Defender HP after attack: %d" % defender.current_hp)
	print("Attacker EXP after attack: %d (expected: 4)" % attacker.current_exp)
	assert(attacker.current_exp == 4, "Attacker must receive EXACTLY 4 EXP (effective damage inflicted), not 8!")
	print("✓ Test 1 Passed: Overkill damage did not inflate EXP!")
	
	# TEST 2: Enemy has 10 HP. Move deals 3 DMG.
	# Effective damage inflicted is 3. Attacker should gain 3 EXP (4 -> 7).
	print("\n--- Test 2: Enemy has 10 HP, Move deals 3 DMG ---")
	defender.current_hp = 10
	var test_move_3dmg = GameData.MoveData.new("Tackle 3", "NORMAL", 3, 1, 1, false, 0, 0, false, "Deals 3 damage.")
	attacker.current_energy = 5
	
	battle.perform_attack(attacker, defender, test_move_3dmg, false, 1, battle.player_card_img, battle.enemy_card_img)
	
	assert(defender.current_hp == 7, "Defender HP should be 7")
	print("Defender HP after attack: %d" % defender.current_hp)
	print("Attacker EXP after attack: %d (expected: 7)" % attacker.current_exp)
	assert(attacker.current_exp == 7, "Attacker must receive 3 EXP (effective damage), reaching 7/10!")
	print("✓ Test 2 Passed: Standard damage grants exact effective EXP!")
	
	# TEST 3: Enemy has 0 HP (or 0 effective damage).
	# Effective damage is 0. Attacker should gain 0 EXP (remains 7).
	print("\n--- Test 3: Attack against 0 HP foe ---")
	defender.current_hp = 0
	attacker.current_energy = 5
	
	battle.perform_attack(attacker, defender, test_move_8dmg, false, 1, battle.player_card_img, battle.enemy_card_img)
	
	print("Attacker EXP after 0 damage attack: %d (expected: 7)" % attacker.current_exp)
	assert(attacker.current_exp == 7, "Attacker must gain 0 EXP when effective damage is 0!")
	print("✓ Test 3 Passed: Zero effective damage grants zero EXP!")
	
	# TEST 4: Enemy has 10 HP. Attacker has 9 EXP (req: 10). Move deals 5 DMG.
	# Effective damage is 5, but capped at required_exp (10).
	print("\n--- Test 4: Attacker at 9/10 EXP, deals 5 effective damage ---")
	defender.current_hp = 10
	attacker.current_exp = 9
	attacker.current_energy = 5
	var test_move_5dmg = GameData.MoveData.new("Tackle 5", "NORMAL", 5, 1, 1, false, 0, 0, false, "Deals 5 damage.")
	
	battle.perform_attack(attacker, defender, test_move_5dmg, false, 1, battle.player_card_img, battle.enemy_card_img)
	
	assert(defender.current_hp == 5, "Defender HP should be 5")
	print("Attacker EXP after attack: %d (expected: 10 MAX)" % attacker.current_exp)
	assert(attacker.current_exp == 10, "Attacker EXP must cap at 10/10 (req_exp)!")
	print("✓ Test 4 Passed: EXP caps properly at req_exp!")
	
	battle.queue_free()
	print("\n=== ALL EXP EFFECTIVE DAMAGE TESTS PASSED PERFECTLY! ===")
	get_tree().quit(0)
