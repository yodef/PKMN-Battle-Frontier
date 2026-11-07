extends Node

func _ready() -> void:
	print("==================================================")
	print("🧪 TESTING ADVENTURE EPISODE V (BRANCHING ROUTES)")
	print("==================================================")

	# 1. Episode V existence and branching validation
	assert(GameData.ADVENTURE_EPISODES.has(5), "Episode V must exist in ADVENTURE_EPISODES")
	var ep5 = GameData.get_adventure_episode_info(5)
	assert(ep5.get("is_branching", false) == true, "Episode V must have is_branching = true")
	var routes = ep5.get("routes", {})
	assert(routes.has("rocket_hideout"), "Must contain rocket_hideout route")
	assert(routes.has("pokemon_tower"), "Must contain pokemon_tower route")
	assert(routes.has("fuchsia_gym"), "Must contain fuchsia_gym route")
	print("✓ Episode V structure and 3 routes verified.")

	# 2. Validate all 3 routes, stage counts, and Pokémon teams
	var expected_routes = {
		"rocket_hideout": {
			"count": 5,
			"teams": [
				["Zubat", "Rattata", "Ekans"],
				["Elekid", "Magnemite", "Electrode"],
				["Raticate", "Arbok"],
				["Golbat", "Electabuzz"],
				["Rhyhorn", "Persian", "Kangaskhan"]
			]
		},
		"pokemon_tower": {
			"count": 4,
			"teams": [
				["Ghastly", "Ghastly"],
				["Ghastly", "Haunter"],
				["Haunter", "Haunter"],
				["Sandshrew", "Marowak", "Gengar"]
			]
		},
		"fuchsia_gym": {
			"count": 3,
			"teams": [
				["Ekans", "Venonat", "Golbat"],
				["Koffing", "Drowzee", "Hypno"],
				["Muk", "Weezing", "Venomoth"]
			]
		}
	}

	for r_id in expected_routes.keys():
		GameData.adventure_ep5_selected_route = r_id
		var total_st = GameData.get_adventure_total_stages(5)
		assert(total_st == expected_routes[r_id]["count"], "Route %s must have %d stages, got %d" % [r_id, expected_routes[r_id]["count"], total_st])
		var expected_teams = expected_routes[r_id]["teams"]
		for i in range(total_st):
			var stage = GameData.get_adventure_stage_info(5, i + 1)
			assert(stage.get("stage_num") == i + 1, "Stage number mismatch in %s" % r_id)
			var team_names = stage.get("team_pokemon_names", [])
			assert(team_names == expected_teams[i], "Team mismatch in %s stage %d: expected %s, got %s" % [r_id, i + 1, str(expected_teams[i]), str(team_names)])
			var rival_team = GameData.get_adventure_rival_team(5, i + 1)
			assert(rival_team.size() == team_names.size(), "All Pokémon must resolve to valid catalog IDs in %s stage %d" % [r_id, i + 1])
			for pid in rival_team:
				assert(pid != -1 and GameData.pokemon_catalog.has(pid), "Invalid Pokémon ID %d in %s" % [pid, r_id])
		print("  ✓ Route '%s' verified (%d stages, all Pokémon resolved)." % [r_id, total_st])

	# 3. Giovanni Super Potion test
	GameData.adventure_ep5_selected_route = "rocket_hideout"
	var giovanni_stage = GameData.get_adventure_stage_info(5, 5)
	assert(giovanni_stage.get("trainer_name") == "Líder Giovanni", "Stage 5 must be Líder Giovanni")
	assert(giovanni_stage.get("has_super_potion", false) == true, "Líder Giovanni must have has_super_potion = true")
	print("✓ Líder Giovanni Super Potion flag verified.")

	# 4. Route unlocking & completion flow
	GameData.adventure_unlocked_episodes = [1, 2, 3, 4, 5]
	GameData.adventure_completed_episodes = [1, 2, 3, 4]
	GameData.adventure_ep5_cleared_routes = []
	GameData.player_diamonds = 0

	# Initial state: only Rocket Hideout unlocked
	assert(GameData.is_adventure_ep5_route_unlocked("rocket_hideout"), "Rocket hideout must be unlocked initially")
	assert(not GameData.is_adventure_ep5_route_unlocked("pokemon_tower"), "Pokémon Tower must be locked initially")
	assert(not GameData.is_adventure_ep5_route_unlocked("fuchsia_gym"), "Fuchsia Gym must be locked initially")
	print("✓ Initial route unlocking states verified.")

	# Complete Rocket Hideout (First Clear: 20 Diamonds & unlocks Tower + Gym)
	GameData.adventure_ep5_selected_route = "rocket_hideout"
	var r1_bonus = GameData.complete_adventure_episode(5)
	assert(r1_bonus == 20, "Rocket hideout first clear must give 20 diamonds, got %d" % r1_bonus)
	assert("rocket_hideout" in GameData.adventure_ep5_cleared_routes, "rocket_hideout must be in cleared routes")
	assert(GameData.is_adventure_ep5_route_unlocked("pokemon_tower"), "Pokémon Tower must now be unlocked")
	assert(GameData.is_adventure_ep5_route_unlocked("fuchsia_gym"), "Fuchsia Gym must now be unlocked")
	print("✓ Rocket Hideout first clear (20 Diamonds & branch unlocking) verified.")

	# Complete Pokémon Tower (First Clear: 15 Diamonds & Poké Flute)
	GameData.adventure_ep5_selected_route = "pokemon_tower"
	var r2_bonus = GameData.complete_adventure_episode(5)
	assert(r2_bonus == 15, "Pokémon Tower first clear must give 15 diamonds, got %d" % r2_bonus)
	assert("pokemon_tower" in GameData.adventure_ep5_cleared_routes, "pokemon_tower must be in cleared routes")
	assert(GameData.adventure_inventory.get("poke_flute", 0) >= 1, "Player must receive Poké Flute upon completing Pokémon Tower")
	
	# Verify Poké Flute is retained across reset
	GameData.reset_adventure_episode(5)
	assert(GameData.adventure_inventory.get("poke_flute", 0) >= 1, "Poké Flute must be retained permanently in adventure inventory")
	print("✓ Pokémon Tower first clear (15 Diamonds & permanent Poké Flute) verified.")

	# Complete Fuchsia Gym (First Clear: 15 Diamonds, Soul Badge & unlocks Episode VI)
	GameData.adventure_ep5_selected_route = "fuchsia_gym"
	var r3_bonus = GameData.complete_adventure_episode(5)
	assert(r3_bonus == 15, "Fuchsia Gym first clear must give 15 diamonds, got %d" % r3_bonus)
	assert("fuchsia_gym" in GameData.adventure_ep5_cleared_routes, "fuchsia_gym must be in cleared routes")
	assert(5 in GameData.adventure_completed_episodes, "Episode 5 must be marked completed after clearing gym")
	assert(6 in GameData.adventure_unlocked_episodes, "Episode 6 must be unlocked after clearing Koga's Gym")
	print("✓ Fuchsia Gym first clear (15 Diamonds, Soul Badge & Episode VI unlock) verified.")

	# 5. Main menu scene instantiation and UI test
	var main_menu_scene = load("res://scenes/main_menu.tscn")
	assert(main_menu_scene != null, "scenes/main_menu.tscn must load")
	var main_menu = main_menu_scene.instantiate()
	add_child(main_menu)
	assert(main_menu.btn_hub_adventure_ep5 != null, "btn_hub_adventure_ep5 must exist in main_menu")
	assert(main_menu.ep5_status_lbl != null, "ep5_status_lbl must exist in main_menu")
	
	# Open Ep 5 modal
	main_menu._open_adventure_ep5_routes_modal()
	assert(main_menu.adventure_ep5_routes_modal != null, "adventure_ep5_routes_modal must be created")
	assert(main_menu.adventure_ep5_routes_modal.visible == true, "adventure_ep5_routes_modal must be visible")
	assert(main_menu.ep5_route_cards.size() == 3, "Must have 3 route cards in modal")
	print("✓ Main menu UI & Episode V routes modal integration verified.")

	print("==================================================")
	print("✅ ALL ADVENTURE EPISODE V TESTS PASSED! (0 ERRORS)")
	print("==================================================")
	get_tree().quit()
