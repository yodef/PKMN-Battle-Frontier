extends Node

func _ready() -> void:
	print("=== STARTING TOURNAMENT BALANCE & CAMP UI TESTS ===")
	
	test_tournament_rival_tiers_and_legendaries()
	test_tournament_rewards()
	await test_camp_ui_layout_and_scrollbar()
	
	print("=== ALL TOURNAMENT TESTS PASSED SUCCESSFULLY! ===")
	get_tree().quit(0)

func test_tournament_rival_tiers_and_legendaries() -> void:
	print("\n--- Testing Tournament Rival Tiers (100 runs per match) ---")
	var banned_ids_count = 0
	var legendary_count = 0
	var tier_s_count = 0
	var total_pokemon_checked = 0
	
	for m in range(1, 10):
		var match_info = GameData.get_tournament_match_info(m)
		print("Checking Match %d (%s)..." % [m, match_info.get("phase_name", "")])
		for run in range(100):
			var team = GameData.generate_tournament_rival_team(m)
			assert(team.size() > 0, "Match %d produced empty team!" % m)
			
			# Check uniqueness
			var unique_ids = []
			for id in team:
				assert(not (id in unique_ids), "Duplicate ID %d in rival team for Match %d!" % [id, m])
				unique_ids.append(id)
				
				# Check tier & legendary
				var d = GameData.pokemon_catalog.get(id, {})
				var r = str(d.get("rarity", "")).strip_edges().to_lower()
				var st = str(d.get("stage", "")).strip_edges().to_lower()
				var tier = str(d.get("tier", "C")).strip_edges().to_upper()
				
				total_pokemon_checked += 1
				
				if r in ["legendary", "legendaria", "legendario", "ur", "ultra rare"] or st == "legendary":
					legendary_count += 1
					printerr("VIOLATION: Legendary %s (ID %d) in Match %d!" % [d.get("name"), id, m])
					
				if tier in ["S", "S+", "SS", "SSS"]:
					tier_s_count += 1
					printerr("VIOLATION: Tier %s Pokemon %s (ID %d) in Match %d!" % [tier, d.get("name"), id, m])
					
				assert(not (r in ["legendary", "legendaria", "legendario", "ur", "ultra rare"]), "Legendary found!")
				assert(not (tier in ["S", "S+"]), "Tier S/S+ found!")
				assert(tier in ["D", "C", "B", "A"], "Unknown tier: " + tier)
				
	print("Verified %d total Pokemon across 900 simulated matches:" % total_pokemon_checked)
	print("Legendaries found: %d (MUST BE 0)" % legendary_count)
	print("Tier S/S+ found: %d (MUST BE 0)" % tier_s_count)
	assert(legendary_count == 0, "Legendaries must be 0")
	assert(tier_s_count == 0, "Tier S/S+ must be 0")
	print("✓ STRICT < Tier S and NO Legendaries confirmed!")

func test_tournament_rewards() -> void:
	print("\n--- Testing Tournament Diamond & Gold Rewards ---")
	var total_gold = 0
	var total_diamonds = 0
	for m in range(1, 10):
		var info = GameData.get_tournament_match_info(m)
		var g = int(info.get("reward_gold", 0))
		var d = int(info.get("reward_diamonds", 0))
		total_gold += g
		total_diamonds += d
		print("Match %d: Gold = %d G, Diamonds = %d 💎 (%s)" % [m, g, d, info.get("desc", "")])
		assert(d > 0, "Match %d must award diamonds!" % m)
		assert(g > 0, "Match %d must award gold!" % m)
	print("Total Guaranteed Tournament Rewards: %d Gold, %d Diamonds" % [total_gold, total_diamonds])
	assert(total_diamonds >= 50, "Total guaranteed diamonds should be generous (>= 50)!")
	print("✓ Diamond rewards verified!")

