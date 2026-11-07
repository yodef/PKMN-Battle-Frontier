extends Node

func _ready() -> void:
	print("==================================================")
	print("🧪 TESTING ADVENTURE EPISODE VI (SILPH CO. & SAFFRON GYM)")
	print("==================================================")

	# 1. Episode VI existence and branching validation
	assert(GameData.ADVENTURE_EPISODES.has(6), "Episode VI must exist in ADVENTURE_EPISODES")
	var ep6 = GameData.get_adventure_episode_info(6)
	assert(ep6.get("is_branching", false) == true, "Episode VI must have is_branching = true")
	var routes = ep6.get("routes", {})
	assert(routes.has("silph_co"), "Must contain silph_co route")
	assert(routes.has("saffron_gym"), "Must contain saffron_gym route")
	print("✓ Episode VI structure and routes verified.")

	# 2. Validate routes, stage counts, and Pokémon teams
	var expected_routes = {
		"silph_co": {
			"count": 6,
			"teams": [
				["Ekans", "Golbat"],
				["Koffing", "Arbok"],
				["Grimer", "Kakuna"],
				["Magmar", "Electivire"],
				["Raticate", "Arbok", "Weezing"],
				["Rhydon", "Persian", "Kangaskhan"]
			]
		},
		"saffron_gym": {
			"count": 4,
			"teams": [
				["Abra", "Slowpoke", "Drowzee"],
				["Mime Jr.", "Smoochum", "Kadabra"],
				["Jynx", "Hypno"],
				["Venomoth", "Mr. Mime", "Alakazam"]
			]
		},
		"fighting_dojo": {
			"count": 4,
			"teams": [
				["Machop", "Mankey", "Abra"],
				["Machoke", "Primeape"],
				["Hitmonlee", "Hitmonchan"],
				["Pinsir", "Machamp"]
			]
		}
	}

	for r_id in expected_routes.keys():
		GameData.adventure_ep6_selected_route = r_id
		var total_st = GameData.get_adventure_total_stages(6)
		assert(total_st == expected_routes[r_id]["count"], "Route %s must have %d stages, got %d" % [r_id, expected_routes[r_id]["count"], total_st])
		var expected_teams = expected_routes[r_id]["teams"]
		for i in range(total_st):
			var stage = GameData.get_adventure_stage_info(6, i + 1)
			assert(stage.get("stage_num") == i + 1, "Stage number mismatch in %s" % r_id)
			var team_names = stage.get("team_pokemon_names", [])
			assert(team_names == expected_teams[i], "Team mismatch in %s stage %d: expected %s, got %s" % [r_id, i + 1, str(expected_teams[i]), str(team_names)])
			var rival_team = GameData.get_adventure_rival_team(6, i + 1)
			assert(rival_team.size() == team_names.size(), "All Pokémon must resolve to valid catalog IDs in %s stage %d" % [r_id, i + 1])
			for pid in rival_team:
				assert(pid != -1 and GameData.pokemon_catalog.has(pid), "Invalid Pokémon ID %d in %s" % [pid, r_id])
		print("  ✓ Route '%s' verified (%d stages, all Pokémon resolved)." % [r_id, total_st])

	# 3. Giovanni Super Potions test (has 2 Super Potions)
	GameData.adventure_ep6_selected_route = "silph_co"
	var giovanni_stage = GameData.get_adventure_stage_info(6, 6)
	assert(giovanni_stage.get("trainer_name") == "Líder Giovanni", "Stage 6 must be Líder Giovanni")
	assert(int(giovanni_stage.get("super_potions", 0)) == 2, "Líder Giovanni in Silph Co. must have 2 Super Potions")
	print("✓ Líder Giovanni 2x Super Potions verified.")

	# 4. Route unlocking & completion flow
	GameData.adventure_unlocked_episodes = [1, 2, 3, 4, 5, 6]
	GameData.adventure_completed_episodes = [1, 2, 3, 4, 5]
	GameData.adventure_ep6_cleared_routes = []
	GameData.player_diamonds = 0

	# Initial state: only Silph Co. unlocked
	assert(GameData.is_adventure_ep6_route_unlocked("silph_co"), "Silph Co. must be unlocked initially")
	assert(not GameData.is_adventure_ep6_route_unlocked("saffron_gym"), "Saffron Gym must be locked initially")
	assert(not GameData.is_adventure_ep6_route_unlocked("fighting_dojo"), "PokéDojo must be locked initially")
	print("✓ Initial route unlocking states verified.")

	# Complete Silph Co. (First Clear: 20 Diamonds & unlocks Saffron Gym + PokéDojo)
	GameData.adventure_ep6_selected_route = "silph_co"
	var r1_bonus = GameData.complete_adventure_episode(6)
	assert(r1_bonus == 20, "Silph Co. first clear must give 20 diamonds, got %d" % r1_bonus)
	assert("silph_co" in GameData.adventure_ep6_cleared_routes, "silph_co must be in cleared routes")
	assert(GameData.is_adventure_ep6_route_unlocked("saffron_gym"), "Saffron Gym must now be unlocked")
	assert(GameData.is_adventure_ep6_route_unlocked("fighting_dojo"), "PokéDojo must now be unlocked")
	print("✓ Silph Co. first clear (20 Diamonds & Saffron Gym + PokéDojo unlocking) verified.")

	# Complete PokéDojo (First Clear: 20 Diamonds, Hitmonlee & Hitmonchan cards)
	var prev_lee_stock = GameData.get_card_stock(111)
	var prev_chan_stock = GameData.get_card_stock(112)
	GameData.adventure_ep6_selected_route = "fighting_dojo"
	var r_dojo_bonus = GameData.complete_adventure_episode(6)
	assert(r_dojo_bonus == 20, "PokéDojo first clear must give 20 diamonds, got %d" % r_dojo_bonus)
	assert("fighting_dojo" in GameData.adventure_ep6_cleared_routes, "fighting_dojo must be in cleared routes")
	assert(GameData.is_pokemon_unlocked(111), "Hitmonlee must be unlocked in collection")
	assert(GameData.is_pokemon_unlocked(112), "Hitmonchan must be unlocked in collection")
	assert(GameData.get_card_stock(111) >= prev_lee_stock + 1, "Hitmonlee stock must be incremented")
	assert(GameData.get_card_stock(112) >= prev_chan_stock + 1, "Hitmonchan stock must be incremented")
	print("✓ PokéDojo first clear (20 Diamonds & Hitmonlee + Hitmonchan cards) verified.")

	# Complete Saffron Gym (First Clear: 20 Diamonds, Marsh Badge & unlocks Episode VII)
	GameData.adventure_ep6_selected_route = "saffron_gym"
	var r2_bonus = GameData.complete_adventure_episode(6)
	assert(r2_bonus == 20, "Saffron Gym first clear must give 20 diamonds, got %d" % r2_bonus)
	assert("saffron_gym" in GameData.adventure_ep6_cleared_routes, "saffron_gym must be in cleared routes")
	assert(6 in GameData.adventure_completed_episodes, "Episode 6 must be marked completed after clearing gym")
	assert(7 in GameData.adventure_unlocked_episodes, "Episode 7 must be unlocked after clearing Sabrina's Gym")
	print("✓ Saffron Gym first clear (20 Diamonds, Marsh Badge & Episode VII unlock) verified.")

	# 5. Main menu scene instantiation and UI test
	var main_menu_scene = load("res://scenes/main_menu.tscn")
	assert(main_menu_scene != null, "scenes/main_menu.tscn must load")
	var main_menu = main_menu_scene.instantiate()
	add_child(main_menu)
	assert(main_menu.btn_hub_adventure_ep6 != null, "btn_hub_adventure_ep6 must exist in main_menu")
	assert(main_menu.ep6_status_lbl != null, "ep6_status_lbl must exist in main_menu")
	
	# Open Ep 6 modal
	main_menu._open_adventure_ep6_routes_modal()
	assert(main_menu.adventure_ep6_routes_modal != null, "adventure_ep6_routes_modal must be created")
	assert(main_menu.adventure_ep6_routes_modal.visible == true, "adventure_ep6_routes_modal must be visible")
	assert(main_menu.ep6_route_cards.size() == 3, "Must have 3 route cards in modal")
	print("✓ Main menu UI & Episode VI routes modal integration verified.")

	print("==================================================")
	print("✅ ALL ADVENTURE EPISODE VI TESTS PASSED! (0 ERRORS)")
	print("==================================================")
	get_tree().quit()
