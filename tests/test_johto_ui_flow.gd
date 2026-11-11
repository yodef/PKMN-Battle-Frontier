extends Node

func _ready() -> void:
	print("=== RUNNING TEST: JOHTO UI FLOW IN MAIN MENU ===")
	
	GameData.tutorial_completed = true
	GameData.adventure_completed_episodes.clear()
	GameData.adventure_unlocked_episodes.clear()
	GameData.lake_of_rage_completed = false
	
	var main_menu_scene = load("res://scenes/main_menu.tscn")
	var main_menu = main_menu_scene.instantiate()
	add_child(main_menu)
	await get_tree().process_frame
	await get_tree().process_frame
	
	print("\n--- Test 1: Adventure Regions Modal Johto Button ---")
	main_menu.update_adventure_regions_ui()
	assert(main_menu.btn_enter_johto != null, "btn_enter_johto should exist")
	assert(not main_menu.btn_enter_johto.disabled, "btn_enter_johto should be enabled")
	print("✓ Johto region button is properly unlocked in Adventure Regions UI")
	
	print("\n--- Test 2: Johto Episodes Modal Generation ---")
	main_menu._open_johto_episodes_modal()
	assert(main_menu.johto_episodes_modal != null, "johto_episodes_modal should be created")
	assert(main_menu.johto_episodes_modal.visible, "johto_episodes_modal should be visible")
	assert(main_menu.johto_episode_cards.size() == 8, "Must have 8 episode cards for Johto")
	assert(not main_menu.johto_lake_of_rage_card.is_empty(), "Lake of Rage card must exist")
	assert(main_menu.johto_episode_cards[101]["rewards"].text.contains("15 Diamantes"), "Ep 101 UI must show 15 Diamantes")
	assert(main_menu.johto_episode_cards[106]["rewards"].text.contains("5 Combates") and main_menu.johto_episode_cards[106]["rewards"].text.contains("30 Diamantes"), "Ep 106 UI must show 5 Combates & 30 Diamantes")
	assert(main_menu.johto_episode_cards[107]["rewards"].text.contains("4 Combates") and main_menu.johto_episode_cards[107]["rewards"].text.contains("25 Diamantes"), "Ep 107 UI must show 4 Combates & 25 Diamantes")
	assert(main_menu.johto_episode_cards[108]["rewards"].text.contains("5 Combates") and main_menu.johto_episode_cards[108]["rewards"].text.contains("35 Diamantes"), "Ep 108 UI must show 5 Combates & 35 Diamantes")
	assert(main_menu.johto_lake_of_rage_card["rewards"].text.contains("30 Diamantes"), "Lake of Rage UI must show 30 Diamantes")
	print("✓ Johto episodes modal created with 8 episode cards + Lake of Rage card and accurate UI reward/battle counts")
	
	print("\n--- Test 3: Episode 101 Unlocked & Lake of Rage Locked (Initial) ---")
	var ep101_card = main_menu.johto_episode_cards[101]
	var btn101 = ep101_card["btn"] as Button
	assert(not btn101.disabled, "Episode 101 button should be enabled initially")
	
	var lake_card = main_menu.johto_lake_of_rage_card
	var lake_btn = lake_card["btn"] as Button
	assert(lake_btn.disabled, "Lake of Rage button should be disabled with 0 badges")
	print("✓ Episode 101 is available and Lake of Rage is safely locked initially")
	
	print("\n--- Test 4: Branching Routes Modal (Episode 106, 107, 108) ---")
	main_menu._open_johto_branching_routes_modal(106)
	assert(main_menu.johto_routes_modal != null, "johto_routes_modal should be instantiated")
	assert(main_menu.johto_routes_modal.visible, "johto_routes_modal should be visible")
	var ep106_routes = main_menu.johto_routes_scroll_vbox.get_children()
	assert(ep106_routes.size() == 3, "Episode 106 should have 3 routes (subway, radio_tower, olivine_gym)")
	print("✓ Episode 106 routes modal verified (3 routes rendered)")
	
	main_menu._open_johto_branching_routes_modal(107)
	var ep107_routes = main_menu.johto_routes_scroll_vbox.get_children()
	assert(ep107_routes.size() == 2, "Episode 107 should have 2 routes (rocket_hideout, mahogany_gym)")
	print("✓ Episode 107 routes modal verified (2 routes rendered)")
	
	main_menu._open_johto_branching_routes_modal(108)
	var ep108_routes = main_menu.johto_routes_scroll_vbox.get_children()
	assert(ep108_routes.size() == 3, "Episode 108 should have 3 routes (ice_path, blackthorn_gym, dragon_den)")
	print("✓ Episode 108 routes modal verified (3 routes rendered)")
	
	print("\n--- Test 5: Lake of Rage Unlock with 8 Johto Badges ---")
	for ep in [101, 102, 103, 104, 105, 106, 107, 108]:
		GameData.adventure_completed_episodes.append(ep)
	assert(GameData.has_all_johto_gym_badges(), "All Johto gym badges should now be conquered")
	
	main_menu._open_johto_episodes_modal()
	main_menu._refresh_johto_episodes_ui()
	assert(not lake_btn.disabled, "Lake of Rage button should now be enabled with 8 badges")
	
	main_menu._start_lake_of_rage_event()
	assert(GameData.campaign_submode == "LAKE_OF_RAGE", "campaign_submode must be LAKE_OF_RAGE")
	assert(main_menu.team_select_modal.visible, "team_select_modal should be visible for Lake of Rage")
	print("✓ Lake of Rage properly unlocks with 8 badges and opens team selection")
	
	print("\n=== ALL JOHTO UI FLOW TESTS PASSED PERFECTLY! ===")
	get_tree().quit(0)
