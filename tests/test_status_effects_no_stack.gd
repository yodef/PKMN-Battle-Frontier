extends Node

func _ready() -> void:
	print("--- Running Test: Status Effects No Re-stacking & Redundancy Guard ---")
	
	GameData.is_campaign_mode = false
	GameData.is_tutorial_mode = false
	GameData.is_online_pvp = false
	
	var battle_scene = load("res://scenes/battle.tscn")
	assert(battle_scene != null, "scenes/battle.tscn must be valid")
	
	var battle = battle_scene.instantiate()
	add_child(battle)
	
	var player = battle.get_active_player()
	var enemy = battle.get_active_enemy()
	assert(player != null, "Player must exist")
	assert(enemy != null, "Enemy must exist")
	
	# Poliwag (ID 63 in poke_stats.csv) has Hypnosis as Move 1
	var poliwag = GameData.create_pokemon_instance(63)
	assert(poliwag != null, "Poliwag must exist")
	var sleep_move = poliwag.moves[0]
	assert(sleep_move.effect_type == "SLEEP", "Move 1 must be SLEEP (Hypnosis), got: %s" % sleep_move.name)
	print("Found SLEEP move: %s (cost: %d)" % [sleep_move.name, sleep_move.cost])
	
	# Test 1: Using SLEEP on awake Pokemon puts it to sleep for 2 rounds
	player.is_asleep_turns = 0
	player.immune_sleep_rounds = 0
	enemy.current_energy = 10
	battle.perform_attack(enemy, player, sleep_move, false, sleep_move.cost, battle.enemy_card_img, battle.player_card_img)
	assert(player.is_asleep_turns == 2, "Awake player should now have is_asleep_turns == 2, got: %d" % player.is_asleep_turns)
	print("✅ Test 1 Passed: SLEEP properly inflicts 2 turns on awake target")
	
	# Test 2: Target is down to 1 turn of sleep. Using SLEEP again MUST NOT reset or increase turns!
	player.is_asleep_turns = 1
	enemy.current_energy = 10
	battle.perform_attack(enemy, player, sleep_move, false, sleep_move.cost, battle.enemy_card_img, battle.player_card_img)
	assert(player.is_asleep_turns == 1, "Sleeping player must STAY at 1 turn of sleep! Got: %d" % player.is_asleep_turns)
	var last_log = battle.combat_history[battle.combat_history.size() - 1]
	print("Combat log: %s" % last_log)
	assert(last_log.contains("already asleep") and last_log.contains("no effect"), "Log must mention already asleep - move had no effect")
	print("✅ Test 2 Passed: Using SLEEP on already sleeping target does NOT re-stack or reset turns, and logs proper note")
	
	# Test 3: Target has sleep immunity. SLEEP must have no effect!
	player.is_asleep_turns = 0
	player.immune_sleep_rounds = 1
	enemy.current_energy = 10
	battle.perform_attack(enemy, player, sleep_move, false, sleep_move.cost, battle.enemy_card_img, battle.player_card_img)
	assert(player.is_asleep_turns == 0, "Immune player must remain at 0 sleep turns! Got: %d" % player.is_asleep_turns)
	var immune_log = battle.combat_history[battle.combat_history.size() - 1]
	print("Combat log: %s" % immune_log)
	assert(immune_log.contains("Immune to Sleep") and immune_log.contains("no effect"), "Log must mention immunity to sleep")
	print("✅ Test 3 Passed: Target with sleep immunity avoids sleep and logs proper note")
	
	# Test 4: Check _is_status_move_redundant helper
	assert(battle._is_status_move_redundant(sleep_move, player) == true, "Should be redundant when immune")
	player.immune_sleep_rounds = 0
	assert(battle._is_status_move_redundant(sleep_move, player) == false, "Should NOT be redundant when awake & not immune")
	player.is_asleep_turns = 2
	assert(battle._is_status_move_redundant(sleep_move, player) == true, "Should be redundant when asleep")
	print("✅ Test 4 Passed: _is_status_move_redundant correctly identifies sleep status redundancy")
	
	# Test 5: Check PARALYZE does not re-stack turns (Pikachu ID 25 or Thunder Wave)
	var paralyze_move = null
	for id in GameData.pokemon_catalog.keys():
		var p_data = GameData.create_pokemon_instance(int(id))
		if p_data:
			for m in p_data.moves:
				if m.effect_type == "PARALYZE":
					paralyze_move = m
					break
			if paralyze_move:
				break
	if paralyze_move:
		player.is_paralyzed = true
		player.paralyze_turns = 1
		enemy.current_energy = 10
		battle.perform_attack(enemy, player, paralyze_move, false, paralyze_move.cost, battle.enemy_card_img, battle.player_card_img)
		assert(player.paralyze_turns == 1, "Paralyze turns must NOT be re-stacked! Got: %d" % player.paralyze_turns)
		var para_log = battle.combat_history[battle.combat_history.size() - 1]
		assert(para_log.contains("already paralyzed") and para_log.contains("no effect"), "Log must mention already paralyzed")
		print("✅ Test 5 Passed: PARALYZE does not re-stack turns when already paralyzed")
		
	# Test 6: Check BURN does not re-stack turns (Charmander row ID 1 with boosted Ember)
	player.current_hp = 50
	player.max_hp = 50
	var charmander = GameData.create_pokemon_instance(1)
	var burn_move = charmander.moves[1]
	if burn_move:
		player.burn_turns = 1
		player.burn_dmg = 2
		enemy.current_energy = 10
		battle.perform_attack(enemy, player, burn_move, true, burn_move.cost + burn_move.boost_cost, battle.enemy_card_img, battle.player_card_img)
		assert(player.burn_turns == 1, "Burn turns must NOT be re-stacked! Got: %d" % player.burn_turns)
		var burn_log = battle.combat_history[battle.combat_history.size() - 1]
		print("Burn log: %s" % burn_log)
		assert(burn_log.contains("already burned") and burn_log.contains("no effect"), "Log must mention already burned")
		print("✅ Test 6 Passed: BURN does not re-stack turns when already burned")

	print("🎉 ALL STATUS EFFECT RE-STACKING AND REDUNDANCY CHECKS PASSED SUCCESSFULLY!")
	get_tree().quit()
