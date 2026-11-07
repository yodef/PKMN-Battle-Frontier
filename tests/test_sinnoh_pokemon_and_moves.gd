extends Node

func _ready():
	print("=== TEST: Sinnoh Pokémon & Moves Verification ===")
	
	# 1. Total Pokémon loaded in catalog
	var all_p = GameData.pokemon_catalog
	print("Total Pokémon loaded: ", all_p.size())
	assert(all_p.size() == 493, "Expected 493 Pokemon, got " + str(all_p.size()))
	
	# 2. Check Region counts
	var region_counts = {"Kanto": 0, "Johto": 0, "Hoenn": 0, "Sinnoh": 0, "Other": 0}
	for c in all_p.values():
		var reg = str(c.get("region", "Kanto")).strip_edges().capitalize()
		if region_counts.has(reg):
			region_counts[reg] += 1
		else:
			region_counts["Other"] += 1
	print("Region distribution: ", region_counts)
	assert(region_counts["Kanto"] == 151, "Expected 151 Kanto Pokemon, got %d" % region_counts["Kanto"])
	assert(region_counts["Johto"] == 100, "Expected 100 Johto Pokemon, got %d" % region_counts["Johto"])
	assert(region_counts["Hoenn"] == 135, "Expected 135 Hoenn Pokemon, got %d" % region_counts["Hoenn"])
	assert(region_counts["Sinnoh"] == 107, "Expected 107 Sinnoh Pokemon, got %d" % region_counts["Sinnoh"])
	print("✅ Region counts verified: Kanto 151, Johto 100, Hoenn 135, Sinnoh 107 -> Total 493!")
	
	# 3. Check new Sinnoh signature moves
	var sinnoh_moves_to_test = [
		{"name": "Roar of Time", "type": "GROUND", "dmg": 14, "effect": "RECOIL"},
		{"name": "Spacial Rend", "type": "WATER", "dmg": 12, "effect": "CRITICAL"},
		{"name": "Shadow Force", "type": "DARK", "dmg": 14, "effect": "SHIELD_BREAKER"},
		{"name": "Magma Storm", "type": "FIRE", "dmg": 12, "effect": "BURN"},
		{"name": "Crush Grip", "type": "NORMAL", "dmg": 12, "effect": "ANTI_TANK"},
		{"name": "Dark Void", "type": "DARK", "dmg": 0, "effect": "SLEEP"},
		{"name": "Seed Flare", "type": "GRASS", "dmg": 12, "effect": "BOOST_DMG"},
		{"name": "Judgment", "type": "NORMAL", "dmg": 16, "effect": "DOUBLE_DMG"},
		{"name": "Head Smash", "type": "GROUND", "dmg": 14, "effect": "RECOIL"},
		{"name": "Chatter", "type": "NORMAL", "dmg": 6, "effect": "CONFUSION"},
		{"name": "Attack Order", "type": "DARK", "dmg": 8, "effect": "CRITICAL"},
		{"name": "Defend Order", "type": "DARK", "dmg": 0, "effect": "SHIELD"},
		{"name": "Leaf Storm", "type": "GRASS", "dmg": 14, "effect": "RECOIL"},
		{"name": "Energy Ball", "type": "GRASS", "dmg": 8, "effect": "BOOST_DMG"},
		{"name": "Ominous Wind", "type": "DARK", "dmg": 6, "effect": "BOOST_IF_FASTER"},
		{"name": "Vacuum Wave", "type": "FIGHTING", "dmg": 4, "effect": "BOOST_IF_FASTER"},
		{"name": "Magnet Bomb", "type": "GROUND", "dmg": 6, "effect": "BOOST_DMG"}
	]
	
	for m_info in sinnoh_moves_to_test:
		var m_key = m_info["name"].to_lower()
		var move_data = GameData.moves_catalog.get(m_key, null)
		assert(move_data != null, "Move '%s' should exist in moves_catalog" % m_info["name"])
		assert(move_data.get("type") == m_info["type"], "Move '%s' type mismatch: got %s" % [m_info["name"], move_data.get("type")])
		assert(int(move_data.get("dmg", 0)) == m_info["dmg"], "Move '%s' damage mismatch" % m_info["name"])
		assert(str(move_data.get("effect_type", "")) == m_info["effect"], "Move '%s' effect mismatch" % m_info["name"])
	print("✅ All 17 new Sinnoh moves validated in moves_catalog!")
	
	# 4. Check Sinnoh Starters and Key Pokémon Instances
	var sinnoh_samples = [
		{"id": 392, "name": "Turtwig", "stage": "Basic", "hp": 12, "energy": 3, "moves": ["Tackle", "Razor Leaf"]},
		{"id": 393, "name": "Grotle", "stage": "Stage 1", "hp": 24, "energy": 5, "moves": ["Bite", "Mega Drain"]},
		{"id": 394, "name": "Torterra", "stage": "Stage 2", "hp": 36, "energy": 8, "moves": ["Earthquake", "Wood Hammer"]},
		{"id": 395, "name": "Chimchar", "stage": "Basic", "hp": 10, "energy": 3, "moves": ["Scratch", "Ember"]},
		{"id": 396, "name": "Monferno", "stage": "Stage 1", "hp": 22, "energy": 5, "moves": ["Double Kick", "Flame Wheel"]},
		{"id": 397, "name": "Infernape", "stage": "Stage 2", "hp": 32, "energy": 8, "moves": ["Close Combat", "Flare Blitz"]},
		{"id": 398, "name": "Piplup", "stage": "Basic", "hp": 10, "energy": 3, "moves": ["Pound", "Water Gun"]},
		{"id": 399, "name": "Prinplup", "stage": "Stage 1", "hp": 22, "energy": 5, "moves": ["Metal Claw", "Bubble Beam"]},
		{"id": 400, "name": "Empoleon", "stage": "Stage 2", "hp": 34, "energy": 8, "moves": ["Flash Cannon", "Hydro Pump"]},
		{"id": 403, "name": "Staraptor", "stage": "Stage 2", "hp": 30, "energy": 8, "moves": ["Close Combat", "Brave Bird"]},
		{"id": 412, "name": "Roserade", "stage": "Stage 2", "hp": 30, "energy": 8, "moves": ["Giga Drain", "Petal Blizzard"]},
		{"id": 421, "name": "Vespiquen", "stage": "Stage 1", "hp": 28, "energy": 6, "moves": ["Attack Order", "Defend Order"]},
		{"id": 424, "name": "Floatzel", "stage": "Stage 1", "hp": 24, "energy": 6, "moves": ["Aqua Jet", "Crunch"]},
		{"id": 449, "name": "Garchomp", "stage": "Stage 2", "hp": 36, "energy": 8, "moves": ["Earthquake", "Draco Meteor"]},
		{"id": 452, "name": "Lucario", "stage": "Stage 1", "hp": 28, "energy": 6, "moves": ["Bullet Punch", "Aura Sphere"]},
		{"id": 456, "name": "Drapion", "stage": "Stage 1", "hp": 28, "energy": 6, "moves": ["Cross Poison", "Night Slash"]},
		{"id": 458, "name": "Toxicroak", "stage": "Stage 1", "hp": 26, "energy": 6, "moves": ["Poison Jab", "Drain Punch"]},
		{"id": 482, "name": "Dialga", "stage": "Legendary", "hp": 36, "energy": 10, "passive": "Pressure", "moves": ["Dragon Pulse", "Roar of Time"]},
		{"id": 483, "name": "Palkia", "stage": "Legendary", "hp": 36, "energy": 10, "passive": "Pressure", "moves": ["Dragon Pulse", "Spacial Rend"]},
		{"id": 486, "name": "Giratina", "stage": "Legendary", "hp": 38, "energy": 10, "passive": "Pressure", "moves": ["Dragon Claw", "Shadow Force"]},
		{"id": 487, "name": "Cresselia", "stage": "Legendary", "hp": 36, "energy": 10, "passive": "Levitate", "moves": ["Psychic", "Calm Mind"]},
		{"id": 490, "name": "Darkrai", "stage": "Legendary", "hp": 32, "energy": 10, "passive": "Bad Dreams", "moves": ["Dark Pulse", "Dark Void"]},
		{"id": 491, "name": "Shaymin", "stage": "Legendary", "hp": 32, "energy": 10, "passive": "Natural Cure", "moves": ["Energy Ball", "Seed Flare"]},
		{"id": 492, "name": "Arceus", "stage": "Legendary", "hp": 42, "energy": 10, "passive": "Multitype", "moves": ["Hyper Beam", "Judgment"]}
	]
	
	for s in sinnoh_samples:
		var inst = GameData.create_pokemon_instance(s["id"])
		assert(inst != null, "Pokemon #%d (%s) instance should exist" % [s["id"], s["name"]])
		assert(inst.name == s["name"], "Name mismatch: %s vs %s" % [inst.name, s["name"]])
		assert(inst.max_hp == s["hp"], "HP mismatch for %s: got %d, expected %d" % [inst.name, inst.max_hp, s["hp"]])
		assert(inst.max_energy == s["energy"], "Energy mismatch for %s: got %d, expected %d" % [inst.name, inst.max_energy, s["energy"]])
		if s.has("passive"):
			assert(inst.has_passive and inst.passive_name == s["passive"], "Passive mismatch for %s: got '%s', expected '%s'" % [inst.name, inst.passive_name, s["passive"]])
		if s.has("moves"):
			var inst_move_names = []
			for m in inst.moves:
				inst_move_names.append(m.name)
			for req_m in s["moves"]:
				assert(req_m in inst_move_names, "Missing move '%s' on %s (has: %s)" % [req_m, inst.name, str(inst_move_names)])
	print("✅ Key Sinnoh Pokémon instances validated with correct stats, passives, and movesets!")
	
	# 5. Test Sinnoh Booster Pack Opening
	GameData.player_diamonds = 100
	var cards: Array[Dictionary] = GameData.open_booster_pack("sinnoh")
	assert(cards.size() == 3, "Sinnoh booster pack should give 3 cards")
	print("✅ Sinnoh booster pack opened successfully! Received cards:")
	for c in cards:
		print("  - #%s %s (%s, %s)" % [c.get("pokedex_num"), c.get("name"), c.get("type"), c.get("rarity")])
		assert(c.get("region") == "Sinnoh", "Card from Sinnoh pack must have region == Sinnoh")
	
	print("🎉 ALL SINNOH POKEMON AND MOVES TESTS PASSED SUCCESSFULLY!")
	get_tree().quit(0)
