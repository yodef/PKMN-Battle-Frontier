extends Node

func _ready() -> void:
	print("=== STARTING CHAOS ODYSSEY & CRYSTAL ONIX BOSS TEST SUITE ===")
	
	test_crystal_onix_and_moves()
	test_boss_diamond_rewards_formula()
	test_chaos_match_info()
	test_chaos_rival_team_generation()
	test_chaos_legendary_candidates()
	test_daily_limit_and_reset()
	test_save_load_serialization()
	
	print("\n=== ALL CHAOS ODYSSEY TESTS PASSED SUCCESSFULLY! ===")
	get_tree().quit(0)

func test_crystal_onix_and_moves() -> void:
	print("\n--- Testing Crystal Onix Boss & Custom Moves ---")
	var onix_id = GameData.CRYSTAL_ONIX_ID
	assert(onix_id == 493, "Crystal Onix ID must be 493!")
	var data = GameData.pokemon_catalog.get(onix_id, {})
	assert(not data.is_empty(), "Crystal Onix must exist in pokemon_catalog!")
	assert(data.get("name") == "Crystal Onix", "Name must be Crystal Onix!")
	assert(int(data.get("hp")) == 900, "HP must be 900! Got: %d" % int(data.get("hp")))
	assert(int(data.get("energy")) == 8, "Energy must be 8! Got: %d" % int(data.get("energy")))
	assert(int(data.get("recover")) == 4, "Recover must be 4! Got: %d" % int(data.get("recover")))
	assert(int(data.get("speed")) == 3, "Speed must be 3! Got: %d" % int(data.get("speed")))
	assert(str(data.get("type")) == "ROCK", "Type must be ROCK! Got: %s" % str(data.get("type")))
	assert(str(data.get("weakness")) == "NONE", "Weakness must be NONE! Got: %s" % str(data.get("weakness")))
	assert(str(data.get("resistant")) == "WATER", "Resistance must be WATER! Got: %s" % str(data.get("resistant")))
	assert(str(data.get("passive_name")) == "Diamond Hoard", "Passive must be Diamond Hoard!")
	
	var moves = [str(data.get("m1_name")), str(data.get("m2_name"))]
	assert("Rock Slide" in moves, "Must have Rock Slide! Got: %s" % str(moves))
	assert("Crystal Blast" in moves, "Must have Crystal Blast! Got: %s" % str(moves))
	
	var m = GameData.get_move_data("Crystal Blast")
	assert(not m.is_empty(), "Move Crystal Blast must exist in moves_catalog!")
	assert(str(m.get("name")) == "Crystal Blast", "Move name must be Crystal Blast!")
	assert(int(m["dmg"]) == 10, "Crystal Blast base damage must be 10!")
	assert(int(m["cost"]) == 2, "Crystal Blast cost must be 2!")
	assert(int(m["req"]) == 2, "Crystal Blast min energy must be 2!")
	assert(str(m["type"]) == "NORMAL", "Crystal Blast type must be NORMAL!")
	print("✓ Crystal Onix stats (900 HP, 8 NRG, 4 REC, 3 SPD) and Crystal Blast move verified!")

func test_boss_diamond_rewards_formula() -> void:
	print("\n--- Testing Boss Diamond Formula ---")
	var battle_script = preload("res://scripts/battle.gd")
	var battle_dummy = Control.new()
	battle_dummy.set_script(battle_script)
	
	assert(battle_dummy.get_boss_diamond_rewards_for_damage(0) == 0, "0 DMG -> 0 Diamonds")
	assert(battle_dummy.get_boss_diamond_rewards_for_damage(9) == 0, "9 DMG -> 0 Diamonds")
	assert(battle_dummy.get_boss_diamond_rewards_for_damage(10) == 1, "10 DMG -> 1 Diamond")
	assert(battle_dummy.get_boss_diamond_rewards_for_damage(50) == 5, "50 DMG -> 5 Diamonds")
	assert(battle_dummy.get_boss_diamond_rewards_for_damage(99) == 9, "99 DMG -> 9 Diamonds")
	assert(battle_dummy.get_boss_diamond_rewards_for_damage(100) == 20, "100 DMG -> 20 Diamonds (10+10)")
	assert(battle_dummy.get_boss_diamond_rewards_for_damage(200) == 40, "200 DMG -> 40 Diamonds (20+20)")
	assert(battle_dummy.get_boss_diamond_rewards_for_damage(499) == 89, "499 DMG -> 89 Diamonds (49+40)")
	assert(battle_dummy.get_boss_diamond_rewards_for_damage(500) == 150, "500 DMG -> 150 Diamonds (50+50+50)")
	assert(battle_dummy.get_boss_diamond_rewards_for_damage(900) == 230, "900 DMG -> 230 Diamonds (90+90+50)")
	
	battle_dummy.free()
	print("✓ Diamond calculation formula rigorously verified across all damage tiers!")

