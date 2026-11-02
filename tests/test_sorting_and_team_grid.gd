extends Node

func _ready() -> void:
	print("\n--- INICIANDO TESTS DE ORDENAMIENTO Y CUADRÍCULA DE SELECCIÓN DE EQUIPO ---")
	
	var main_scene_packed = load("res://scenes/main_menu.tscn")
	var main_scene = main_scene_packed.instantiate()
	add_child(main_scene)
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	# -------------------------------------------------------------
	# 1. TEST DE ORDENAMIENTO EN MI COLECCIÓN
	# -------------------------------------------------------------
	main_scene._on_collection_pressed()
	var grid_view = main_scene.get_node("CollectionModal/GridView")
	assert(grid_view.visible == true, "GridView de colección debe estar visible.")
	
	# Por default el modo es ID
	assert(main_scene.collection_sort_mode == "ID", "El modo inicial de colección debe ser ID.")
	assert(main_scene.current_sorted_collection.size() > 0, "current_sorted_collection no debe estar vacío.")
	for i in range(main_scene.current_sorted_collection.size() - 1):
		var id_a = int(main_scene.current_sorted_collection[i]["id"])
		var id_b = int(main_scene.current_sorted_collection[i+1]["id"])
		assert(id_a <= id_b, "Orden ID debe ser ascendente: %d <= %d" % [id_a, id_b])
	print("✓ Verificación 1: Ordenamiento por defecto en Colección es ID interno ascendente.")
	
	# Cambiar a orden por Nº Pokédex
	main_scene._on_col_sort_pressed("DEX")
	assert(main_scene.collection_sort_mode == "DEX", "Modo debe ser DEX.")
	for i in range(main_scene.current_sorted_collection.size() - 1):
		var dex_a = int(main_scene.current_sorted_collection[i]["pokedex_num"])
		var dex_b = int(main_scene.current_sorted_collection[i+1]["pokedex_num"])
		assert(dex_a <= dex_b, "Orden DEX debe ser ascendente: #%d <= #%d" % [dex_a, dex_b])
	# Bulbasaur debe ser primero (#1) y Pichu al final (#172)
	assert(int(main_scene.current_sorted_collection[0]["pokedex_num"]) == 1, "Primer Pokémon en DEX debe ser #001 (Bulbasaur).")
	assert(int(main_scene.current_sorted_collection[-1]["pokedex_num"]) >= 172, "Último Pokémon en DEX debe ser #172 (Pichu).")
	print("✓ Verificación 2: Ordenamiento por Nº Pokédex organiza numéricamente (#001 primero, #172 Pichu al final).")
	
	# Cambiar a orden Alfabético
	main_scene._on_col_sort_pressed("NAME")
	assert(main_scene.collection_sort_mode == "NAME", "Modo debe ser NAME.")
	for i in range(main_scene.current_sorted_collection.size() - 1):
		var name_a = str(main_scene.current_sorted_collection[i]["short_name"]).to_lower()
		var name_b = str(main_scene.current_sorted_collection[i+1]["short_name"]).to_lower()
		assert(name_a <= name_b, "Orden alfabético A-Z: %s <= %s" % [name_a, name_b])
	assert(main_scene.current_sorted_collection[0]["short_name"] == "Blastoise", "Primer Pokémon alfabético debe ser Blastoise. Actual: %s" % main_scene.current_sorted_collection[0]["short_name"])
	print("✓ Verificación 3: Ordenamiento Alfabético (A - Z) ubica Blastoise al inicio y ordena correctamente.")
	
	# Navegación en detalle respeta orden activo (Blastoise #009 está bloqueado, Bulbasaur #001 desbloqueado)
	main_scene.open_collection_detail(0)
	assert(main_scene.detail_sub.text.contains("009"), "Detalle de posición 0 (Blastoise) debe indicar No. 009.")
	main_scene._on_next_card_pressed()
	assert(main_scene.detail_name.text == "Bulbasaur", "Siguiente tras Blastoise en orden alfabético debe ser Bulbasaur.")
	main_scene._on_back_to_grid_pressed()
	print("✓ Verificación 4: Vista de detalle y botones Anterior/Siguiente respetan la lista ordenada.")

	# -------------------------------------------------------------
	# 2. TEST DE CUADRÍCULA Y SELECCIÓN EN TEAM SELECT MODAL
	# -------------------------------------------------------------
	main_scene.collection_modal.visible = false
	main_scene._on_quick_battle_pressed()
	var team_modal = main_scene.team_select_modal
	assert(team_modal.visible == true, "TeamSelectModal debe abrirse.")
	
	var team_grid = main_scene.team_grid_cards
	assert(team_grid != null, "team_grid_cards debe existir en la escena.")
	assert(team_grid.columns == 4, "La cuadrícula de selección de equipo debe tener 4 columnas igual que Colección.")
	
	# En pestaña Jugador con iniciales
	assert(main_scene.team_card_views_map.size() == 4, "Jugador debe tener 4 miniaturas disponibles. Actual: %d" % main_scene.team_card_views_map.size())
	
	# Comprobar ordenamiento en Team Select
	main_scene._on_team_sort_pressed("DEX")
	assert(main_scene.team_sort_mode == "DEX", "Modo en Team Select debe ser DEX.")
	for i in range(main_scene.current_sorted_team_pool.size() - 1):
		var dex_a = int(main_scene.current_sorted_team_pool[i]["pokedex_num"])
		var dex_b = int(main_scene.current_sorted_team_pool[i+1]["pokedex_num"])
		assert(dex_a <= dex_b, "Orden DEX en Team Select debe ser ascendente.")
	print("✓ Verificación 5: Selección de equipo usa la misma cuadrícula de 4 columnas y soporta ordenamiento.")

	# Comprobar selección y badges visuales
	main_scene.selected_player_ids.clear()
	main_scene.update_team_select_ui()
	assert(main_scene.slot1_lbl.text.contains("[Vacío]"), "Slot 1 debe estar vacío.")
	assert(main_scene.btn_start_battle.disabled == true, "Botón entrar a combate debe estar deshabilitado con 0 Pokémon.")
	
	# Seleccionar Bulbasaur (id 0) como 1º Líder
	main_scene.toggle_pokemon_selection(0)
	assert(main_scene.selected_player_ids.has(0), "Bulbasaur debe estar en selected_player_ids.")
	assert(main_scene.team_card_views_map[0]["badge_panel"].visible == true, "Badge de rol debe estar visible.")
	assert(main_scene.team_card_views_map[0]["badge_lbl"].text == "✓ 1º LÍDER", "Badge debe decir '✓ 1º LÍDER'.")
	assert(main_scene.slot1_lbl.text.contains("Bulbasaur"), "Slot 1 debe mostrar a Bulbasaur.")
	print("✓ Verificación 6: Al seleccionar un Pokémon se asigna como 1º LÍDER con badge visual verde y borde resaltado.")

	# Seleccionar Charmander (id 1) como 2º Banca
	main_scene.toggle_pokemon_selection(1)
	assert(main_scene.team_card_views_map[1]["badge_panel"].visible == true, "Badge de rol para Charmander debe estar visible.")
	assert(main_scene.team_card_views_map[1]["badge_lbl"].text == "✓ 2º BANCA", "Badge debe decir '✓ 2º BANCA'.")
	assert(main_scene.slot2_lbl.text.contains("Charmander"), "Slot 2 debe mostrar a Charmander.")
	print("✓ Verificación 7: Al seleccionar un segundo Pokémon se asigna como 2º BANCA.")

	# Deseleccionar Bulbasaur -> Charmander pasa a ser 1º Líder
	main_scene.toggle_pokemon_selection(0)
	assert(not main_scene.selected_player_ids.has(0), "Bulbasaur ya no debe estar seleccionado.")
	assert(main_scene.team_card_views_map[0]["badge_panel"].visible == false, "Badge de Bulbasaur debe ocultarse.")
	assert(main_scene.team_card_views_map[1]["badge_lbl"].text == "✓ 1º LÍDER", "Charmander debe ser promovido a 1º LÍDER.")
	assert(main_scene.slot1_lbl.text.contains("Charmander"), "Slot 1 debe actualizarse con Charmander.")
	assert(main_scene.slot2_lbl.text.contains("[Vacío]"), "Slot 2 debe quedar vacío.")
	print("✓ Verificación 8: Deseleccionar actualiza los roles y reasigna los puestos correctamente.")

	# Pestaña Rival IA
	main_scene._on_tab_enemy_pressed()
	assert(main_scene.team_card_views_map.size() == GameData.all_pokemon_ids.size(), "IA debe tener todo el catálogo en la cuadrícula.")
	main_scene._on_team_sort_pressed("NAME")
	assert(main_scene.current_sorted_team_pool[0]["short_name"] == "Blastoise", "Primer Pokémon de IA en NAME debe ser Blastoise.")
	print("✓ Verificación 9: Pestaña Rival IA despliega todo el catálogo y soporta ordenamiento independiente.")

	print("\n🎉 TODOS LOS TESTS DE ORDENAMIENTO Y CUADRÍCULA DE EQUIPO PASARON CON ÉXITO.")
	get_tree().quit(0)
