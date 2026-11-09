extends Node

func _ready() -> void:
	print("=== STARTING STADIUM PHASE 1 TIER & RIVAL RESTRICTION TESTS ===")
	
	test_phase_1_match_1()
	test_phase_1_match_2()
	test_phase_1_match_3()
	test_banned_high_tier_basics_in_phase_1()
	test_full_tournament_progression()
	
	print("\n=== ALL STADIUM TIER TESTS PASSED SUCCESSFULLY! ===")
	get_tree().quit(0)

func test_phase_1_match_1() -> void:
	print("\n--- Testing Match 1 (Phase 1 Warmup) Rivals (100 runs) ---")
	for i in range(100):
		var team = GameData.generate_tournament_rival_team(1)
		assert(team.size() == 1, "Match 1 must have exactly 1 rival pokemon!")
		var id = team[0]
		var data = GameData.pokemon_catalog.get(id, {})
		var stage = str(data.get("stage", "")).strip_edges().to_lower()
		var tier = str(data.get("tier", "")).strip_edges().to_upper()
		assert(stage == "basic", "Match 1 rival must be Basic! Got: " + stage + " (" + str(data.get("name")) + ")")
		assert(tier == "D", "Match 1 rival must be strictly Tier D! Got: " + tier + " (" + str(data.get("name")) + ")")
	print("✓ Match 1: 100/100 runs strictly Tier D Basic Pokémon!")

func test_phase_1_match_2() -> void:
	print("\n--- Testing Match 2 (Phase 1 Skirmish) Rivals (100 runs) ---")
	for i in range(100):
		var team = GameData.generate_tournament_rival_team(2)
		assert(team.size() == 2, "Match 2 must have exactly 2 rival pokemon!")
		assert(team[0] != team[1], "Match 2 rivals must be unique!")
		for id in team:
			var data = GameData.pokemon_catalog.get(id, {})
			var stage = str(data.get("stage", "")).strip_edges().to_lower()
			var tier = str(data.get("tier", "")).strip_edges().to_upper()
			assert(stage == "basic", "Match 2 rival must be Basic! Got: " + stage + " (" + str(data.get("name")) + ")")
			assert(tier == "D", "Match 2 rival must be strictly Tier D! Got: " + tier + " (" + str(data.get("name")) + ")")
	print("✓ Match 2: 100/100 runs strictly Tier D Basic Pokémon!")

func test_phase_1_match_3() -> void:
	print("\n--- Testing Match 3 (Phase 1 Finale) Rivals (100 runs) ---")
	for i in range(100):
		var team = GameData.generate_tournament_rival_team(3)
		assert(team.size() == 2, "Match 3 must have exactly 2 rival pokemon!")
		assert(team[0] != team[1], "Match 3 rivals must be unique!")
		
		var basic_id = team[0]
		var s1_id = team[1]
		
		var b_data = GameData.pokemon_catalog.get(basic_id, {})
		var b_stage = str(b_data.get("stage", "")).strip_edges().to_lower()
		var b_tier = str(b_data.get("tier", "")).strip_edges().to_upper()
		assert(b_stage == "basic", "Match 3 first rival must be Basic! Got: " + b_stage)
		assert(b_tier == "D", "Match 3 basic must be strictly Tier D! Got: " + b_tier + " (" + str(b_data.get("name")) + ")")
		
		var s1_data = GameData.pokemon_catalog.get(s1_id, {})
		var s1_stage = str(s1_data.get("stage", "")).strip_edges().to_lower()
		var s1_tier = str(s1_data.get("tier", "")).strip_edges().to_upper()
		assert(s1_stage == "stage 1", "Match 3 second rival must be Stage 1! Got: " + s1_stage)
		assert(s1_tier in ["D", "C"], "Match 3 Stage 1 must be Tier D or C! Got: " + s1_tier + " (" + str(s1_data.get("name")) + ")")
	print("✓ Match 3: 100/100 runs composed of 1 Tier D Basic + 1 Tier D/C Stage 1!")

func test_banned_high_tier_basics_in_phase_1() -> void:
	print("\n--- Testing That Overpowered / Elevated Basics Never Appear in Phase 1 ---")
	var banned_ids = [
		132, # Scyther (Tier A)
		152, # Porygon (Tier A)
		214, # Girafarig (Tier A)
		224, # Sneasel (Tier A)
		242, # Stantler (Tier A)
		357, # Kecleon (Tier A)
		99,  # Onix (Tier B)
		113, # Lickitung (Tier B)
		218, # Gligar (Tier B)
		221, # Qwilfish (Tier B)
		231, # Corsola (Tier B)
		332, # Spinda (Tier B)
		356, # Castform (Tier B)
		459, # Carnivine (Tier B)
		153, # Omanyte (Tier C)
		155, # Kabuto (Tier C)
		376, # Bagon (Tier C)
		379, # Beldum (Tier C)
		413, # Cranidos (Tier C)
		447  # Gible (Tier C)
	]
	
	for m in [1, 2, 3]:
		for run in range(100):
			var team = GameData.generate_tournament_rival_team(m)
			for id in team:
				assert(not (id in banned_ids), "Banned high-tier basic ID %d (%s) appeared in Phase 1 Match %d!" % [
					id,
					GameData.pokemon_catalog.get(id, {}).get("name", "Unknown"),
					m
				])
	print("✓ None of the 20 monitored high-tier/powerhouse basics appeared across 300 Phase 1 team generations!")

func test_full_tournament_progression() -> void:
	print("\n--- Testing Full Tournament Progression Across All 9 Matches (50 runs) ---")
	for m in range(1, 10):
		for run in range(50):
			var team = GameData.generate_tournament_rival_team(m)
			assert(team.size() > 0, "Match %d cannot be empty" % m)
			for id in team:
				var data = GameData.pokemon_catalog.get(id, {})
				var tier = str(data.get("tier", "")).strip_edges().to_upper()
				var r = str(data.get("rarity", "")).strip_edges().to_lower()
				var st = str(data.get("stage", "")).strip_edges().to_lower()
				assert(not (tier in ["S", "S+", "SS"]), "Match %d had illegal tier %s!" % [m, tier])
				assert(not (r in ["legendary", "legendaria", "ur"]), "Match %d had legendary!" % m)
				assert(st != "legendary", "Match %d had legendary stage!" % m)
	print("✓ Full 9-match progression cleanly obeys all stage, tier, and non-legendary constraints!")