func test_chaos_match_info() -> void:
	print("\n--- Testing Chaos Match Info Configuration ---")
	assert(GameData.CHAOS_TOTAL_MATCHES == 7, "Total matches in Chaos Odyssey must be 7!")
	
	var m1 = GameData.get_chaos_match_info(1)
	assert(m1["super_potions"] == 0, "Match 1 must have 0 super potions")
	assert(m1["is_boss"] == false, "Match 1 is not boss")
	assert(m1["reward_gold"] == 30, "Match 1 gold is 30")
	
	var m2 = GameData.get_chaos_match_info(2)
	assert(m2["super_potions"] == 0, "Match 2 must have 0 super potions")
	assert(m2["is_boss"] == false, "Match 2 is not boss")
	assert(m2["reward_gold"] == 50, "Match 2 gold is 50")
	
	var m3 = GameData.get_chaos_match_info(3)
	assert(m3["super_potions"] == 0, "Match 3 must have 0 super potions")
	assert(m3["is_boss"] == false, "Match 3 is not boss")
	assert(m3["reward_gold"] == 75, "Match 3 gold is 75")
	
	var m4 = GameData.get_chaos_match_info(4)
	assert(m4["super_potions"] == 1, "Match 4 must have 1 super potion")
	assert(m4["is_boss"] == false, "Match 4 is not boss")
	assert(m4["reward_gold"] == 100, "Match 4 gold is 100")
	
	var m5 = GameData.get_chaos_match_info(5)
	assert(m5["super_potions"] == 1, "Match 5 must have 1 super potion")
	assert(m5["is_boss"] == false, "Match 5 is not boss")
	assert(m5["reward_gold"] == 130, "Match 5 gold is 130")
	
	var m6 = GameData.get_chaos_match_info(6)
	assert(m6["super_potions"] == 1, "Match 6 must have 1 super potion")
	assert(m6["is_boss"] == false, "Match 6 is not boss")
	assert(m6["reward_gold"] == 175, "Match 6 gold is 175")
	
	var m7 = GameData.get_chaos_match_info(7)
	assert(m7["super_potions"] == 1, "Match 7 must have 1 super potion")
	assert(m7["is_boss"] == true, "Match 7 must be Boss fight")
	assert(m7["reward_gold"] == 0, "Match 7 (Boss) gives 0 gold!")
	print("✓ All 7 Chaos match configurations verified!")

