extends Node

func _ready() -> void:
	print("==================================================")
	print("🧪 TESTING ADVENTURE EPISODE VII (POKÉMON MANSION & BLAINE GYM)")
	print("==================================================")

	# 1. Episode VII existence and branching validation
	assert(GameData.ADVENTURE_EPISODES.has(7), "Episode VII must exist in ADVENTURE_EPISODES")
	var ep7 = GameData.get_adventure_episode_info(7)
	assert(ep7.get("is_branching", false) == true, "Episode VII must have is_branching = true")
	var routes = ep7.get("routes", {})
	assert(routes.has("pokemon_mansion"), "Must contain pokemon_mansion route")
	assert(routes.has("blaine_gym"), "Must contain blaine_gym route")
	print("✓ Episode VII structure and routes verified.")

	# 2. Validate routes, stage counts, and Pokémon teams
	var expected_routes = {
		"pokemon_mansion": {
			"count": 6,
			"teams": [
				["Ekans", "Arbok"],
				["Pikachu", "Jolteon"],
				["Growlithe", "Muk"],
				["Wigglytuff", "Clefable"],
				["Machop", "Nidorino", "Golem"],
				["Kadabra", "Charizard", "Pidgeot"]
			]
		},
		"blaine_gym": {
			"count": 5,
			"teams": [
				["Rapidash", "Ekans", "Raticate"],
				["Geodude", "Nidorina", "Graveler"],
				["Snorlax"],
				["Machoke", "Primeape"],
				["Growlithe", "Rapidash", "Arcanine"]
			]
		}
	}

	for r_id in expected_routes.keys():
		GameData.adventure_ep7_selected_route = r_id
		var total_st = GameData.get_adventure_total_stages(7)
		assert(total_st == expected_routes[r_id]["count"], "Route %s must have %d stages, got %d" % [r_id, expected_routes[r_id]["count"], total_st])
		var expected_teams = expected_routes[r_id]["teams"]
		for i in range(total_st):
			var stage = GameData.get_adventure_stage_info(7, i + 1)
			assert(stage.get("stage_num") == i + 1, "Stage number mismatch in %s" % r_id)
			var team_names = stage.get("team_pokemon_names", [])
			assert(team_names == expected_teams[i], "Team mismatch in %s stage %d: expected %s, got %s" % [r_id, i + 1, str(expected_teams[i]), str(team_names)])
			var rival_team = GameData.get_adventure_rival_team(7, i + 1)
			assert(rival_team.size() == team_names.size(), "All Pokémon must resolve to valid catalog IDs in %s stage %d" % [r_id, i + 1])
			for pid in rival_team:
				assert(pid != -1 and GameData.pokemon_catalog.has(pid), "Invalid Pokémon ID %d in %s" % [pid, r_id])
		print("  ✓ Route '%s' verified (%d stages, all Pokémon resolved)." % [r_id, total_st])

	# 3. Boss stage checks
	GameData.adventure_ep7_selected_route = "pokemon_mansion"
	var rival_stage = GameData.get_adventure_stage_info(7, 6)
	assert(rival_stage.get("trainer_name") == "Rival Blue", "Stage 6 in Mansion must be Rival Blue")

	GameData.adventure_ep7_selected_route = "blaine_gym"
	var blaine_stage = GameData.get_adventure_stage_info(7, 5)
	assert(blaine_stage.get("trainer_name") == "Líder Blaine", "Stage 5 in Gym must be Líder Blaine")
	assert(blaine_stage.get("badge_name") == "Volcano Badge", "Blaine must award Volcano Badge")
	print("✓ Bosses (Rival Blue & Líder Blaine) verified.")

	# 4. Route unlocking & completion flow
	GameData.adventure_unlocked_episodes = [1, 2, 3, 4, 5, 6, 7]
	GameData.adventure_completed_episodes = [1, 2, 3, 4, 5, 6]
	GameData.adventure_ep7_cleared_routes = []
	GameData.tutorial_completed = true
	GameData.player_diamonds = 0

	# Initial state: only Pokémon Mansion unlocked
	assert(GameData.is_adventure_ep7_route_unlocked("pokemon_mansion"), "Pokémon Mansion must be unlocked initially")
	assert(not GameData.is_adventure_ep7_route_unlocked("blaine_gym"), "Blaine Gym must be locked initially")
	print("✓ Initial route unlocking states verified.")

	# Complete Pokémon Mansion (First Clear: 35 Diamonds & unlocks Blaine Gym)
	GameData.adventure_ep7_selected_route = "pokemon_mansion"
	var r1_bonus = GameData.complete_adventure_episode(7)
	assert(r1_bonus == 35, "Pokémon Mansion first clear must give 35 diamonds, got %d" % r1_bonus)
	assert("pokemon_mansion" in GameData.adventure_ep7_cleared_routes, "pokemon_mansion must be in cleared routes")
	assert(GameData.is_adventure_ep7_route_unlocked("blaine_gym"), "Blaine Gym must now be unlocked")
	print("✓ Pokémon Mansion first clear (35 Diamonds & Blaine Gym unlocking) verified.")

	# Complete Blaine Gym (First Clear: 35 Diamonds, Volcano Badge & completes campaign)
	GameData.adventure_ep7_selected_route = "blaine_gym"
	var r2_bonus = GameData.complete_adventure_episode(7)
	assert(r2_bonus == 35, "Blaine Gym first clear must give 35 diamonds, got %d" % r2_bonus)
	assert("blaine_gym" in GameData.adventure_ep7_cleared_routes, "blaine_gym must be in cleared routes")
	assert(7 in GameData.adventure_completed_episodes, "Episode 7 must be marked completed")
	print("✓ Blaine Gym first clear (35 Diamonds, Volcano Badge & Episode VII completed) verified.")

	# Replay test
	var replay_bonus = GameData.complete_adventure_episode(7)
	assert(replay_bonus == 0, "Replaying cleared route must give 0 bonus diamonds")
	print("✓ Replay rewards safety verified.")

	# 5. Main menu scene instantiation and UI test
	var main_menu_scene = load("res://scenes/main_menu.tscn")
	assert(main_menu_scene != null, "scenes/main_menu.tscn must load")
	var main_menu = main_menu_scene.instantiate()
	add_child(main_menu)
	assert(main_menu.btn_hub_adventure_ep7 != null, "btn_hub_adventure_ep7 must exist in main_menu")
	assert(main_menu.ep7_status_lbl != null, "ep7_status_lbl must exist in main_menu")
	
	# Open Ep 7 modal
	main_menu._open_adventure_ep7_routes_modal()
	assert(main_menu.adventure_ep7_routes_modal != null, "adventure_ep7_routes_modal must be created")
	assert(main_menu.adventure_ep7_routes_modal.visible == true, "adventure_ep7_routes_modal must be visible")
	assert(main_menu.ep7_route_cards.size() == 2, "Must have 2 route cards in modal")
	print("✓ Main menu UI & Episode VII routes modal integration verified.")

	print("==================================================")
	print("✅ ALL ADVENTURE EPISODE VII TESTS PASSED! (0 ERRORS)")
	print("==================================================")
	get_tree().quit()
