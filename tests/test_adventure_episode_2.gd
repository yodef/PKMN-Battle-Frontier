extends Node

func _ready() -> void:
	print("--- BEGIN ADVENTURE EPISODE II TEST ---")
	
	# 1. Database & Stage Configuration Audit
	var ep2 = GameData.get_adventure_episode_info(2)
	assert(not ep2.is_empty(), "Episode 2 data must exist in ADVENTURE_EPISODES")
	assert(ep2.get("reward_diamonds_first_clear") == 25, "Episode 2 first clear reward must be 25 diamonds")
	assert(GameData.get_adventure_total_stages(2) == 5, "Episode 2 must have exactly 5 stages")
	
	# Stage 1: Spearow & Pidgey
	var s1 = GameData.get_adventure_stage_info(2, 1)
	assert(s1.get("team_pokemon_names") == ["Spearow", "Pidgey"], "Stage 1 team must be Spearow and Pidgey")
	var s1_rivals = GameData.get_adventure_rival_team(2, 1)
	assert(s1_rivals.size() == 2, "Stage 1 rival team must resolve 2 valid IDs")
	assert(GameData.pokemon_catalog[s1_rivals[0]].name == "Spearow", "Stage 1 PKMN 1 must be Spearow")
	assert(GameData.pokemon_catalog[s1_rivals[1]].name == "Pidgey", "Stage 1 PKMN 2 must be Pidgey")
	
	# Stage 2: Jigglypuff
	var s2 = GameData.get_adventure_stage_info(2, 2)
	assert(s2.get("team_pokemon_names") == ["Jigglypuff"], "Stage 2 team must be Jigglypuff")
	var s2_rivals = GameData.get_adventure_rival_team(2, 2)
	assert(s2_rivals.size() == 1, "Stage 2 rival team must resolve 1 valid ID")
	assert(GameData.pokemon_catalog[s2_rivals[0]].name == "Jigglypuff", "Stage 2 PKMN must be Jigglypuff")
	
	# Stage 3: Ekans & Zubat
	var s3 = GameData.get_adventure_stage_info(2, 3)
	assert(s3.get("team_pokemon_names") == ["Ekans", "Zubat"], "Stage 3 team must be Ekans and Zubat")
	var s3_rivals = GameData.get_adventure_rival_team(2, 3)
	assert(s3_rivals.size() == 2, "Stage 3 rival team must resolve 2 valid IDs")
	assert(GameData.pokemon_catalog[s3_rivals[0]].name == "Ekans", "Stage 3 PKMN 1 must be Ekans")
	assert(GameData.pokemon_catalog[s3_rivals[1]].name == "Zubat", "Stage 3 PKMN 2 must be Zubat")
	
	# Stage 4: Geodude & Rhyhorn (also verify alias Ryhorn)
	var s4 = GameData.get_adventure_stage_info(2, 4)
	assert(s4.get("team_pokemon_names") == ["Geodude", "Rhyhorn"], "Stage 4 team must be Geodude and Rhyhorn")
	var s4_rivals = GameData.get_adventure_rival_team(2, 4)
	assert(s4_rivals.size() == 2, "Stage 4 rival team must resolve 2 valid IDs")
	assert(GameData.pokemon_catalog[s4_rivals[0]].name == "Geodude", "Stage 4 PKMN 1 must be Geodude")
	assert(GameData.pokemon_catalog[s4_rivals[1]].name == "Rhyhorn", "Stage 4 PKMN 2 must be Rhyhorn")
	assert(GameData.get_pokemon_id_by_name("Ryhorn") == GameData.get_pokemon_id_by_name("Rhyhorn"), "Ryhorn spelling alias must match Rhyhorn")
	
	# Stage 5: Gym Leader Misty (Staryu, Psyduck, Starmie)
	var s5 = GameData.get_adventure_stage_info(2, 5)
	assert(s5.get("is_boss") == true, "Stage 5 must be boss battle")
	assert(s5.get("badge_name") == "Cascade Badge", "Stage 5 must award Cascade Badge")
	assert(s5.get("trainer_name").contains("Misty"), "Stage 5 trainer name must be Misty")
	assert(s5.get("team_pokemon_names") == ["Staryu", "Psyduck", "Starmie"], "Stage 5 team must be Staryu, Psyduck, and Starmie")
	var s5_rivals = GameData.get_adventure_rival_team(2, 5)
	assert(s5_rivals.size() == 3, "Stage 5 rival team must resolve 3 valid IDs")
	assert(GameData.pokemon_catalog[s5_rivals[0]].name == "Staryu", "Stage 5 PKMN 1 must be Staryu")
	assert(GameData.pokemon_catalog[s5_rivals[1]].name == "Psyduck", "Stage 5 PKMN 2 must be Psyduck")
	assert(GameData.pokemon_catalog[s5_rivals[2]].name == "Starmie", "Stage 5 PKMN 3 must be Starmie")
	
	# Episode 3 structure check (locked until Episode 2 completed)
	var ep3 = GameData.get_adventure_episode_info(3)
	assert(not ep3.is_empty(), "Episode 3 data must exist in ADVENTURE_EPISODES")
	assert(ep3.get("title").contains("Vermilion City Gym"), "Episode 3 title must be Vermilion City Gym")
	print("Test 1 Passed: Episode II & III configuration and rival teams verified.")
	
	# 2. Progression & Unlock Flow
	GameData.create_new_profile("TesterEp2", "Guest", "tester_ep2@frontier.local")
	GameData.tutorial_completed = true
	GameData.tutorial_reward_claimed = true
	
	assert(GameData.is_adventure_episode_unlocked(1), "Episode 1 must be unlocked after tutorial")
	assert(not GameData.is_adventure_episode_unlocked(2), "Episode 2 must be locked initially")
	assert(not GameData.is_adventure_episode_unlocked(3), "Episode 3 must be locked initially")
	
	# Complete Episode 1
	var init_d = GameData.player_diamonds
	var r1 = GameData.complete_adventure_episode(1)
	assert(r1 == 20, "Completing Episode 1 must award 20 diamonds")
	assert(GameData.player_diamonds == init_d + 20, "Player diamonds must increase by 20")
	assert(GameData.is_adventure_episode_completed(1), "Episode 1 must be marked completed")
	assert(GameData.is_adventure_episode_unlocked(2), "Episode 2 must be unlocked after Episode 1 clear")
	assert(not GameData.is_adventure_episode_unlocked(3), "Episode 3 must remain locked after Episode 1 clear")
	print("Test 2 Passed: Episode 1 clear unlocks Episode 2.")
	
	# Complete Episode 2 (first clear)
	var d_before_ep2 = GameData.player_diamonds
	var r2 = GameData.complete_adventure_episode(2)
	assert(r2 == 25, "Completing Episode 2 must award 25 diamonds")
	assert(GameData.player_diamonds == d_before_ep2 + 25, "Player diamonds must increase by 25")
	assert(GameData.is_adventure_episode_completed(2), "Episode 2 must be marked completed")
	assert(GameData.is_adventure_episode_unlocked(3), "Episode 3 must be unlocked after Episode 2 clear")
	print("Test 3 Passed: Episode 2 clear awards 25 diamonds and unlocks Episode 3.")
	
	# Replay Episode 2 (duplicate clear does not award 30 diamonds again)
	var d_after_ep2 = GameData.player_diamonds
	var r2_replay = GameData.complete_adventure_episode(2)
	assert(r2_replay == 0, "Replaying Episode 2 must award 0 bonus diamonds")
	assert(GameData.player_diamonds == d_after_ep2, "Player diamonds must not change on replay")
	print("Test 4 Passed: Episode 2 replay reward prevention verified.")
	
	# 3. Save & Load Persistence
	var save_dict = GameData.get_save_dict()
	assert(save_dict.has("adventure"), "Save dict must contain adventure section")
	assert(save_dict["adventure"]["completed_episodes"].has(2), "Completed episodes in save dict must contain 2")
	assert(save_dict["adventure"]["unlocked_episodes"].has(3), "Unlocked episodes in save dict must contain 3")
	
	GameData.create_new_profile("OtherUserEp2", "Guest", "other_ep2@frontier.local")
	assert(not GameData.is_adventure_episode_unlocked(2), "New profile should have Episode 2 locked")
	GameData.apply_save_dict(save_dict)
	assert(GameData.is_adventure_episode_completed(2), "Loaded profile must restore Episode 2 completion")
	assert(GameData.is_adventure_episode_unlocked(3), "Loaded profile must restore Episode 3 unlocked")
	print("Test 5 Passed: Save and load persistence verified.")
	
	# 4. Main Menu UI Modal Inspection
	var menu_scene = load("res://scenes/main_menu.tscn")
	var menu = menu_scene.instantiate()
	add_child(menu)
	await get_tree().process_frame
	
	var ep_vbox = menu.get_node("AdventureEpisodesModal/Box/EpisodesScroll/EpisodesVBox")
	assert(ep_vbox.get_node_or_null("CardAdventureEp1") != null, "CardAdventureEp1 must exist")
	assert(ep_vbox.get_node_or_null("CardAdventureEp2") != null, "CardAdventureEp2 must exist")
	assert(ep_vbox.get_node_or_null("CardAdventureEp3") != null, "CardAdventureEp3 must exist")
	assert(ep_vbox.get_node_or_null("CardAdventureEp4") != null, "CardAdventureEp4 must exist")
	
	menu.update_adventure_episodes_ui()
	assert(menu.btn_hub_adventure_ep2.disabled == false, "Episode 2 button must be enabled when unlocked")
	assert(menu.btn_hub_adventure_ep3.disabled == false, "Episode 3 button must be enabled when unlocked")
	assert(menu.btn_hub_adventure_ep4.disabled == true, "Episode 4 button must be disabled/locked")
	
	# Test team select for Episode 2
	GameData.campaign_submode = "ADVENTURE"
	GameData.adventure_current_episode = 2
	menu.open_team_select_for_campaign()
	assert(menu.team_select_subtitle.text.contains("Episode II"), "Team select subtitle must mention Episode II")
	print("Test 6 Passed: Main Menu UI cards, buttons, and Episode II team select verified.")
	
	print("=== ALL ADVENTURE EPISODE II TESTS PASSED! ===")
	get_tree().quit(0)