func test_chaos_rival_team_generation() -> void:
	print("\n--- Testing Rival Team Generation for Trials 1-7 (50 runs each) ---")
	for rep in range(50):
		# Match 1: 2 Basics high tier
		var t1 = GameData.generate_chaos_rival_team(1)
		assert(t1.size() == 2, "Match 1 must have 2 Pokémon")
		assert(t1[0] != t1[1], "Match 1 Pokémon must be unique")
		for pid in t1:
			var d = GameData.pokemon_catalog[pid]
			assert(str(d.get("stage", "")).to_lower() == "basic", "M1 must be Basic")
			assert(str(d.get("tier", "")).to_upper() in ["S", "A"], "M1 must be High Tier (A/S)")
		
		# Match 2: 2 Stage 1 + 1 Basic high tier
		var t2 = GameData.generate_chaos_rival_team(2)
		assert(t2.size() == 3, "Match 2 must have 3 Pokémon")
		var s1_count = 0
		var b_high_count = 0
		for pid in t2:
			var d = GameData.pokemon_catalog[pid]
			var st = str(d.get("stage", "")).to_lower()
			var tr = str(d.get("tier", "")).to_upper()
			if st == "stage 1":
				s1_count += 1
			elif st == "basic" and tr in ["S", "A"]:
				b_high_count += 1
		assert(s1_count == 2, "M2 must have 2 Stage 1")
		assert(b_high_count == 1, "M2 must have 1 High Tier Basic")
		
		# Match 3: 2 Stage 2
		var t3 = GameData.generate_chaos_rival_team(3)
		assert(t3.size() == 2, "Match 3 must have 2 Pokémon")
		assert(t3[0] != t3[1], "M3 Pokémon must be unique")
		for pid in t3:
			var d = GameData.pokemon_catalog[pid]
			assert(str(d.get("stage", "")).to_lower() == "stage 2", "M3 must be Stage 2")
		
		# Match 4: 1 Basic high tier + 1 Legendary
		var t4 = GameData.generate_chaos_rival_team(4)
		assert(t4.size() == 2, "Match 4 must have 2 Pokémon")
		var leg_count = 0
		var b_count = 0
		for pid in t4:
			var d = GameData.pokemon_catalog[pid]
			var st = str(d.get("stage", "")).to_lower()
			var tr = str(d.get("tier", "")).to_upper()
			var r = str(d.get("rarity", "")).to_lower()
			var is_leg = (r in ["legendary", "legendaria", "legendario", "ur", "ultra rare"]) or (st == "legendary")
			if is_leg:
				leg_count += 1
			elif st == "basic" and tr in ["S", "A"]:
				b_count += 1
		assert(leg_count == 1, "M4 must have 1 Legendary")
		assert(b_count == 1, "M4 must have 1 High Tier Basic")
		
		# Match 5: 1 Stage 1, 1 Stage 2, 1 Legendary
		var t5 = GameData.generate_chaos_rival_team(5)
		assert(t5.size() == 3, "Match 5 must have 3 Pokémon")
		var m5_s1 = 0
		var m5_s2 = 0
		var m5_leg = 0
		for pid in t5:
			var d = GameData.pokemon_catalog[pid]
			var st = str(d.get("stage", "")).to_lower()
			var r = str(d.get("rarity", "")).to_lower()
			var is_leg = (r in ["legendary", "legendaria", "legendario", "ur", "ultra rare"]) or (st == "legendary")
			if is_leg:
				m5_leg += 1
			elif st == "stage 1":
				m5_s1 += 1
			elif st == "stage 2":
				m5_s2 += 1
		assert(m5_leg == 1, "M5 must have 1 Legendary")
		assert(m5_s1 == 1, "M5 must have 1 Stage 1")
		assert(m5_s2 == 1, "M5 must have 1 Stage 2")
		
		# Match 6: 2 Legendaries
		var t6 = GameData.generate_chaos_rival_team(6)
		assert(t6.size() == 2, "Match 6 must have 2 Pokémon")
		assert(t6[0] != t6[1], "M6 legendaries must be unique")
		for pid in t6:
			var d = GameData.pokemon_catalog[pid]
			var st = str(d.get("stage", "")).to_lower()
			var r = str(d.get("rarity", "")).to_lower()
			var is_leg = (r in ["legendary", "legendaria", "legendario", "ur", "ultra rare"]) or (st == "legendary")
			assert(is_leg, "M6 must be Legendary")
			
		# Match 7: Final Boss Crystal Onix
		var t7 = GameData.generate_chaos_rival_team(7)
		assert(t7.size() == 1, "Match 7 must have exactly 1 Pokémon")
		assert(t7[0] == GameData.CRYSTAL_ONIX_ID, "Match 7 must be Crystal Onix (493)!")
	print("✓ Rival teams across all 7 trials successfully generated and validated!")