func test_camp_ui_layout_and_scrollbar() -> void:
	print("\n--- Testing Camp UI Layout & Scrollbar Removal ---")
	
	# Setup sample team matching user situation (Doduo, Farfetch'd, Electabuzz)
	var doduo_id = 88
	var farfetch_id = 87
	var electabuzz_id = 137
	
	for id in GameData.all_pokemon_ids:
		var n = GameData.pokemon_catalog.get(id, {}).get("name", "").to_lower()
		if n == "doduo": doduo_id = id
		elif n == "farfetch'd" or n == "farfetchd": farfetch_id = id
		elif n == "electabuzz": electabuzz_id = id
		
	GameData.campaign_player_team_state.clear()
	for cid in [doduo_id, farfetch_id, electabuzz_id]:
		var inst = GameData.create_pokemon_instance(cid)
		GameData.campaign_player_team_state.append({
			"id": cid,
			"name": inst.name,
			"stage": inst.stage,
			"type": inst.type,
			"current_hp": inst.max_hp,
			"max_hp": inst.max_hp,
			"speed": inst.speed,
			"texture_path": inst.texture_path,
			"current_exp": 0,
			"is_poisoned": false,
			"burn_turns": 0
		})
		
	# Doduo fainted and ready for Dodrio
	GameData.campaign_player_team_state[0]["current_hp"] = 0
	GameData.campaign_player_team_state[0]["current_exp"] = 10
	# Farfetch'd fainted
	GameData.campaign_player_team_state[1]["current_hp"] = 0
	GameData.campaign_player_team_state[1]["current_exp"] = 0
	# Electabuzz healthy
	GameData.campaign_player_team_state[2]["current_hp"] = 19
	GameData.campaign_player_team_state[2]["current_exp"] = 16
	
	GameData.campaign_match_number = 4
	GameData.campaign_submode = "TOURNAMENT"
	GameData.campaign_gold = 30
	GameData.player_diamonds = 0
	
	var menu_scene = load("res://scenes/main_menu.tscn").instantiate()
	add_child(menu_scene)
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	menu_scene._setup_camp_modals()
	if menu_scene.login_modal: menu_scene.login_modal.visible = false
	menu_scene.campaign_modal.visible = true
	menu_scene.update_campaign_ui()
	
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.3).timeout
	
	var box = menu_scene.campaign_modal.get_node("Box")
	var team_scroll = box.get_node("TeamScroll")
	var team_list = team_scroll.get_node("TeamList")
	var h_bar = team_scroll.get_h_scroll_bar()
	var v_bar = team_scroll.get_v_scroll_bar()
	
	print("TeamScroll size: ", team_scroll.size)
	print("TeamList size: ", team_list.size)
	print("TeamScroll horizontal_scroll_mode: ", team_scroll.horizontal_scroll_mode)
	print("HBar visible: ", h_bar.visible if h_bar else false)
	print("VBar visible: ", v_bar.visible if v_bar else false)
	
	assert(team_scroll.horizontal_scroll_mode == ScrollContainer.SCROLL_MODE_DISABLED, "Horizontal scroll must be DISABLED!")
	assert(not h_bar.visible, "Horizontal scrollbar must NOT be visible!")
	assert(not v_bar.visible, "Vertical scrollbar must NOT be visible!")
	
	# Verify children cards
	var cards = team_list.get_children()
	assert(cards.size() == 3, "Expected 3 pokemon cards, found %d" % cards.size())
	for i in range(cards.size()):
		var c = cards[i]
		print("Card %d size: %s" % [i, c.size])
		
	# Capture screenshot
	var img = get_viewport().get_texture().get_image()
	if img:
		var art_dir = "C:/Users/rafag/.gemini/antigravity/brain/dca5182f-4733-4c52-8dfc-ccfff3b26dd9"
		var shot_path = art_dir + "/tournament_camp_fixed_no_scrollbar.png"
		img.save_png(shot_path)
		print("Screenshot saved to: ", shot_path)
	
	print("✓ Camp UI layout and scrollbar removal verified!")
