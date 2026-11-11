extends Node

func _ready() -> void:
	print("=== STARTING STADIUM, MOVES & POKEDEX TEST SUITE ===")
	GameData.load_moves_from_csv()
	GameData.load_pokemon_from_csv()
	
	test_stadium_and_chaos_red_gyarados_exclusion()
	test_booster_pack_red_gyarados_exclusion()
	test_move_rebalance_and_status_chances()
	test_charge_dmg_boost_in_battle()
	test_pokedex_ui_and_lobby_icon()
	
	print("=== ALL STADIUM, MOVES & POKEDEX TESTS PASSED! ===")
	get_tree().quit(0)

func test_stadium_and_chaos_red_gyarados_exclusion() -> void:
	assert(not GameData.is_valid_tournament_rival_id(GameData.RED_GYARADOS_CARD_ID), "Red Gyarados (494) must be banned in Stadium")
	assert(not GameData.is_valid_tournament_rival_id(GameData.RED_GYARADOS_BOSS_ID), "Red Gyarados Boss (495) must be banned in Stadium")
	assert(not GameData.is_valid_tournament_rival_id(GameData.CRYSTAL_ONIX_ID), "Crystal Onix (493) must be banned in Stadium")
	assert(not GameData.is_valid_tournament_rival_id(165), "Mewtwo (165) must be banned in Stadium")
	assert(not GameData.is_valid_tournament_rival_id(492), "Arceus (492) must be banned in Stadium")
	
	var pool = GameData.get_tournament_candidates("any", "any", [])
	assert(not (GameData.RED_GYARADOS_CARD_ID in pool), "Red Gyarados must NOT appear in Stadium candidates")
	assert(not (GameData.RED_GYARADOS_BOSS_ID in pool), "Red Gyarados Boss must NOT appear in Stadium candidates")
	assert(not (GameData.CRYSTAL_ONIX_ID in pool), "Crystal Onix must NOT appear in Stadium candidates")
	for pid in pool:
		var d = GameData.pokemon_catalog.get(pid, {})
		var r = str(d.get("rarity", "")).strip_edges().to_lower()
		var st = str(d.get("stage", "")).strip_edges().to_lower()
		var tier = str(d.get("tier", "")).strip_edges().to_upper()
		assert(not (r in ["legendary", "legendaria", "legendario", "ur", "ultra rare", "boss", "special"]), "Legendary/Boss rarity leaked in Stadium pool: %s" % d.get("name"))
		assert(not (st in ["legendary", "boss", "special"]), "Legendary/Boss stage leaked in Stadium pool: %s" % d.get("name"))
		assert(not (tier in ["S", "S+", "SS", "SSS"]), "Tier S+ leaked in Stadium pool: %s" % d.get("name"))
	
	# Stale cached rival team containing Red Gyarados must auto-regenerate
	GameData.current_tournament_rival_match = 1
	GameData.current_tournament_rival_team = [GameData.RED_GYARADOS_CARD_ID]
	var sanitized_team = GameData.get_campaign_rival_team(1)
	assert(not (GameData.RED_GYARADOS_CARD_ID in sanitized_team), "Cached Stadium team must sanitize Red Gyarados!")
	assert(GameData.is_valid_tournament_rival_id(sanitized_team[0]), "Sanitized team must be legal")
	
	var chaos_legs = GameData.get_chaos_legendary_candidates()
	assert(not (GameData.RED_GYARADOS_CARD_ID in chaos_legs), "Red Gyarados must NOT appear in Chaos encounters")
	assert(not (GameData.RED_GYARADOS_BOSS_ID in chaos_legs), "Red Gyarados Boss must NOT appear in Chaos encounters")
	assert(not (GameData.CRYSTAL_ONIX_ID in chaos_legs), "Crystal Onix must NOT appear in regular Chaos legendary pool")
	print("✓ Stadium & Chaos exclusions verified.")

func test_booster_pack_red_gyarados_exclusion() -> void:
	GameData.player_diamonds = 1000
	for _i in range(40):
		var cards = GameData.open_booster_pack("Johto")
		for c in cards:
			var cid = int(c.get("id", -1))
			assert(not (cid in [GameData.CRYSTAL_ONIX_ID, GameData.RED_GYARADOS_CARD_ID, GameData.RED_GYARADOS_BOSS_ID]), "Exclusive boss/event card leaked from Booster Pack: %d" % cid)
	print("✓ Johto Booster Pack exclusion verified.")

func _make_move(move_name: String) -> GameData.MoveData:
	var md = GameData.get_move_data(move_name)
	var m = GameData.MoveData.new(
		md["name"], md["type"], md["dmg"], md["cost"], md["req"],
		md["boost_cost"] > 0, md["boost_cost"], md["boost_dmg"],
		md["effect_type"] == "BURN", md["desc"]
	)
	m.effect_type = md["effect_type"]
	return m

