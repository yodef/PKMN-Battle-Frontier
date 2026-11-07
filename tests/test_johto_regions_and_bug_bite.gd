extends Node

func _ready():
	print("=== TEST: Bug Bite + Johto Starters + Region Filters ===")
	var all_p = GameData.pokemon_catalog
	print("Total Pokemon loaded: ", all_p.size())
	assert(all_p.size() == 257, "Expected 257 Pokemon (Kanto 151 + Johto 100 + Other 6), got " + str(all_p.size()))
	
	# 1. Verify Bug Bite in GameData.moves_catalog and on Caterpie
	var bug_bite = GameData.moves_catalog.get("bug bite", null)
	assert(bug_bite != null, "Bug Bite should exist in moves_catalog")
	print("Bug Bite -> dmg:", bug_bite.get("dmg"), " cost:", bug_bite.get("cost"), " boost_cost:", bug_bite.get("boost_cost"), " effect:", bug_bite.get("effect_type"))
	assert(int(bug_bite.get("dmg", 0)) == 3, "Bug Bite dmg should be 3")
	assert(int(bug_bite.get("cost", 0)) == 1, "Bug Bite cost should be 1")
	assert(int(bug_bite.get("boost_cost", 0)) == 1, "Bug Bite boost_cost should be 1")
	assert(str(bug_bite.get("effect_type", "")) == "FLINCH", "Bug Bite effect_type should be FLINCH")
	
	var caterpie = GameData.create_pokemon_instance(10)
	assert(caterpie != null, "Caterpie instance should exist")
	var cat_bb = null
	for m in caterpie.moves:
		if m.name == "Bug Bite":
			cat_bb = m
	assert(cat_bb != null, "Caterpie should have Bug Bite")
	assert(cat_bb.base_damage == 3, "Caterpie Bug Bite base_damage should be 3")
	assert(cat_bb.cost == 1, "Caterpie Bug Bite cost should be 1")
	assert(cat_bb.can_boost == true, "Caterpie Bug Bite should have can_boost == true")
	assert(cat_bb.boost_cost == 1, "Caterpie Bug Bite boost_cost should be 1")
	assert(cat_bb.effect_type == "FLINCH", "Caterpie Bug Bite effect_type should be FLINCH")
	
	# 2. Verify Johto starters and evolution chains
	var johto_expected = {
		"Chikorita": {"id": 167, "evolves_to": "Bayleef", "region": "Johto"},
		"Bayleef": {"id": 168, "evolves_to": "Meganium", "region": "Johto"},
		"Meganium": {"id": 169, "evolves_to": "", "region": "Johto"},
		"Cyndaquil": {"id": 170, "evolves_to": "Quilava", "region": "Johto"},
		"Quilava": {"id": 171, "evolves_to": "Typhlosion", "region": "Johto"},
		"Typhlosion": {"id": 172, "evolves_to": "", "region": "Johto"},
		"Totodile": {"id": 173, "evolves_to": "Croconaw", "region": "Johto"},
		"Croconaw": {"id": 174, "evolves_to": "Feraligatr", "region": "Johto"},
		"Feraligatr": {"id": 175, "evolves_to": "", "region": "Johto"}
	}
	for p_name in johto_expected.keys():
		var pid: int = johto_expected[p_name]["id"]
		var inst = GameData.create_pokemon_instance(pid)
		assert(inst != null, p_name + " should exist in GameData")
		assert(inst.name == p_name, "Expected name " + p_name + ", got " + inst.name)
		assert(inst.evolves_to == johto_expected[p_name]["evolves_to"], p_name + " evolves_to mismatch: got '" + inst.evolves_to + "'")
		assert(inst.region == johto_expected[p_name]["region"], p_name + " region mismatch: got '" + inst.region + "'")
		assert(ResourceLoader.exists(inst.texture_path), p_name + " card sprite should exist at " + inst.texture_path)
	print("All 9 Johto starter cards verified with valid sprites and evolution chains!")
	
	# 3. Verify Main Menu Region Filters (My Collection & Hidden Shop)
	var menu_scene = load("res://scenes/main_menu.tscn")
	var menu = menu_scene.instantiate()
	add_child(menu)
	await get_tree().process_frame
	
	# Collection default region is KANTO
	assert(menu.col_filter_region == "KANTO", "Default collection region should be KANTO")
	var kanto_cards = menu.get_filtered_collection_cards()
	print("Collection KANTO count: ", kanto_cards.size())
	assert(kanto_cards.size() == 151, "Expected 151 Kanto cards, got " + str(kanto_cards.size()))
	
	menu._on_col_region_pressed("JOHTO")
	var johto_cards = menu.get_filtered_collection_cards()
	print("Collection JOHTO count: ", johto_cards.size())
	assert(johto_cards.size() == 100, "Expected 100 Johto cards, got " + str(johto_cards.size()))
	
	menu._on_col_region_pressed("OTHER")
	var other_cards = menu.get_filtered_collection_cards()
	print("Collection OTHER count: ", other_cards.size())
	assert(other_cards.size() == 6, "Expected 6 Other cards, got " + str(other_cards.size()))
	
	menu._on_col_region_pressed("ALL")
	var all_cards = menu.get_filtered_collection_cards()
	print("Collection ALL count: ", all_cards.size())
	assert(all_cards.size() == 257, "Expected 257 All cards, got " + str(all_cards.size()))
	
	# Hidden shop region filtering
	assert(menu.hidden_shop_region == "KANTO", "Default Hidden Shop region should be KANTO")
	menu._populate_hidden_shop_view()
	print("Hidden Shop KANTO grid count: ", menu.hidden_shop_grid.get_child_count())
	assert(menu.hidden_shop_grid.get_child_count() == 151, "Hidden Shop KANTO should have 151 cards")
	
	menu.hidden_region_buttons["JOHTO"].pressed.emit()
	print("Hidden Shop JOHTO grid count: ", menu.hidden_shop_grid.get_child_count())
	assert(menu.hidden_shop_grid.get_child_count() == 100, "Hidden Shop JOHTO should have 100 cards")
	
	menu.hidden_region_buttons["OTHER"].pressed.emit()
	print("Hidden Shop OTHER grid count: ", menu.hidden_shop_grid.get_child_count())
	assert(menu.hidden_shop_grid.get_child_count() == 6, "Hidden Shop OTHER should have 6 cards")
	
	# 4. Verify region labels have no leading icons
	assert(menu.col_region_buttons["KANTO"].text.begins_with("Kanto ("), "Col KANTO button should start with 'Kanto (' (got '%s')" % menu.col_region_buttons["KANTO"].text)
	assert(menu.col_region_buttons["JOHTO"].text.begins_with("Johto ("), "Col JOHTO button should start with 'Johto (' (got '%s')" % menu.col_region_buttons["JOHTO"].text)
	assert(menu.col_region_buttons["OTHER"].text.begins_with("Other ("), "Col OTHER button should start with 'Other (' (got '%s')" % menu.col_region_buttons["OTHER"].text)
	assert(menu.col_region_buttons["ALL"].text.begins_with("All ("), "Col ALL button should start with 'All (' (got '%s')" % menu.col_region_buttons["ALL"].text)
	assert(menu.hidden_region_buttons["KANTO"].text.begins_with("Kanto ("), "Hidden Shop KANTO button should start with 'Kanto ('")
	assert(menu.hidden_region_buttons["JOHTO"].text.begins_with("Johto ("), "Hidden Shop JOHTO button should start with 'Johto ('")
	assert(menu.hidden_region_buttons["OTHER"].text.begins_with("Other ("), "Hidden Shop OTHER button should start with 'Other ('")
	assert(menu.hidden_region_buttons["ALL"].text.begins_with("All ("), "Hidden Shop ALL button should start with 'All ('")
	
	print("=== ALL TESTS PASSED! ===")
	get_tree().quit(0)
