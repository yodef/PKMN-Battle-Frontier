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

	# 6. Test Standardized Diamond Rewards & Johto vs Kanto Balance
	print("\n--- Test 6: Standardized Diamond Rewards & Johto vs Kanto Difficulty Balance ---")
	var saved_diamonds = GameData.player_diamonds
	var saved_comp = GameData.adventure_completed_episodes.duplicate()
	var saved_unl = GameData.adventure_unlocked_episodes.duplicate()
	var saved_r106 = GameData.adventure_ep106_cleared_routes.duplicate()
	var saved_r107 = GameData.adventure_ep107_cleared_routes.duplicate()
	var saved_r108 = GameData.adventure_ep108_cleared_routes.duplicate()
	var saved_s106 = GameData.adventure_ep106_selected_route
	var saved_s107 = GameData.adventure_ep107_selected_route
	var saved_s108 = GameData.adventure_ep108_selected_route

	GameData.player_diamonds = 0
	for ep_id in expected_eps:
		GameData.adventure_completed_episodes.erase(ep_id)
	GameData.adventure_ep106_cleared_routes.clear()
	GameData.adventure_ep107_cleared_routes.clear()
	GameData.adventure_ep108_cleared_routes.clear()

	var expected_ep_rewards = {
		101: 15, 102: 20, 103: 20, 104: 25, 105: 25,
		106: 30, 107: 25, 108: 35
	}
	var expected_route_rewards = {
		106: {"subway": 10, "radio_tower": 10, "olivine_gym": 10},
		107: {"rocket_hideout": 10, "mahogany_gym": 15},
		108: {"ice_path": 10, "blackthorn_gym": 15, "dragon_den": 10}
	}

	var johto_stages_total = 0
	var johto_diamonds_total = 0
	for ep_id in expected_eps:
		var stg_count = GameData.get_adventure_episode_total_stages_all_routes(ep_id)
		var dia_total = GameData.get_adventure_episode_total_diamonds(ep_id)
		johto_stages_total += stg_count
		johto_diamonds_total += dia_total
		assert(dia_total == expected_ep_rewards[ep_id], "Ep %d total diamonds expected %d, got %d" % [ep_id, expected_ep_rewards[ep_id], dia_total])

		if expected_route_rewards.has(ep_id):
			for r_id in expected_route_rewards[ep_id].keys():
				GameData.set_adventure_selected_route(ep_id, r_id)
				var r_bonus = GameData.complete_adventure_episode(ep_id)
				assert(r_bonus == expected_route_rewards[ep_id][r_id], "Ep %d route %s expected %d, got %d" % [ep_id, r_id, expected_route_rewards[ep_id][r_id], r_bonus])
				assert(GameData.complete_adventure_episode(ep_id) == 0, "Replay of Ep %d route %s must yield 0" % [ep_id, r_id])
		else:
			var bonus = GameData.complete_adventure_episode(ep_id)
			assert(bonus == expected_ep_rewards[ep_id], "Ep %d completion expected %d, got %d" % [ep_id, expected_ep_rewards[ep_id], bonus])
			assert(GameData.complete_adventure_episode(ep_id) == 0, "Replay of Ep %d must yield 0" % ep_id)

	assert(johto_stages_total == 39, "Johto must have 39 total battles across Ep 101-108, got %d" % johto_stages_total)
	assert(johto_diamonds_total == 195, "Johto Ep 101-108 total diamonds must be 195, got %d" % johto_diamonds_total)
	assert(GameData.player_diamonds == 195, "Player diamonds after clearing Ep 101-108 must be 195, got %d" % GameData.player_diamonds)
	assert(GameData.LAKE_OF_RAGE_REWARD_DIAMONDS == 30, "Lake of Rage bonus must be 30 diamonds")

	var kanto_stages_total = 0
	var kanto_diamonds_total = 0
	for k_ep in [1, 2, 3, 4, 5, 6, 7]:
		kanto_stages_total += GameData.get_adventure_episode_total_stages_all_routes(k_ep)
		kanto_diamonds_total += GameData.get_adventure_episode_total_diamonds(k_ep)

	assert(kanto_stages_total == 61 and kanto_diamonds_total == 290, "Kanto baseline expected 61 battles / 290 diamonds")
	assert(johto_diamonds_total + GameData.LAKE_OF_RAGE_REWARD_DIAMONDS < kanto_diamonds_total, "Johto (including Lake of Rage) must award fewer diamonds than longer/harder Kanto campaign")
	assert(GameData.calculate_adventure_standard_diamonds(4, 1) == 15, "Standard helper Tier 1 (4 stg) -> 15")
	assert(GameData.calculate_adventure_standard_diamonds(5, 1) == 20, "Standard helper Tier 1 (5 stg) -> 20")
	assert(GameData.calculate_adventure_standard_diamonds(2, 3, true) == 15, "Standard helper Tier 3 Boss (2 stg) -> 15")

	# Restore profile state
	GameData.player_diamonds = saved_diamonds
	GameData.adventure_completed_episodes = saved_comp
	GameData.adventure_unlocked_episodes = saved_unl
	GameData.adventure_ep106_cleared_routes = saved_r106
	GameData.adventure_ep107_cleared_routes = saved_r107
	GameData.adventure_ep108_cleared_routes = saved_r108
	GameData.adventure_ep106_selected_route = saved_s106
	GameData.adventure_ep107_selected_route = saved_s107
	GameData.adventure_ep108_selected_route = saved_s108
	GameData.save_profile()
	print("✓ Johto standardized rewards (39 battles -> 195💎 + 30💎 boss = 225💎 vs Kanto 61 battles -> 290💎) verified!")

	print("\n=== ALL JOHTO EPISODES & RED GYARADOS TESTS PASSED PERFECTLY! ===")
	get_tree().quit(0)
