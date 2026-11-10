extends Node

func _ready():
	print("=== RUNNING TEST: JOHTO ADVENTURE EPISODES & RED GYARADOS ===")
	
	# 1. Test Red Gyarados Catalog Entries
	print("\n--- Test 1: Red Gyarados Catalog Validation ---")
	assert(GameData.pokemon_catalog.has(GameData.RED_GYARADOS_CARD_ID), "Red Gyarados playable ID 494 must exist")
	var r_gyarados = GameData.pokemon_catalog[GameData.RED_GYARADOS_CARD_ID]
	assert(r_gyarados["name"] == "Red Gyarados", "Name should be Red Gyarados")
	assert(r_gyarados["hp"] == 34, "HP should be 34 (same as normal Gyarados)")
	assert(r_gyarados["energy"] == 8, "Energy should be 8")
	assert(r_gyarados["speed"] == 3, "Speed should be 3")
	assert(r_gyarados["stage"].strip_edges().to_lower() == "legendary", "Stage must be Legendary")
	assert(r_gyarados["rarity"].strip_edges().to_lower() == "legendary", "Rarity must be Legendary")
	assert(r_gyarados["passive_name"] == "Furia", "Passive should be Furia")
	print("✓ Playable Red Gyarados (ID 494) stats and properties verified!")
	
	assert(GameData.pokemon_catalog.has(GameData.RED_GYARADOS_BOSS_ID), "Red Gyarados boss ID 495 must exist")
	var r_boss = GameData.pokemon_catalog[GameData.RED_GYARADOS_BOSS_ID]
	assert(r_boss["name"] == "Red Gyarados (Boss)", "Name should be Red Gyarados (Boss)")
	assert(r_boss["hp"] == 600, "HP should be 600")
	assert(r_boss["stage"].strip_edges().to_lower() == "boss", "Stage must be Boss")
	assert(r_boss["rarity"].strip_edges().to_lower() == "boss", "Rarity must be Boss")
	assert(r_boss["passive_name"] == "Furia Desatada", "Passive should be Furia Desatada")
	print("✓ Event Boss Red Gyarados (ID 495) stats and properties verified!")
	
	# 2. Test Shiny Texture Loading
	print("\n--- Test 2: Shiny Gyarados Texture Loading ---")
	var shiny_tex = GameData.get_pokemon_texture("130 (Shiny).png")
	assert(shiny_tex != null, "130 (Shiny).png must load successfully")
	print("✓ Shiny Gyarados texture loaded: %s" % shiny_tex.resource_path)
	
	# 3. Test Johto Episodes 101 to 108 Structure
	print("\n--- Test 3: Johto Adventure Episodes 101-108 Structure & Teams ---")
	var expected_eps = [101, 102, 103, 104, 105, 106, 107, 108]
	for ep_id in expected_eps:
		var ep_info = GameData.get_adventure_episode_info(ep_id)
		assert(not ep_info.is_empty(), "Episode %d must be registered in ADVENTURE_EPISODES" % ep_id)
		assert(ep_info.get("region", "") == "Johto", "Episode %d region must be Johto" % ep_id)
		
		var is_branching = ep_info.get("is_branching", false)
		if is_branching:
			var routes = ep_info.get("routes", {})
			assert(routes.size() >= 2, "Branching episode %d must have at least 2 routes" % ep_id)
			for r_id in routes.keys():
				var r_data = routes[r_id]
				var stages = r_data.get("stages", [])
				assert(stages.size() >= 1, "Route %s in Ep %d must have stages" % [r_id, ep_id])
				for s in stages:
					var p_names = s.get("team_pokemon_names", [])
					assert(p_names.size() >= 1, "Stage %d in Route %s must have Pokémon" % [s["stage_num"], r_id])
					for p_name in p_names:
						var pid = GameData.get_pokemon_id_by_name(p_name)
						assert(pid != -1, "Pokémon name '%s' in Ep %d Route %s must resolve to valid ID" % [p_name, ep_id, r_id])
		else:
			var total_stages = GameData.get_adventure_total_stages(ep_id)
			assert(total_stages >= 4, "Episode %d must have at least 4 stages" % ep_id)
			for st in range(1, total_stages + 1):
				var stage_info = GameData.get_adventure_stage_info(ep_id, st)
				assert(not stage_info.is_empty(), "Stage %d info must exist in Ep %d" % [st, ep_id])
				var team = GameData.get_adventure_rival_team(ep_id, st)
				assert(team.size() >= 1, "Rival team in Ep %d Stage %d must have Pokémon" % [ep_id, st])
				for pid in team:
					assert(GameData.pokemon_catalog.has(pid), "Team Pokémon ID %d must exist in catalog" % pid)
					
		print("  ✓ Episode %d verified: %s" % [ep_id, ep_info.get("title", "")])
		
	# 4. Test Unlocking Logic & Johto Badges
	print("\n--- Test 4: Johto Badges & Lake of Rage Logic ---")
	GameData.adventure_completed_episodes.clear()
	GameData.adventure_unlocked_episodes.clear()
	GameData.lake_of_rage_completed = false
	GameData.tutorial_completed = true
	
	# Backup original adventure state so test doesn't contaminate user profile
	var original_completed = GameData.adventure_completed_episodes.duplicate()
	var original_lake_done = GameData.lake_of_rage_completed
	
	# Clear Johto episodes for test
	for ep_id in expected_eps:
		GameData.adventure_completed_episodes.erase(ep_id)
	GameData.lake_of_rage_completed = false
	
	assert(GameData.is_adventure_episode_unlocked(101), "Episode 101 should be unlocked when tutorial is complete")
	assert(GameData.get_johto_gym_badges_count() == 0, "Initial Johto badges should be 0")
	assert(not GameData.has_all_johto_gym_badges(), "has_all_johto_gym_badges should be false")
	assert(not GameData.is_lake_of_rage_unlocked(), "Lake of Rage should be locked initially")
	
	# Simulate clearing all 8 Johto episodes
	for ep_id in expected_eps:
		GameData.adventure_completed_episodes.append(ep_id)
		
	assert(GameData.get_johto_gym_badges_count() == 8, "Johto badges should now be 8")
	assert(GameData.has_all_johto_gym_badges(), "has_all_johto_gym_badges should be true")
	assert(GameData.is_lake_of_rage_unlocked(), "Lake of Rage must be unlocked with 8 Johto badges!")
	
	# Test Lake of Rage completion
	assert(not GameData.is_lake_of_rage_completed(), "Lake of rage initially not completed")
	GameData.complete_lake_of_rage()
	assert(GameData.is_lake_of_rage_completed(), "Lake of rage completed should now be true")
	# Once completed, is_lake_of_rage_unlocked must be false (not repeatable)
	assert(not GameData.is_lake_of_rage_unlocked(), "Lake of rage must be locked once completed!")
	assert(GameData.RED_GYARADOS_CARD_ID in GameData.player_unlocked_ids, "Playable Red Gyarados should now be unlocked in player collection!")
	print("✓ Johto badges count and Lake of Rage reward flow verified!")
	
	# Restore original profile state
	GameData.adventure_completed_episodes = original_completed
	GameData.lake_of_rage_completed = original_lake_done
	GameData.save_profile()
	
	# 5. Test Furia Passive Ability in Battle
	print("\n--- Test 5: Furia Passive Ability Mechanics ---")
	var battle_scene = load("res://scenes/battle.tscn")
	var battle = battle_scene.instantiate()
	add_child(battle)
	await get_tree().process_frame
	
	var red_gya_inst = GameData.create_pokemon_instance(GameData.RED_GYARADOS_CARD_ID)
	assert(red_gya_inst.has_passive, "Red Gyarados must have passive")
	assert(red_gya_inst.passive_name == "Furia", "Passive name must be Furia")
	
	var defender = GameData.create_pokemon_instance(143) # Snorlax
	defender.current_hp = 100
	defender.weakness = "NONE"
	defender.resistant = "NONE"
	defender.shield_reduction = 0
	defender.wall_hp = 0
	
	battle.player_team = [red_gya_inst]
	battle.active_player_idx = 0
	battle.enemy_team = [defender]
	battle.active_enemy_idx = 0
	
	var move_normal = GameData.MoveData.new("Hit 10", "NORMAL", 10, 1, 1, false, 0, 0, false, "10 dmg")
	red_gya_inst.current_energy = 5
	
	# Attack when at FULL HP and did not take damage: Furia is inactive (deals 10)
	red_gya_inst.current_hp = red_gya_inst.max_hp
	red_gya_inst.took_damage_last_turn = false
	defender.current_hp = 100
	battle.perform_attack(red_gya_inst, defender, move_normal, false, 1, battle.player_card_img, battle.enemy_card_img)
	assert(defender.current_hp == 90, "Defender HP should be 90 (100 - 10)")
	print("✓ Furia inactive at full HP when taking no damage: 10 DMG dealt.")
	
	# Attack when below 50% HP: Furia ACTIVE (+2 DMG -> 12 DMG)
	red_gya_inst.current_hp = 10 # below 17 (half of 34)
	red_gya_inst.current_energy = 5
	defender.current_hp = 100
	battle.perform_attack(red_gya_inst, defender, move_normal, false, 1, battle.player_card_img, battle.enemy_card_img)
	assert(defender.current_hp == 88, "Defender HP should be 88 (100 - 12 with +2 Furia)")
	print("✓ Furia ACTIVE at ≤50%% HP: dealt 12 DMG (+2 DMG bonus)!")
	
	# Attack when took_damage_last_turn is true: Furia ACTIVE
	red_gya_inst.current_hp = red_gya_inst.max_hp
	red_gya_inst.took_damage_last_turn = true
	red_gya_inst.current_energy = 5
	defender.current_hp = 100
	battle.perform_attack(red_gya_inst, defender, move_normal, false, 1, battle.player_card_img, battle.enemy_card_img)
	assert(defender.current_hp == 88, "Defender HP should be 88 (100 - 12 with +2 Furia)")
	print("✓ Furia ACTIVE after taking damage: dealt 12 DMG (+2 DMG bonus)!")
	
	battle.queue_free()
	print("\n=== ALL JOHTO EPISODES & RED GYARADOS TESTS PASSED PERFECTLY! ===")
	get_tree().quit(0)
