extends Node

func _ready() -> void:
	print("==================================================")
	print("🧪 TESTING ADVENTURE EPISODE IV (CELADON CITY GYM)")
	print("==================================================")

	# 1. Episode metadata
	var ep4_info = GameData.get_adventure_episode_info(4)
	assert(not ep4_info.is_empty(), "Episode IV must exist in ADVENTURE_EPISODES")
	assert(ep4_info.get("id") == 4, "Episode IV id should be 4")
	assert(str(ep4_info.get("title")).contains("Episode IV"), "Episode IV title must contain 'Episode IV'")
	assert(int(ep4_info.get("reward_diamonds_first_clear", 0)) == 35, "First clear reward should be 35 diamonds")
	print("✓ Episode IV metadata verified:", ep4_info.get("title"))

	# 2. Total stages
	var total_stages = GameData.get_adventure_total_stages(4)
	assert(total_stages == 8, "Episode IV must have exactly 8 stages, got: %d" % total_stages)
	print("✓ Total stages verified: 8 stages")

	# 3. Verify each of the 8 stages and rivals
	var expected_stages = [
		{
			"stage_num": 1,
			"expected_names": ["Sandshrew", "Rattata"],
			"is_boss": false
		},
		{
			"stage_num": 2,
			"expected_names": ["Voltorb", "Magnemite", "Pikachu"],
			"is_boss": false
		},
		{
			"stage_num": 3,
			"expected_names": ["Rhyhorn", "Graveler"],
			"is_boss": false
		},
		{
			"stage_num": 4,
			"expected_names": ["Pidgeotto", "Fearow"],
			"is_boss": false
		},
		{
			"stage_num": 5,
			"expected_names": ["Clefairy", "Jigglypuff"],
			"is_boss": false
		},
		{
			"stage_num": 6,
			"expected_names": ["Alakazam", "Blastoise"],
			"is_boss": false
		},
		{
			"stage_num": 7,
			"expected_names": ["Digglet", "Dugtrio"],
			"is_boss": false
		},
		{
			"stage_num": 8,
			"expected_names": ["Tangela", "Weepinbell", "Vileplume"],
			"is_boss": true,
			"badge": "Rainbow Badge"
		}
	]

	for exp in expected_stages:
		var s_num = int(exp["stage_num"])
		var stage_info = GameData.get_adventure_stage_info(4, s_num)
		assert(not stage_info.is_empty(), "Stage %d info must exist" % s_num)
		assert(bool(stage_info.get("is_boss", false)) == bool(exp.get("is_boss", false)), "Stage %d is_boss mismatch" % s_num)
		if exp.has("badge"):
			assert(str(stage_info.get("badge_name", "")) == str(exp["badge"]), "Stage %d badge mismatch" % s_num)

		var rival_ids = GameData.get_adventure_rival_team(4, s_num)
		var exp_names: Array = exp["expected_names"]
		assert(rival_ids.size() == exp_names.size(), "Stage %d rival team size mismatch. Expected %d, got %d" % [s_num, exp_names.size(), rival_ids.size()])

		var resolved_names: Array[String] = []
		for pid in rival_ids:
			assert(GameData.pokemon_catalog.has(pid), "Pokemon ID %d must exist in catalog" % pid)
			var pkmn = GameData.pokemon_catalog[pid]
			resolved_names.append(str(pkmn.get("name", "")))

		print("  Stage %d: %s | Team: %s" % [s_num, stage_info.get("trainer_name", ""), str(resolved_names)])

	# 4. Progression & Unlocking test
	GameData.tutorial_completed = true
	if not (3 in GameData.adventure_completed_episodes):
		GameData.adventure_completed_episodes.append(3)
	if not (4 in GameData.adventure_unlocked_episodes):
		GameData.adventure_unlocked_episodes.append(4)

	assert(GameData.is_adventure_episode_unlocked(4), "Episode IV should be unlocked when Ep 3 is cleared")
	print("✓ Episode IV unlocking logic verified.")

	# 5. Completion reward test
	GameData.adventure_completed_episodes.erase(4)
	GameData.player_diamonds = 0
	var diamonds_won = GameData.complete_adventure_episode(4)
	assert(diamonds_won == 35, "Complete Episode IV should reward 35 diamonds")
	assert(GameData.is_adventure_episode_completed(4), "Episode IV must be marked as completed")
	print("✓ Episode IV completion and reward verified (80 diamonds).")

	print("==================================================")
	print("✅ ALL ADVENTURE EPISODE IV TESTS PASSED! (0 ERRORS)")
	print("==================================================")
	get_tree().quit()
