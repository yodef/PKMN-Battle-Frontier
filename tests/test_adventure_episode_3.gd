extends Node

func _ready() -> void:
	print("--- BEGIN ADVENTURE EPISODE III TEST ---")
	
	# 1. Database & Stage Configuration Audit
	var ep3 = GameData.get_adventure_episode_info(3)
	assert(not ep3.is_empty(), "Episode 3 data must exist in ADVENTURE_EPISODES")
	assert(ep3.get("reward_diamonds_first_clear") == 60, "Episode 3 first clear reward must be 60 diamonds")
	assert(GameData.get_adventure_total_stages(3) == 7, "Episode 3 must have exactly 7 stages")
	
	# Stage 1: Sandshrew
	var s1 = GameData.get_adventure_stage_info(3, 1)
	assert(s1.get("team_pokemon_names") == ["Sandshrew"], "Stage 1 team must be Sandshrew")
	var s1_rivals = GameData.get_adventure_rival_team(3, 1)
	assert(s1_rivals.size() == 1, "Stage 1 rival team must resolve 1 valid ID")
	assert(GameData.pokemon_catalog[s1_rivals[0]].name == "Sandshrew", "Stage 1 PKMN must be Sandshrew")
	
	# Stage 2: Clefairy & Pikachu
	var s2 = GameData.get_adventure_stage_info(3, 2)
	assert(s2.get("team_pokemon_names") == ["Clefairy", "Pikachu"], "Stage 2 team must be Clefairy and Pikachu")
	var s2_rivals = GameData.get_adventure_rival_team(3, 2)
	assert(s2_rivals.size() == 2, "Stage 2 rival team must resolve 2 valid IDs")
	assert(GameData.pokemon_catalog[s2_rivals[0]].name == "Clefairy", "Stage 2 PKMN 1 must be Clefairy")
	assert(GameData.pokemon_catalog[s2_rivals[1]].name == "Pikachu", "Stage 2 PKMN 2 must be Pikachu")
	
	# Stage 3: Poliwhirl
	var s3 = GameData.get_adventure_stage_info(3, 3)
	assert(s3.get("team_pokemon_names") == ["Poliwhirl"], "Stage 3 team must be Poliwhirl")
	var s3_rivals = GameData.get_adventure_rival_team(3, 3)
	assert(s3_rivals.size() == 1, "Stage 3 rival team must resolve 1 valid ID")
	assert(GameData.pokemon_catalog[s3_rivals[0]].name == "Poliwhirl", "Stage 3 PKMN must be Poliwhirl")
	
	# Stage 4: Mankey & Machop
	var s4 = GameData.get_adventure_stage_info(3, 4)
	assert(s4.get("team_pokemon_names") == ["Mankey", "Machop"], "Stage 4 team must be Mankey and Machop")
	var s4_rivals = GameData.get_adventure_rival_team(3, 4)
	assert(s4_rivals.size() == 2, "Stage 4 rival team must resolve 2 valid IDs")
	assert(GameData.pokemon_catalog[s4_rivals[0]].name == "Mankey", "Stage 4 PKMN 1 must be Mankey")
	assert(GameData.pokemon_catalog[s4_rivals[1]].name == "Machop", "Stage 4 PKMN 2 must be Machop")
	
	# Stage 5: Rival with Charmeleon & Ivysaur
	var s5 = GameData.get_adventure_stage_info(3, 5)
	assert(s5.get("team_pokemon_names") == ["Charmeleon", "Ivysaur"], "Stage 5 team must be Charmeleon and Ivysaur")
	var s5_rivals = GameData.get_adventure_rival_team(3, 5)
	assert(s5_rivals.size() == 2, "Stage 5 rival team must resolve 2 valid IDs")
	assert(GameData.pokemon_catalog[s5_rivals[0]].name == "Charmeleon", "Stage 5 PKMN 1 must be Charmeleon")
	assert(GameData.pokemon_catalog[s5_rivals[1]].name == "Ivysaur", "Stage 5 PKMN 2 must be Ivysaur")
	
	# Stage 6: Team Rocket Grunt with Arbok & Persian
	var s6 = GameData.get_adventure_stage_info(3, 6)
	assert(s6.get("team_pokemon_names") == ["Arbok", "Persian"], "Stage 6 team must be Arbok and Persian")
	var s6_rivals = GameData.get_adventure_rival_team(3, 6)
	assert(s6_rivals.size() == 2, "Stage 6 rival team must resolve 2 valid IDs")
	assert(GameData.pokemon_catalog[s6_rivals[0]].name == "Arbok", "Stage 6 PKMN 1 must be Arbok")
	assert(GameData.pokemon_catalog[s6_rivals[1]].name == "Persian", "Stage 6 PKMN 2 must be Persian")
	
	# Stage 7: Gym Leader Lt. Surge (Voltorb, Magneton, Raichu)
	var s7 = GameData.get_adventure_stage_info(3, 7)
	assert(s7.get("is_boss") == true, "Stage 7 must be boss battle")
	assert(s7.get("badge_name") == "Thunder Badge", "Stage 7 must award Thunder Badge")
	assert(s7.get("trainer_name").contains("Lt. Surge"), "Stage 7 trainer name must be Lt. Surge")
	assert(s7.get("team_pokemon_names") == ["Voltorb", "Magneton", "Raichu"], "Stage 7 team must be Voltorb, Magneton, and Raichu")
	var s7_rivals = GameData.get_adventure_rival_team(3, 7)
	assert(s7_rivals.size() == 3, "Stage 7 rival team must resolve 3 valid IDs")
	assert(GameData.pokemon_catalog[s7_rivals[0]].name == "Voltorb", "Stage 7 PKMN 1 must be Voltorb")
	assert(GameData.pokemon_catalog[s7_rivals[1]].name == "Magneton", "Stage 7 PKMN 2 must be Magneton")
	assert(GameData.pokemon_catalog[s7_rivals[2]].name == "Raichu", "Stage 7 PKMN 3 must be Raichu")
	
	# Episode 4 structure check (locked until Episode 3 completed)
	var ep4 = GameData.get_adventure_episode_info(4)
	assert(not ep4.is_empty(), "Episode 4 data must exist in ADVENTURE_EPISODES")
	assert(ep4.get("title").contains("Celadon City Gym"), "Episode 4 title must be Celadon City Gym")
	print("Test 1 Passed: Episode III (7 battles) & Episode IV configuration verified.")
	
	# 2. Progression & Unlock Flow
	GameData.create_new_profile("TesterEp3", "Guest", "tester_ep3@frontier.local")
	GameData.tutorial_completed = true
	GameData.tutorial_reward_claimed = true
	
	assert(GameData.is_adventure_episode_unlocked(1), "Episode 1 must be unlocked after tutorial")
	assert(not GameData.is_adventure_episode_unlocked(2), "Episode 2 must be locked initially")
	assert(not GameData.is_adventure_episode_unlocked(3), "Episode 3 must be locked initially")
	assert(not GameData.is_adventure_episode_unlocked(4), "Episode 4 must be locked initially")
	
	# Complete Episode 1 and 2
	GameData.complete_adventure_episode(1)
	assert(GameData.is_adventure_episode_unlocked(2), "Episode 2 unlocked after Ep 1 clear")
	assert(not GameData.is_adventure_episode_unlocked(3), "Episode 3 still locked before Ep 2 clear")
	
	GameData.complete_adventure_episode(2)
	assert(GameData.is_adventure_episode_unlocked(3), "Episode 3 unlocked after Ep 2 clear")
	assert(not GameData.is_adventure_episode_unlocked(4), "Episode 4 locked before Ep 3 clear")
	print("Test 2 Passed: Episode 3 unlock depends on Episode 2 completion.")
	
	# Complete Episode 3 (first clear)
	var d_before_ep3 = GameData.player_diamonds
	var r3 = GameData.complete_adventure_episode(3)
	assert(r3 == 60, "Completing Episode 3 must award 60 diamonds")
	assert(GameData.player_diamonds == d_before_ep3 + 60, "Player diamonds must increase by exactly 60")
	assert(GameData.is_adventure_episode_completed(3), "Episode 3 must be marked completed")
	assert(GameData.is_adventure_episode_unlocked(4), "Episode 4 must be unlocked after Episode 3 clear")
	print("Test 3 Passed: Episode 3 clear awards 60 diamonds and unlocks Episode 4.")
	
	# Replay Episode 3 (duplicate clear does not award 60 diamonds again)
	var d_after_ep3 = GameData.player_diamonds
	var r3_replay = GameData.complete_adventure_episode(3)
	assert(r3_replay == 0, "Replaying Episode 3 must award 0 bonus diamonds")
	assert(GameData.player_diamonds == d_after_ep3, "Player diamonds must not change on replay")
	print("Test 4 Passed: Episode 3 replay reward prevention verified.")
	
	# 3. Save & Load Persistence
	var save_dict = GameData.get_save_dict()
	assert(save_dict.has("adventure"), "Save dict must contain adventure section")
	assert(save_dict["adventure"]["completed_episodes"].has(3), "Completed episodes in save dict must contain 3")
	assert(save_dict["adventure"]["unlocked_episodes"].has(4), "Unlocked episodes in save dict must contain 4")
	
	# Load profile into new clean state
	GameData.create_new_profile("OtherUserEp3", "Guest", "other_ep3@frontier.local")
	assert(not GameData.is_adventure_episode_completed(3), "New profile must not have completed Ep 3")
	GameData.apply_save_dict(save_dict)
	assert(GameData.is_adventure_episode_completed(3), "Loaded profile must have completed Ep 3")
	assert(GameData.is_adventure_episode_unlocked(4), "Loaded profile must have Ep 4 unlocked")
	print("Test 5 Passed: Save and load persistence verified for Episode 3 & 4.")
	
	# 4. Main Menu UI Test
	var menu_scene = load("res://scenes/main_menu.tscn")
	assert(menu_scene != null, "scenes/main_menu.tscn must load")
	var menu = menu_scene.instantiate()
	add_child(menu)
	await get_tree().process_frame
	
	var adv_modal = menu.get_node("AdventureEpisodesModal")
	assert(adv_modal != null, "AdventureEpisodesModal must exist")
	var card_ep3 = adv_modal.get_node_or_null("Box/EpisodesScroll/EpisodesVBox/CardAdventureEp3")
	var card_ep4 = adv_modal.get_node_or_null("Box/EpisodesScroll/EpisodesVBox/CardAdventureEp4")
	assert(card_ep3 != null, "CardAdventureEp3 must exist in AdventureEpisodesModal")
	assert(card_ep4 != null, "CardAdventureEp4 must exist in AdventureEpisodesModal")
	
	menu.update_adventure_episodes_ui()
	assert(menu.ep3_status_lbl.text.contains("COMPLETED") or menu.ep3_status_lbl.text.contains("Thunder Badge"), "Ep3 status should show completed for loaded profile")
	assert(menu.btn_hub_adventure_ep3.text.contains("Replay Episode III"), "Ep3 button text should offer Replay Episode III")
	assert(menu.btn_hub_adventure_ep3.disabled == false, "Ep3 button should be enabled")
	
	# Check Episode 4 UI
	assert(menu.ep4_status_lbl.text.contains("Coming Soon") or menu.ep4_status_lbl.text.contains("In Development"), "Ep4 status should show Coming Soon once unlocked")
	assert(menu.btn_hub_adventure_ep4.disabled == true, "Ep4 button should be disabled")
	
	# Test clicking Replay Episode 3 opens team select or campaign modal
	GameData.adventure_player_team_state.clear()
	menu._on_select_adventure_ep3_pressed()
	assert(GameData.adventure_current_episode == 3, "Selecting Ep3 must set adventure_current_episode to 3")
	assert(menu.team_select_modal.visible == true, "Selecting Ep3 with empty team opens team select")
	assert(menu.team_select_title.text.contains("ADVENTURE"), "Team select title must mention ADVENTURE")
	assert(menu.team_select_subtitle.text.contains("Episode III"), "Team select subtitle must mention Episode III")
	print("Test 6 Passed: Main Menu UI cards, buttons, and Episode III team select verified.")
	
	print("=== ALL ADVENTURE EPISODE III TESTS PASSED! ===")
	get_tree().quit(0)