func test_move_rebalance_and_status_chances() -> void:
	var checks = [
		{"name": "Hyper Beam", "cost": 5, "req": 5, "dmg": 25, "eff": "REST"},
		{"name": "Giga Impact", "cost": 5, "req": 5, "dmg": 25, "eff": "REST"},
		{"name": "Mind Bending", "cost": 5, "req": 5, "dmg": 25, "eff": "REST"},
		{"name": "Hammer Arm", "cost": 3, "req": 2, "dmg": 14, "eff": "SLOW_USER"},
		{"name": "Judgment", "cost": 4, "req": 3, "dmg": 16, "eff": "DOUBLE_DMG"},
		{"name": "Signal Beam", "cost": 2, "req": 1, "dmg": 8, "eff": "CONFUSION"},
		{"name": "Thunder Wave", "cost": 1, "req": 1, "dmg": 0, "eff": "PARALYZE"},
		{"name": "Dragon Breath", "cost": 2, "req": 1, "dmg": 6, "eff": "PARALYZE"},
		{"name": "Charge", "cost": 1, "req": 1, "dmg": 0, "eff": "DMG_BOOST"},
		{"name": "Ice Shard", "cost": 2, "req": 1, "dmg": 6, "eff": "SPEED_UP"},
		{"name": "Horn Attack", "cost": 2, "req": 1, "dmg": 8, "eff": "SHIELD_BREAKER"},
		{"name": "Venom Drench", "cost": 1, "req": 1, "dmg": 0, "eff": "WEAKEN"},
		{"name": "Confuse Ray", "cost": 1, "req": 1, "dmg": 0, "eff": "CONFUSION"},
		{"name": "Flatter", "cost": 1, "req": 1, "dmg": 0, "eff": "CONFUSION"},
		{"name": "Confusion", "cost": 3, "req": 1, "dmg": 12, "eff": "CONFUSION"},
		{"name": "Thunder Fang", "cost": 3, "req": 1, "dmg": 12, "eff": "PARALYZE"},
		{"name": "Lick", "cost": 1, "req": 1, "dmg": 3, "eff": "PARALYZE"},
	]
	for ch in checks:
		var m = GameData.get_move_data(ch["name"])
		assert(not m.is_empty(), "Move missing: %s" % ch["name"])
		assert(int(m["cost"]) == ch["cost"], "%s cost mismatch: got %d expected %d" % [ch["name"], int(m["cost"]), ch["cost"]])
		assert(int(m["req"]) == ch["req"], "%s req mismatch: got %d expected %d" % [ch["name"], int(m["req"]), ch["req"]])
		assert(int(m["dmg"]) == ch["dmg"], "%s dmg mismatch: got %d expected %d" % [ch["name"], int(m["dmg"]), ch["dmg"]])
		assert(str(m["effect_type"]) == ch["eff"], "%s eff mismatch: got %s expected %s" % [ch["name"], str(m["effect_type"]), ch["eff"]])
		
	var battle_scene = load("res://scenes/battle.tscn").instantiate()
	add_child(battle_scene)
	var tw = _make_move("Thunder Wave")
	var db = _make_move("Dragon Breath")
	var sb = _make_move("Signal Beam")
	var lk = _make_move("Lick")
	var cf = _make_move("Confusion")
	var tf = _make_move("Thunder Fang")
	assert(is_equal_approx(battle_scene._get_status_proc_chance(tw, false, false), 1.0), "Thunder Wave should be 100% paralyze")
	assert(is_equal_approx(battle_scene._get_status_proc_chance(db, false, false), 0.30), "Dragon Breath should be 30% paralyze")
	assert(is_equal_approx(battle_scene._get_status_proc_chance(sb, false, false), 0.30), "Signal Beam should be 30% confusion")
	assert(is_equal_approx(battle_scene._get_status_proc_chance(lk, false, false), 0.30), "Lick should be 30% paralyze")
	assert(is_equal_approx(battle_scene._get_status_proc_chance(cf, false, false), 0.30), "Confusion should be 30% confusion")
	assert(is_equal_approx(battle_scene._get_status_proc_chance(tf, false, false), 0.30), "Thunder Fang should be 30% paralyze")
	battle_scene.queue_free()
	print("✓ All move costs, damages, effects, and proc chances verified.")

