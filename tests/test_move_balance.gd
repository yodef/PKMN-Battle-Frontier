extends Node

func _ready() -> void:
	print("=== RUNNING EXTENDED MOVE BALANCE & TIER AUDIT ===")
	GameData.load_moves_from_csv()
	GameData.load_pokemon_from_csv()
	
	var move_checks = [
		{"name": "Giga Drain", "cost": 2, "base_dmg": 6, "effect_type": "LIFE_DRAIN"},
		{"name": "Solar Beam", "cost": 4, "base_dmg": 20, "effect_type": "REST"},
		{"name": "Psychic", "cost": 2, "base_dmg": 8, "effect_type": "NONE"},
		{"name": "Grand Thunder", "cost": 4, "base_dmg": 12, "effect_type": "PARALYZE"},
		{"name": "Thunder Punch", "cost": 3, "base_dmg": 9, "effect_type": "PARALYZE"},
		{"name": "Psybeam", "cost": 3, "base_dmg": 9, "effect_type": "CONFUSION"},
		{"name": "Hydro Pump", "cost": 3, "base_dmg": 12, "effect_type": "NONE"},
		{"name": "Sludge Bomb", "cost": 3, "base_dmg": 10, "effect_type": "POISON"},
		{"name": "Earthquake", "cost": 4, "base_dmg": 16, "effect_type": "SHIELD_BREAKER"},
		{"name": "Rock Slide", "cost": 4, "base_dmg": 16, "effect_type": "NONE"},
		{"name": "Rock Wrecker", "cost": 4, "base_dmg": 16, "effect_type": "NONE"},
		{"name": "Fissure", "cost": 4, "base_dmg": 16, "effect_type": "NONE"},
		{"name": "Power Whip", "cost": 4, "base_dmg": 16, "effect_type": "NONE"},
		{"name": "Brine", "cost": 4, "base_dmg": 16, "effect_type": "NONE"},
		{"name": "Might Sphere", "cost": 4, "base_dmg": 16, "effect_type": "NONE"},
		{"name": "Mega Punch", "cost": 3, "base_dmg": 12, "effect_type": "NONE"},
		{"name": "Megahorn", "cost": 3, "base_dmg": 12, "effect_type": "NONE"},
		{"name": "Burn Up", "cost": 4, "base_dmg": 16, "effect_type": "BURN"},
		{"name": "Leaf Tornado", "cost": 4, "base_dmg": 16, "effect_type": "SLOW_FOE"},
		{"name": "Aura Sphere", "cost": 3, "base_dmg": 12, "effect_type": "DOUBLE_TYPE"},
		{"name": "Special Punch", "cost": 3, "base_dmg": 12, "effect_type": "TRIPLE_TYPE"},
		{"name": "Thunderbolt", "cost": 3, "base_dmg": 12, "effect_type": "OVERCHARGE"},
		{"name": "Cosmic Power", "cost": 2, "base_dmg": 8, "effect_type": "NONE"},
		{"name": "Dragon Pulse", "cost": 2, "base_dmg": 8, "effect_type": "NONE"},
		{"name": "Hyper Fang", "cost": 2, "base_dmg": 8, "effect_type": "NONE"},
		{"name": "Twister", "cost": 2, "base_dmg": 8, "effect_type": "NONE"},
		{"name": "Aqua Jet", "cost": 1, "base_dmg": 3, "effect_type": "NONE"},
		{"name": "Sonic Boom", "cost": 1, "base_dmg": 3, "effect_type": "NONE"},
		{"name": "Covet", "cost": 1, "base_dmg": 3, "effect_type": "NONE"},
		{"name": "High Confusion", "cost": 3, "base_dmg": 10, "effect_type": "BOOST_CONFUSED"},
		{"name": "Kinetic Beam", "cost": 2, "base_dmg": 7, "effect_type": "ADAPT"},
		{"name": "Pluck", "cost": 1, "base_dmg": 3, "effect_type": "BOOST_DMG_TYPE"},
		{"name": "Zen Headbutt", "cost": 1, "base_dmg": 3, "effect_type": "FLINCH"},
		{"name": "Cross Chop", "cost": 2, "base_dmg": 8, "effect_type": "CRITICAL"},
		{"name": "Crunch", "cost": 3, "base_dmg": 10, "effect_type": "WEAKEN"},
		{"name": "Dragon Breath", "cost": 2, "base_dmg": 6, "effect_type": "PARALYZE"},
		{"name": "Electro Ball", "cost": 4, "base_dmg": 13, "effect_type": "BOOST_IF_FASTER"},
		{"name": "Shadow Punch", "cost": 3, "base_dmg": 12, "effect_type": "SHIELD_BREAKER"}
	]
	
	var all_ok = true
	for c in move_checks:
		var move = GameData.get_move_data(c["name"])
		if not move or move.get("id", 0) == 0:
			print("❌ Move NOT found: ", c["name"])
			all_ok = false
			continue
		var cost_ok = (move["cost"] == c["cost"])
		var dmg_ok = (move["dmg"] == c["base_dmg"])
		var eff_ok = (move["effect_type"] == c["effect_type"])
		if cost_ok and dmg_ok and eff_ok:
			print("✅ Move %s: Cost %d | DMG %d | Effect %s" % [move["name"], move["cost"], move["dmg"], move["effect_type"]])
		else:
			print("❌ Mismatch on Move %s! Expected Cost %d DMG %d Eff %s | Got Cost %d DMG %d Eff %s" % [
				c["name"], c["cost"], c["base_dmg"], c["effect_type"], move["cost"], move["dmg"], move["effect_type"]
			])
			all_ok = false
			
	var pkmn_checks = [
		{"name": "Venusaur", "expected_tier": "S"},
		{"name": "Alakazam", "expected_tier": "S"},
		{"name": "Primeape", "expected_tier": "A"},
		{"name": "Muk", "expected_tier": "A"},
		{"name": "Haunter", "expected_tier": "A"},
		{"name": "Electrode", "expected_tier": "A"},
		{"name": "Dratini", "expected_tier": "B"}
	]
	
	for pk in pkmn_checks:
		var found = false
		for p in GameData.pokemon_catalog.values():
			if p.get("name", "") == pk["name"]:
				found = true
				var t = p.get("tier", "")
				if t == pk["expected_tier"]:
					print("✅ PKMN %s: Tier %s" % [pk["name"], t])
				else:
					print("❌ PKMN %s: Expected Tier %s | Got Tier %s" % [pk["name"], pk["expected_tier"], t])
					all_ok = false
				break
		if not found:
			print("❌ PKMN NOT found in catalog: ", pk["name"])
			all_ok = false
			
	if all_ok:
		print("🎉 ALL MOVE AND TIER AUDIT CHECKS PASSED PERFECTLY!")
	else:
		print("❌ Some checks failed.")
		
	get_tree().quit(0 if all_ok else 1)
