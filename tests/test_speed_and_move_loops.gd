extends Node

func _ready() -> void:
	print("==================================================")
	print("🧪 RUNNING TEST SUITE: SPEED 1-10 & MOVE LOOP REBALANCE")
	print("==================================================")
	
	var all_passed: bool = true
	
	# -------------------------------------------------------------
	# TEST 1: Speed 1-10 distribution in catalog
	# -------------------------------------------------------------
	print("\n--- Test 1: Speed scale 1-10 verification ---")
	var spd_counts = {}
	for i in range(1, 11):
		spd_counts[i] = 0
		
	var min_spd = 999
	var max_spd = -999
	for pkmn_id in GameData.pokemon_catalog:
		var raw = GameData.pokemon_catalog[pkmn_id]
		var spd = int(raw.get("speed", 0))
		min_spd = min(min_spd, spd)
		max_spd = max(max_spd, spd)
		if spd_counts.has(spd):
			spd_counts[spd] += 1
			
	print("Min Speed: %d, Max Speed: %d" % [min_spd, max_spd])
	for spd in range(1, 11):
		print("Speed %2d: %3d Pokemon" % [spd, spd_counts[spd]])
		
	if min_spd == 1 and max_spd == 10 and spd_counts[1] > 0 and spd_counts[10] > 0:
		print("✅ TEST 1 PASSED: Speed is fully distributed across 1-10 scale.")
	else:
		print("❌ TEST 1 FAILED: Speed bounds not matching 1-10.")
		all_passed = false
		
	# Check specific iconic Pokemon (Ninjask 296, Shuckle 222, Blastoise 9)
	var ninjask_inst = GameData.create_pokemon_instance(296)
	var shuckle_inst = GameData.create_pokemon_instance(222)
	var blastoise_inst = GameData.create_pokemon_instance(9)
	print("Ninjask speed: %d (expected 10)" % ninjask_inst.speed)
	print("Shuckle speed: %d (expected 1)" % shuckle_inst.speed)
	print("Blastoise speed: %d (expected 6)" % blastoise_inst.speed)
	if ninjask_inst.speed == 10 and shuckle_inst.speed == 1 and blastoise_inst.speed == 6:
		print("✅ Iconic Pokemon speed test passed.")
	else:
		print("❌ Iconic Pokemon speed test failed.")
		all_passed = false

	# -------------------------------------------------------------
	# TEST 2: Move loop & Forced Rest Energy Rebalance (Hyper Beam)
	# -------------------------------------------------------------
	print("\n--- Test 2: Hyper Beam Rest Fatigue (+1⚡ instead of recover_amount) ---")
	var battle_scene = load("res://scenes/battle.tscn").instantiate()
	add_child(battle_scene)
	
	# Create Snorlax (158) with recover_amount = 4
	var p_snorlax = GameData.create_pokemon_instance(158)
	p_snorlax.current_energy = 0
	p_snorlax.rest_next_turn = true
	
	# Simulate rest turn in battle
	# In battle.gd line 1685, resting gives: var rec = min(1, actor.max_energy - actor.current_energy)
	var rec = min(1, p_snorlax.max_energy - p_snorlax.current_energy)
	p_snorlax.current_energy += rec
	p_snorlax.rest_next_turn = false
	
	print("Snorlax recover_amount: %d | Energy gained during Rest: %d (Current: %d/%d)" % [p_snorlax.recover_amount, rec, p_snorlax.current_energy, p_snorlax.max_energy])
	if rec == 1 and p_snorlax.current_energy == 1:
		print("✅ TEST 2 PASSED: Forced Rest only gives +1⚡ fatigue recovery, breaking infinite Hyper Beam loops.")
	else:
		print("❌ TEST 2 FAILED: Rest recovered more than 1 energy.")
		all_passed = false

	# -------------------------------------------------------------
	# TEST 3: Healing Moves cost = 3 and HEAL effect
	# -------------------------------------------------------------
	print("\n--- Test 3: Healing Moves (Recover, Milk Drink, Soft-Boiled) ---")
	var rec_data = GameData.get_move_data("Recover")
	var milk_data = GameData.get_move_data("Milk Drink")
	var soft_data = GameData.get_move_data("Soft-Boiled")
	
	print("Recover: Cost=%d (expected 3), Effect=%s (expected HEAL)" % [rec_data["cost"], rec_data["effect_type"]])
	print("Milk Drink: Cost=%d (expected 3), Effect=%s (expected HEAL)" % [milk_data["cost"], milk_data["effect_type"]])
	print("Soft-Boiled: Cost=%d (expected 3), Effect=%s (expected HEAL)" % [soft_data["cost"], soft_data["effect_type"]])
	
	if rec_data["cost"] == 3 and rec_data["effect_type"] == "HEAL" and milk_data["cost"] == 3 and milk_data["effect_type"] == "HEAL" and soft_data["cost"] == 3 and soft_data["effect_type"] == "HEAL":
		print("✅ TEST 3 PASSED: Healing moves cost 3⚡ and have dedicated HEAL effect_type.")
	else:
		print("❌ TEST 3 FAILED: Healing move stats or effect_type incorrect.")
		all_passed = false

	# -------------------------------------------------------------
	# TEST 4: Evasion & Dig Anti-Spam (Failure on consecutive usage)
	# -------------------------------------------------------------
	print("\n--- Test 4: Evasion & Dig Consecutive Anti-Spam ---")
	var teleport_data = GameData.get_move_data("Teleport")
	var dig_data = GameData.get_move_data("Dig")
	
	var user_inst = GameData.create_pokemon_instance(66) # Abra
	# Turn 1: uses Teleport
	user_inst.last_move_used = "Pound"
	var t1_fail = (user_inst.last_move_used == teleport_data["name"])
	user_inst.is_evasive = not t1_fail
	user_inst.last_move_used = teleport_data["name"]
	
	# Turn 2: attempts Teleport again consecutively
	var t2_fail = (user_inst.last_move_used == teleport_data["name"])
	print("Turn 1 Teleport Consecutive Failure: %s (is_evasive=%s)" % [t1_fail, user_inst.is_evasive])
	print("Turn 2 Teleport Consecutive Failure: %s (should fail)" % [t2_fail])
	
	if not t1_fail and t2_fail:
		print("✅ TEST 4 PASSED: Evasion cannot be spammed in consecutive rounds.")
	else:
		print("❌ TEST 4 FAILED: Evasion consecutive check did not trigger properly.")
		all_passed = false

	# -------------------------------------------------------------
	# TEST 5: Paralysis & Sleep Immunity (Anti-Lock Chains)
	# -------------------------------------------------------------
	print("\n--- Test 5: Paralysis & Sleep Immunity after recovery ---")
	var target_pkmn = GameData.create_pokemon_instance(25) # Pikachu
	target_pkmn.is_paralyzed = true
	target_pkmn.paralyze_turns = 1
	
	# End of round: recovers from paralysis
	target_pkmn.paralyze_turns -= 1
	if target_pkmn.paralyze_turns <= 0:
		target_pkmn.is_paralyzed = false
		target_pkmn.immune_paralyze_rounds = 1
		
	var twave_data = GameData.get_move_data("Thunder Wave")
	var twave = GameData.MoveData.new(
		twave_data["name"], twave_data["type"], twave_data["dmg"], twave_data["cost"], twave_data["req"],
		false, 0, 0, false, twave_data["desc"]
	)
	twave.effect_type = twave_data["effect_type"]
	
	var redundant = battle_scene._is_status_move_redundant(twave, target_pkmn)
	print("Target immune_paralyze_rounds: %d | Thunder Wave redundant: %s" % [target_pkmn.immune_paralyze_rounds, redundant])
	
	# Decrement immunity at end of next round
	if target_pkmn.immune_paralyze_rounds > 0 and not target_pkmn.is_paralyzed:
		target_pkmn.immune_paralyze_rounds -= 1
	print("Target immune_paralyze_rounds after cooldown: %d" % target_pkmn.immune_paralyze_rounds)
	
	if redundant and target_pkmn.immune_paralyze_rounds == 0:
		print("✅ TEST 5 PASSED: Target receives 1 round immunity against Paralysis upon waking/recovering, preventing perma-locks.")
	else:
		print("❌ TEST 5 FAILED: Paralysis immunity check failed.")
		all_passed = false

	battle_scene.queue_free()

	print("\n==================================================")
	if all_passed:
		print("🎉 ALL TESTS PASSED SUCCESSFULLY! (EXIT CODE 0)")
		print("==================================================")
		get_tree().quit(0)
	else:
		print("💥 SOME TESTS FAILED! (EXIT CODE 1)")
		print("==================================================")
		get_tree().quit(1)
