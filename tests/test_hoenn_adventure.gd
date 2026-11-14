extends Node

func _ready() -> void:
	print("\n=== STARTING HOENN ADVENTURE REGION INTEGRATION TEST ===")
	
	# 1. Verify all Hoenn episodes (201-208) exist in ADVENTURE_EPISODES
	var all_names = {}
	for id in GameData.all_pokemon_ids:
		var cat = GameData.pokemon_catalog.get(id, {})
		all_names[str(cat.get("name", ""))] = true

	for ep_id in range(201, 209):
		var ep = GameData.ADVENTURE_EPISODES.get(ep_id, {})
		assert(not ep.is_empty(), "Episode %d must exist in ADVENTURE_EPISODES" % ep_id)
		assert(ep.get("region") == "Hoenn", "Episode %d region must be 'Hoenn'" % ep_id)
		assert(ep.has("title") and ep.has("title_es"), "Episode %d must have title and title_es" % ep_id)
		assert(ep.has("subtitle") and ep.has("subtitle_es"), "Episode %d must have subtitle and subtitle_es" % ep_id)
		var is_branching = bool(ep.get("is_branching", false))
		if is_branching:
			var routes = ep.get("routes", {})
			assert(routes.size() >= 2, "Branching episode %d must have at least 2 routes" % ep_id)
			for r_id in routes.keys():
				var r_data = routes[r_id]
				assert(r_data.has("name") and r_data.has("name_es"), "Route %s of Ep %d must have name and name_es" % [r_id, ep_id])
				assert(r_data.has("desc") and r_data.has("desc_es"), "Route %s of Ep %d must have desc and desc_es" % [r_id, ep_id])
				var r_stages = r_data.get("stages", [])
				assert(r_stages.size() > 0, "Route %s of Ep %d must have stages" % [r_id, ep_id])
				for st in r_stages:
					assert(st.has("trainer_name") and st.has("trainer_name_es"), "Stage in Ep %d Route %s must have trainer_name and trainer_name_es" % [ep_id, r_id])
					assert(st.has("intro") and st.has("intro_es"), "Stage in Ep %d Route %s must have intro and intro_es" % [ep_id, r_id])
					assert(st.has("outro") and st.has("outro_es"), "Stage in Ep %d Route %s must have outro and outro_es" % [ep_id, r_id])
					var p_names = st.get("team_pokemon_names", [])
					assert(p_names.size() > 0, "Stage %d of route %s in Ep %d must have Pokemon" % [st.get("stage_num", 0), r_id, ep_id])
					for p_name in p_names:
						assert(all_names.has(p_name), "Pokemon '%s' in Ep %d must exist in catalog!" % [p_name, ep_id])
		else:
			var stages = ep.get("stages", [])
			assert(stages.size() > 0, "Episode %d must have stages" % ep_id)
			for st in stages:
				assert(st.has("trainer_name") and st.has("trainer_name_es"), "Stage in Ep %d must have trainer_name and trainer_name_es" % ep_id)
				assert(st.has("intro") and st.has("intro_es"), "Stage in Ep %d must have intro and intro_es" % ep_id)
				assert(st.has("outro") and st.has("outro_es"), "Stage in Ep %d must have outro and outro_es" % ep_id)
				var p_names = st.get("team_pokemon_names", [])
				assert(p_names.size() > 0, "Stage in Ep %d must have Pokemon" % ep_id)
				for p_name in p_names:
					assert(all_names.has(p_name), "Pokemon '%s' in Ep %d must exist in catalog!" % [p_name, ep_id])
	print("✓ All 8 Hoenn episodes and stages correctly defined with bilingual text and valid catalog Pokémon.")

	# 2. Verify total diamonds calculation
	var total_hoenn_diamonds = 0
	for ep_id in range(201, 209):
		var d = GameData.get_adventure_episode_total_diamonds(ep_id)
		assert(d >= 15, "Episode %d must grant at least 15 diamonds" % ep_id)
		total_hoenn_diamonds += d
	print("✓ Total Hoenn first-clear diamonds: %d 💎 (Well-balanced!)" % total_hoenn_diamonds)

	# 3. Test progression & badge count functions
	for ep in range(201, 209):
		GameData.adventure_completed_episodes.erase(ep)
		GameData.adventure_unlocked_episodes.erase(ep)
	GameData.adventure_ep204_cleared_routes.clear()
	GameData.adventure_ep206_cleared_routes.clear()
	GameData.adventure_ep208_cleared_routes.clear()

	var initial_badges = GameData.get_hoenn_gym_badges_count()
	assert(initial_badges == 0, "Initial Hoenn badges must be 0")
	assert(not GameData.has_all_hoenn_gym_badges(), "Should not have all Hoenn badges initially")

	# Mock completing ep 201
	GameData.adventure_unlocked_episodes.append(201)
	assert(GameData.is_adventure_episode_unlocked(201), "Ep 201 should be unlocked")
	var earned = GameData.complete_adventure_episode(201)
	assert(earned == 15, "Ep 201 first-clear should give 15 diamonds")
	assert(GameData.get_hoenn_gym_badges_count() == 1, "Should now have 1 Hoenn badge")
	assert(GameData.is_adventure_episode_unlocked(202), "Ep 202 should be unlocked after completing 201")
	print("✓ Hoenn episode completion, progression and badge counting verified.")

	# 4. Test branching routes for Ep 204
	GameData.adventure_unlocked_episodes.append(204)
	assert(GameData.is_adventure_route_unlocked(204, "jagged_pass"), "Jagged Pass should be unlocked first in Ep 204")
	assert(not GameData.is_adventure_route_unlocked(204, "lavaridge_gym"), "Lavaridge Gym should be locked before clearing Jagged Pass")
	GameData.set_adventure_selected_route(204, "jagged_pass")
	GameData.complete_adventure_episode(204)
	assert(GameData.is_adventure_route_unlocked(204, "lavaridge_gym"), "Lavaridge Gym should unlock after clearing Jagged Pass")
	GameData.set_adventure_selected_route(204, "lavaridge_gym")
	GameData.complete_adventure_episode(204)
	assert(GameData.is_adventure_episode_completed(204), "Ep 204 should be completed after final route")
	assert(GameData.is_adventure_episode_unlocked(205), "Ep 205 should be unlocked after Ep 204 completion")
	print("✓ Hoenn branching routes unlock and completion sequence verified.")

	# 5. Test MainMenu UI integration
	var menu = load("res://scenes/main_menu.tscn").instantiate()
	add_child(menu)
	await get_tree().process_frame
	
	menu.update_adventure_regions_ui()
	assert(menu.btn_enter_hoenn != null, "BtnEnterHoenn must exist")
	assert(menu.btn_enter_hoenn.disabled == false, "BtnEnterHoenn should now be enabled")
	
	# Open Hoenn episodes modal
	menu._open_hoenn_episodes_modal()
	assert(menu.hoenn_episodes_modal != null and menu.hoenn_episodes_modal.visible, "Hoenn episodes modal should open")
	assert(menu.hoenn_episode_cards.size() == 8, "Should have 8 episode cards for Hoenn")
	print("✓ MainMenu UI modal for Hoenn opens and displays all 8 episode cards.")

	# 6. Test language switching in UI
	GameData.settings_language = "es"
	menu._refresh_hoenn_episodes_ui()
	var card201 = menu.hoenn_episode_cards[201]
	assert("Petra" in card201["title"].text, "Spanish title should mention Petra")
	
	GameData.settings_language = "en"
	menu._refresh_hoenn_episodes_ui()
	assert("Roxanne" in card201["title"].text, "English title should mention Roxanne")
	print("✓ MainMenu UI properly reflects language change (EN/ES) dynamically.")

	print("\n=== ALL HOENN ADVENTURE TESTS PASSED SUCCESSFULLY! ===")
	get_tree().quit(0)