func test_chaos_legendary_candidates() -> void:
	print("\n--- Testing Legendary & Pseudo-Legendary Filtering ---")
	assert(GameData.is_line_legendary(162), "Dratini (162) must be line legendary!")
	assert(GameData.is_line_legendary(251), "Larvitar (251) must be line legendary!")
	assert(GameData.is_line_legendary(376), "Bagon (376) must be line legendary!")
	assert(GameData.is_line_legendary(379), "Beldum (379) must be line legendary!")
	assert(GameData.is_line_legendary(447), "Gible (447) must be line legendary!")
	assert(not GameData.is_line_legendary(0), "Bulbasaur (0) is NOT line legendary")
	assert(not GameData.is_line_legendary(16), "Pidgey (16) is NOT line legendary")
	assert(not GameData.is_line_legendary(94), "Onix (94) is NOT line legendary")
	
	var leg_candidates = GameData.get_chaos_legendary_candidates()
	assert(leg_candidates.size() > 0, "Chaos legendary candidates must not be empty!")
	assert(not (162 in leg_candidates), "Dratini must NOT be in pure legendary rival pool")
	assert(not (GameData.CRYSTAL_ONIX_ID in leg_candidates), "Crystal Onix (Boss) must NOT be in rival legendary pool!")
	
	var draft_candidates = GameData.get_chaos_player_draft_candidates()
	assert(162 in draft_candidates, "Dratini must be in player draft candidates")
	assert(251 in draft_candidates, "Larvitar must be in player draft candidates")
	assert(376 in draft_candidates, "Bagon must be in player draft candidates")
	assert(379 in draft_candidates, "Beldum must be in player draft candidates")
	assert(447 in draft_candidates, "Gible must be in player draft candidates")
	assert(not (0 in draft_candidates), "Bulbasaur must NOT be in candidates")
	assert(not (GameData.CRYSTAL_ONIX_ID in draft_candidates), "Crystal Onix (Boss) must NOT be in player draft candidates!")
	print("✓ Chaos legendary selection candidates correctly curated!")

func test_daily_limit_and_reset() -> void:
	print("\n--- Testing Daily Limit & Mode Reset ---")
	var today = Time.get_date_string_from_system()
	GameData.chaos_last_played_date = ""
	assert(GameData.can_play_chaos_odyssey_today() == true, "Empty date must be allowed to play")
	
	GameData.chaos_last_played_date = "2020-01-01"
	assert(GameData.can_play_chaos_odyssey_today() == true, "Old date must be allowed to play")
	
	GameData.chaos_last_played_date = today
	assert(GameData.can_play_chaos_odyssey_today() == false, "Today date must be blocked by daily limit")
	
	GameData.chaos_match_number = 5
	GameData.chaos_player_team_state = [{"id": 149, "current_hp": 30}]
	GameData.chaos_inventory = {"potion": 2}
	GameData.reset_chaos_odyssey()
	assert(GameData.chaos_match_number == 1, "Reset must set match number to 1")
	assert(GameData.chaos_player_team_state.is_empty(), "Reset must clear team")
	assert(GameData.chaos_inventory == GameData.DEFAULT_INVENTORY, "Reset must restore default inventory")
	print("✓ Daily limit & Odyssey reset work accurately!")

func test_save_load_serialization() -> void:
	print("\n--- Testing Save/Load Serialization ---")
	GameData.chaos_boss_damage_record = 450
	GameData.chaos_last_played_date = "2026-11-09"
	GameData.chaos_match_number = 4
	
	var save_dict = GameData.get_save_dict()
	assert(save_dict.has("chaos_odyssey"), "Save dict must have chaos_odyssey!")
	var c_dict = save_dict["chaos_odyssey"]
	assert(c_dict["boss_damage_record"] == 450, "Serialized boss record must be 450")
	assert(c_dict["last_played_date"] == "2026-11-09", "Serialized date must match")
	assert(c_dict["match_number"] == 4, "Serialized match must be 4")
	
	# Alter values and apply
	GameData.chaos_boss_damage_record = 0
	GameData.chaos_last_played_date = ""
	GameData.chaos_match_number = 1
	GameData.apply_save_dict(save_dict)
	
	assert(GameData.chaos_boss_damage_record == 450, "Restored boss record must be 450")
	assert(GameData.chaos_last_played_date == "2026-11-09", "Restored date must match")
	assert(GameData.chaos_match_number == 4, "Restored match must be 4")
	print("✓ Chaos Odyssey profile serialization and deserialization verified!")
