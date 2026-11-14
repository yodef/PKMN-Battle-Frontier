extends Node

func _ids_of(pool: Array) -> Array:
	var out = []
	for c in pool:
		out.append(int(c["id"]))
	return out

func _ready() -> void:
	print("\n=== TEST: TEAM SELECT REGION TABS + SEARCH / POKÉDEX SEARCH ===")
	var menu = load("res://scenes/main_menu.tscn").instantiate()
	add_child(menu)

	GameData.player_unlocked_ids = []
	var names = ["Bulbasaur", "Charmander", "Pikachu", "Chikorita", "Cyndaquil"]
	var by_name = {}
	for p_id in GameData.pokemon_catalog.keys():
		var nm = str(GameData.pokemon_catalog[p_id].get("name", ""))
		if nm in names and not by_name.has(nm):
			GameData.unlock_pokemon(p_id)
			by_name[nm] = int(p_id)
	assert(by_name.size() == 5, "Test Pokémon must exist in catalog")

	menu._on_login_play_pressed()
	GameData.is_pvp_mode = false
	menu._on_quick_battle_pressed()
	await get_tree().process_frame
	await get_tree().create_timer(0.1).timeout

	assert(menu.team_filters_box != null and menu.team_filters_box.is_inside_tree(), "Filters box must exist in TeamSelectModal")
	assert(menu.team_region_buttons.size() == 5, "Region tabs must exist")
	assert(menu.current_sorted_team_pool.size() == 5, "ALL tab shows every unlocked card")

	menu._on_team_region_pressed("JOHTO")
	var ids = _ids_of(menu.current_sorted_team_pool)
	assert(ids.size() == 2 and by_name["Chikorita"] in ids and by_name["Cyndaquil"] in ids, "Johto tab shows only Johto cards: %s" % str(ids))
	menu._on_team_region_pressed("KANTO")
	assert(menu.current_sorted_team_pool.size() == 3, "Kanto tab shows 3 cards")
	print("✓ Region tabs filter team pool")

	menu._on_team_region_pressed("ALL")
	menu._on_team_search_changed("pika")
	ids = _ids_of(menu.current_sorted_team_pool)
	assert(ids == [by_name["Pikachu"]], "Name search must find Pikachu: %s" % str(ids))
	var pika_dex = int(GameData.pokemon_catalog[by_name["Pikachu"]].get("pokedex_num", 25))
	menu._on_team_search_changed("#%d" % pika_dex)
	ids = _ids_of(menu.current_sorted_team_pool)
	assert(by_name["Pikachu"] in ids, "Dex number search must find Pikachu: %s" % str(ids))
	menu._on_team_search_changed("zzzz")
	assert(menu.current_sorted_team_pool.is_empty(), "No-match search empties grid")

	# Selection persists across filters
	menu._on_team_search_changed("")
	menu.toggle_pokemon_selection(by_name["Bulbasaur"])
	menu._on_team_region_pressed("JOHTO")
	assert(by_name["Bulbasaur"] in menu.selected_player_ids, "Selection persists when switching region")
	menu._on_team_region_pressed("ALL")
	print("✓ Search by name / Pokédex # works in team select")

	# PokéDex (collection) search
	menu._on_collection_pressed()
	await get_tree().process_frame
	assert(menu.col_search_edit != null, "Collection search box must exist")
	menu.col_filter_region = "ALL"
	menu.col_search_query = "chikor"
	var col = menu.get_filtered_collection_cards()
	assert(col.size() >= 1, "Collection search finds Chikorita")
	for c in col:
		assert(str(c.get("name", "")).to_lower().contains("chikor") or str(c.get("short_name", "")).to_lower().contains("chikor"), "Only matching cards")
	menu._on_reset_collection_filters_pressed()
	assert(menu.col_search_query == "", "Reset clears search")
	print("✓ PokéDex search works")

	print("=== ALL REGION TAB / SEARCH TESTS PASSED ===")
	get_tree().quit()
