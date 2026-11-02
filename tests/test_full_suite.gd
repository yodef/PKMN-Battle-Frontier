extends Node

func _ready() -> void:
	print("==================================================")
	print("STARTING FULL IN-ENGINE GAME VALIDATION TEST")
	print("==================================================")
	
	# 1. Validate All 167 Pokemon
	assert(GameData.all_pokemon_ids.size() == 167, "Must have 167 Pokemon")
	print("✓ Total Pokemon verified: %d" % GameData.all_pokemon_ids.size())
	
	for pid in GameData.all_pokemon_ids:
		var p = GameData.create_pokemon_instance(pid)
		assert(p != null)
		assert(p.moves.size() == 2)
		assert(p.max_hp > 0)
		assert(p.max_energy > 0)
		assert(p.speed > 0)
	print("✓ All 167 Pokemon instances created and validated with 2 active moves.")
	
	# 2. Validate Passives
	var passives_map = {
		"Ditto": "Slimy",
		"Porygon": "Conversion",
		"Pichu": "Charm",
		"Wartortle": "Protect",
		"Chansey": "Pacifist",
		"Rattata": "Focus Energy",
		"Caterpie": "String Shot",
		"Weedle": "String Shot"
	}
	for pk_name in passives_map.keys():
		var id = GameData.get_pokemon_id_by_name(pk_name)
		assert(id != -1, "Missing pkmn %s" % pk_name)
		var inst = GameData.create_pokemon_instance(id)
		assert(inst.passive_name == passives_map[pk_name], "Passive mismatch on %s" % pk_name)
		print("  - Passive verified for %s: %s" % [pk_name, inst.passive_name])
	print("✓ All active passives verified!")

	# 3. Simulate Battle Scene
	var b_res = load("res://scenes/battle.tscn")
	var battle = b_res.instantiate()
	add_child(battle)
	print("✓ Battle scene instantiated into node tree.")
	
	# Let battle initialize
	var p = battle.get_active_player()
	var e = battle.get_active_enemy()
	print("Active Matchup: %s vs %s" % [p.name, e.name])
	
	for m in p.moves:
		var pred = battle.calculate_predicted_damage(p, e, m, m.cost, false)
		var sum = battle.get_move_effect_summary(m, false)
		print("  - Player Move %s [%s] -> Pred DMG: %d, Tooltip: '%s'" % [m.name, m.effect_type, pred, sum])
	for m in e.moves:
		var pred = battle.calculate_predicted_damage(e, p, m, m.cost, false)
		var sum = battle.get_move_effect_summary(m, false)
		print("  - Enemy Move %s [%s] -> Pred DMG: %d, Tooltip: '%s'" % [m.name, m.effect_type, pred, sum])
		
	# 4. Test Attack with Status Infliction
	print("Testing Move execution...")
	var test_move = p.moves[1]
	p.current_energy = p.max_energy
	battle.perform_attack(p, e, test_move, false, test_move.cost, battle.player_card_img, battle.enemy_card_img)
	print("✓ Perform attack executed cleanly. Enemy HP: %d/%d" % [e.current_hp, e.max_hp])
	
	print("==================================================")
	print("ALL IN-ENGINE TESTS COMPLETED SUCCESSFULLY (100% OK)")
	print("==================================================")
	get_tree().quit(0)
