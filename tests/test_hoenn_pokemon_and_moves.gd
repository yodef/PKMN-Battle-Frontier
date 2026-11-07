extends Node

func _ready():
	print("=== TEST: Hoenn Pokémon & Moves Verification ===")
	
	# 1. Total Pokémon loaded in catalog
	var all_p = GameData.pokemon_catalog
	print("Total Pokémon loaded: ", all_p.size())
	assert(all_p.size() >= 392, "Expected at least 392 Pokemon, got " + str(all_p.size()))
	
	# 2. Check Hoenn moves
	var new_moves_to_test = [
		{"name": "Blaze Kick", "type": "FIRE", "dmg": 10, "effect": "CRITICAL"},
		{"name": "Sky Uppercut", "type": "FIGHTING", "dmg": 8, "effect": "BOOST_IF_FASTER"},
		{"name": "Dragon Claw", "type": "NORMAL", "dmg": 8, "effect": "CRITICAL"},
		{"name": "Meteor Mash", "type": "GROUND", "dmg": 12, "effect": "BOOST_DMG"},
		{"name": "Doom Desire", "type": "GROUND", "dmg": 14, "effect": "SHIELD_BREAKER"},
		{"name": "Psycho Boost", "type": "PSYCHIC", "dmg": 14, "effect": "RECOIL"},
		{"name": "Water Spout", "type": "WATER", "dmg": 12, "effect": "BOOST_DMG"},
		{"name": "Eruption", "type": "FIRE", "dmg": 12, "effect": "BOOST_DMG"},
		{"name": "Needle Arm", "type": "GRASS", "dmg": 6, "effect": "FLINCH"},
		{"name": "Crush Claw", "type": "NORMAL", "dmg": 8, "effect": "CRITICAL"},
		{"name": "Poison Tail", "type": "DARK", "dmg": 6, "effect": "POISON"},
		{"name": "Shadow Sneak", "type": "DARK", "dmg": 4, "effect": "BOOST_IF_FASTER"},
		{"name": "Shadow Claw", "type": "DARK", "dmg": 8, "effect": "CRITICAL"},
		{"name": "Arm Thrust", "type": "FIGHTING", "dmg": 3, "effect": "MULTI_ATTACK"},
		{"name": "Fake Out", "type": "NORMAL", "dmg": 4, "effect": "FLINCH"},
		{"name": "Knock Off", "type": "DARK", "dmg": 6, "effect": "BOOST_DMG"},
		{"name": "Night Slash", "type": "DARK", "dmg": 8, "effect": "CRITICAL"},
		{"name": "Silver Wind", "type": "GRASS", "dmg": 6, "effect": "BOOST_IF_FASTER"},
		{"name": "Weather Ball", "type": "NORMAL", "dmg": 6, "effect": "BOOST_DMG"},
		{"name": "Astonish", "type": "DARK", "dmg": 4, "effect": "FLINCH"},
		{"name": "Bounce", "type": "WATER", "dmg": 8, "effect": "PARALYZE"},
		{"name": "Spore", "type": "GRASS", "dmg": 0, "effect": "SLEEP"},
		{"name": "Volt Tackle", "type": "ELECTRIC", "dmg": 12, "effect": "RECOIL"},
		{"name": "Teeter Dance", "type": "NORMAL", "dmg": 0, "effect": "CONFUSION"}
	]
	
	for m_info in new_moves_to_test:
		var m_key = m_info["name"].to_lower()
		var move_data = GameData.moves_catalog.get(m_key, null)
		assert(move_data != null, "Move '%s' should exist in moves_catalog" % m_info["name"])
		assert(move_data.get("type") == m_info["type"], "Move '%s' type mismatch" % m_info["name"])
		assert(int(move_data.get("dmg", 0)) == m_info["dmg"], "Move '%s' damage mismatch" % m_info["name"])
		assert(str(move_data.get("effect_type", "")) == m_info["effect"], "Move '%s' effect mismatch" % m_info["name"])
	print("✅ All checked Hoenn moves validated in moves_catalog!")
	
	# 3. Check Hoenn Starters and Key Pokémon Instances
	var hoenn_samples = [
		{"id": 257, "name": "Treecko", "stage": "Basic", "hp": 10, "energy": 3, "moves": ["Pound", "Mega Drain"]},
		{"id": 258, "name": "Grovyle", "stage": "Stage 1", "hp": 22, "energy": 5, "moves": ["Quick Attack", "Leaf Blade"]},
		{"id": 259, "name": "Sceptile", "stage": "Stage 2", "hp": 32, "energy": 8, "moves": ["Slam", "Leaf Blade"]},
		{"id": 260, "name": "Torchic", "stage": "Basic", "hp": 10, "energy": 3, "moves": ["Scratch", "Ember"]},
		{"id": 261, "name": "Combusken", "stage": "Stage 1", "hp": 22, "energy": 5, "moves": ["Double Kick", "Flame Wheel"]},
		{"id": 262, "name": "Blaziken", "stage": "Stage 2", "hp": 32, "energy": 8, "moves": ["Sky Uppercut", "Blaze Kick"]},
		{"id": 263, "name": "Mudkip", "stage": "Basic", "hp": 10, "energy": 3, "moves": ["Tackle", "Water Gun"]},
		{"id": 264, "name": "Marshtomp", "stage": "Stage 1", "hp": 24, "energy": 5, "moves": ["Mud Shot", "Water Pulse"]},
		{"id": 265, "name": "Swampert", "stage": "Stage 2", "hp": 36, "energy": 8, "moves": ["Earthquake", "Muddy Water"]},
		{"id": 297, "name": "Shedinja", "stage": "Stage 1", "hp": 1, "energy": 6, "passive": "Wonder Guard"},
		{"id": 294, "name": "Slaking", "stage": "Stage 2", "hp": 42, "energy": 8, "passive": "Truant"},
		{"id": 381, "name": "Metagross", "stage": "Stage 2", "hp": 36, "energy": 8, "passive": "Clear Body"},
		{"id": 387, "name": "Kyogre", "stage": "Legendary", "hp": 36, "energy": 10, "passive": "Drizzle"},
		{"id": 388, "name": "Groudon", "stage": "Legendary", "hp": 36, "energy": 10, "passive": "Drought"},
		{"id": 389, "name": "Rayquaza", "stage": "Legendary", "hp": 36, "energy": 10, "passive": "Air Lock"},
		{"id": 391, "name": "Deoxys", "stage": "Legendary", "hp": 30, "energy": 10, "passive": "Pressure"}
	]
	
	for s in hoenn_samples:
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
	print("✅ Key Hoenn Pokémon instances validated with correct stats, passives, and movesets!")
	
	# 4. Test Hoenn Booster Pack Opening
	GameData.player_diamonds = 100
	var cards: Array[Dictionary] = GameData.open_booster_pack("hoenn")
	assert(cards.size() == 3, "Hoenn booster pack should give 3 cards")
	print("✅ Hoenn booster pack opened successfully! Received cards:")
	for c in cards:
		print("  - #%s %s (%s, %s)" % [c.get("pokedex_num"), c.get("name"), c.get("type"), c.get("rarity")])
		assert(c.get("region") == "Hoenn", "Card from Hoenn pack must have region == Hoenn")
	
	print("🎉 ALL HOENN POKEMON AND MOVES TESTS PASSED SUCCESSFULLY!")
	get_tree().quit(0)