func test_charge_dmg_boost_in_battle() -> void:
	var battle_scene = load("res://scenes/battle.tscn").instantiate()
	add_child(battle_scene)
	battle_scene.start_new_game()
	var zapdos = GameData.create_pokemon_instance(160) # Zapdos: Charge + Discharge
	zapdos.current_energy = 5
	var target = GameData.create_pokemon_instance(7) # Squirtle
	battle_scene.player_team = [zapdos]
	battle_scene.enemy_team = [target]
	battle_scene.active_player_idx = 0
	battle_scene.active_enemy_idx = 0
	
	var charge_move = zapdos.moves[0]
	assert(charge_move.name == "Charge", "Zapdos move1 expected Charge, got %s" % charge_move.name)
	battle_scene.perform_attack(zapdos, target, charge_move, false, 1, battle_scene.player_card_img, battle_scene.enemy_card_img)
	assert(zapdos.damage_buff == 6, "Charge must apply +6 DMG buff! Got %d" % zapdos.damage_buff)
	assert(not target.is_paralyzed, "Charge must NOT paralyze anymore!")
	battle_scene.queue_free()
	print("✓ Charge DMG_BOOST (+6 DMG, no paralyze) verified in combat.")

func test_pokedex_ui_and_lobby_icon() -> void:
	var menu = load("res://scenes/main_menu.tscn").instantiate()
	add_child(menu)
	
	assert(menu.btn_collection != null, "btn_collection must exist")
	assert(menu.btn_shop != null, "btn_shop must exist")
	assert(menu.btn_collection.text == "", "Lobby PokeDex button must have NO text, got '%s'" % menu.btn_collection.text)
	assert(menu.btn_shop.text == "", "Lobby PokeMart button must have NO text, got '%s'" % menu.btn_shop.text)
	assert(menu.btn_collection.custom_minimum_size == Vector2(74, 74), "Lobby PokeDex button should be 74x74 round medallion, got %s" % str(menu.btn_collection.custom_minimum_size))
	assert(menu.btn_shop.custom_minimum_size == Vector2(74, 74), "Lobby PokeMart button should be 74x74 round medallion, got %s" % str(menu.btn_shop.custom_minimum_size))
	assert(menu.btn_collection.icon.resource_path == "res://assets/ui/pokedex.png", "Expected pokedex.png icon, got '%s'" % menu.btn_collection.icon.resource_path)
	assert(menu.btn_shop.icon.resource_path == "res://assets/ui/pokemart.png", "Expected pokemart.png icon, got '%s'" % menu.btn_shop.icon.resource_path)
	assert(menu.btn_collection.get_parent().name == "FeatureIconsRow" and menu.btn_shop.get_parent() == menu.btn_collection.get_parent(), "PokéDex and PokéMart must sit together in FeatureIconsRow")
	var menu_buttons = menu.get_node("ContentContainer/MenuButtons")
	assert(menu.btn_collection.get_parent().get_index() == menu_buttons.get_child_count() - 1, "FeatureIconsRow (PokéDex & PokéMart) must be at the end of MenuButtons")
	assert(menu.btn_daily_missions.get_parent().name == "ProgressRow" and menu.btn_achievements.get_parent() == menu.btn_daily_missions.get_parent(), "Daily Missions and Achievements must share ProgressRow")
	assert(menu.btn_daily_missions.custom_minimum_size.y == 44 and menu.btn_achievements.custom_minimum_size.y == 44, "Daily Missions and Achievements must be compact (44px tall)")
	for pair in [[menu.btn_collection, "PokedexHoverPill", "PokéDex"], [menu.btn_shop, "ShopHoverPill", "PokéMart"]]:
		var btn_node = pair[0]
		var pill = btn_node.get_node_or_null(pair[1]) as PanelContainer
		assert(pill != null, "%s must exist" % pair[1])
		assert(pill.visible == false, "%s should be hidden until hover" % pair[1])
		btn_node.mouse_entered.emit()
		assert(pill.visible == true, "%s must pop up on hover" % pair[1])
		assert((pill.get_node("Label") as Label).text == pair[2], "%s label mismatch" % pair[1])
		btn_node.mouse_exited.emit()
		assert(pill.visible == false, "%s must hide on mouse exit" % pair[1])
	
	var title_lbl = menu.get_node_or_null("CollectionModal/GridView/Title") as Label
	assert(title_lbl != null, "CollectionModal/GridView/Title must exist")
	assert("POKÉDEX" in title_lbl.text.to_upper() or "POKEDEX" in title_lbl.text.to_upper(), "Modal title must say PokéDex, got '%s'" % title_lbl.text)
	
	var loc = load("res://scripts/localization.gd")
	assert(loc.translate_en_to_es("📖 View in PokéDex") == "📖 Ver en la PokéDex", "Spanish translation of View in PokéDex mismatch")
	menu.queue_free()
	print("✓ PokéDex UI title & Lobby icon button verified.")
