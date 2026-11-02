extends Node

func _ready() -> void:
	print("--- INICIANDO TEST DE CUADRÍCULA DE COLECCIÓN ---")
	
	assert(GameData.player_unlocked_ids.size() == 4, "Debe haber exactamente 4 iniciales desbloqueados.")
	assert(GameData.all_pokemon_ids.size() >= 9, "Debe haber al menos 9 Pokémon en el catálogo.")
	print("✓ Verificación 1: GameData tiene 4 iniciales y 9 Pokémon totales.")
	
	# 1. Cargar la escena del menú principal
	var main_scene = load("res://scenes/main_menu.tscn").instantiate()
	add_child(main_scene)
	
	# 2. Abrir Mi Colección
	main_scene._on_collection_pressed()
	
	var collection_modal = main_scene.get_node("CollectionModal")
	var grid_view = main_scene.get_node("CollectionModal/GridView")
	var detail_view = main_scene.get_node("CollectionModal/DetailView")
	var grid_cards = main_scene.get_node("CollectionModal/GridView/GridScroll/GridMargin/GridCards")
	var stats_lbl = main_scene.get_node("CollectionModal/GridView/StatsLbl")
	
	assert(collection_modal.visible == true, "CollectionModal debe estar visible.")
	assert(grid_view.visible == true, "GridView debe estar visible.")
	assert(detail_view.visible == false, "DetailView debe estar oculto al abrir la colección.")
	assert(stats_lbl.text.begins_with("Cartas Obtenidas: 4 /"), "El contador debe decir 'Cartas Obtenidas: 4 / X'. Actual: " + stats_lbl.text)
	print("✓ Verificación 2: Mi Colección abre en vista de Cuadrícula con contador dinámico.")
	
	# 3. Inspeccionar elementos de la cuadrícula
	var children = grid_cards.get_children()
	assert(children.size() == GameData.all_pokemon_ids.size(), "Debe haber %d elementos en la cuadrícula. Actual: %d" % [GameData.all_pokemon_ids.size(), children.size()])
	
	# Bulbasaur (índice 0, Desbloqueado)
	var cell0 = children[0]
	var btn0 = cell0.get_child(0) as Button
	var lbl0 = cell0.get_child(1) as Label
	assert(btn0.text == "", "La miniatura de Bulbasaur desbloqueado NO debe tener texto sobrecargado.")
	assert(btn0.icon != null, "La miniatura de Bulbasaur desbloqueado SÍ debe tener su sprite centrado.")
	assert(lbl0.text.contains("Bulbasaur"), "La etiqueta debe decir Bulbasaur. Actual: " + lbl0.text)
	print("✓ Verificación 3: Miniatura de Bulbasaur desbloqueada (fondo elemental con sprite centrado y nombre).")
	
	# Weedle (índice 4, Bloqueado)
	var cell4 = children[4]
	var btn4 = cell4.get_child(0) as Button
	var lbl4 = cell4.get_child(1) as Label
	assert(btn4.text == "?", "La miniatura de Weedle bloqueado debe mostrar '?'. Actual: " + btn4.text)
	assert(lbl4.text.contains("???"), "La etiqueta de Weedle debe decir ???. Actual: " + lbl4.text)
	print("✓ Verificación 4: Miniatura de Weedle bloqueada (estilo oscuro con '?' y nombre ???).")
	
	# 4. Clic en Bulbasaur (Desbloqueado) -> Abrir Detalle
	main_scene.open_collection_detail(0)
	assert(grid_view.visible == false, "GridView debe ocultarse.")
	assert(detail_view.visible == true, "DetailView debe mostrarse.")
	
	var assembled_card = main_scene.get_node("CollectionModal/DetailView/CardCenter/AssembledCard")
	var name_lbl = assembled_card.get_node("CardPanel/Margin/VBox/HeaderHBox/NameLabel")
	var hp_lbl = assembled_card.get_node("CardPanel/Margin/VBox/HeaderHBox/HpBox/HpLabel")
	var type_icon = assembled_card.get_node("CardPanel/Margin/VBox/HeaderHBox/HpBox/TypeIcon")
	var locked_notice = main_scene.get_node("CollectionModal/DetailView/DetailsScroll/DetailsBox/LockedNoticePanel")
	
	assert(name_lbl.text == "Bulbasaur", "AssembledCard debe mostrar 'Bulbasaur'.")
	assert(hp_lbl.text == "10 HP", "AssembledCard debe mostrar '10 HP'.")
	assert(type_icon.visible == true, "El icono de tipo debe estar visible.")
	assert(locked_notice.visible == false, "El aviso de bloqueo debe estar oculto para Bulbasaur.")
	print("✓ Verificación 5: Detalle de Bulbasaur ensambla la carta completa y datos reales.")
	
	# 5. Navegar con 'Siguiente' hasta Weedle (índice 4)
	for i in range(4):
		main_scene._on_next_card_pressed()
		
	assert(main_scene.current_collection_index == 4, "Debe estar en el índice 4 (Weedle).")
	assert(name_lbl.text == "???", "AssembledCard para Weedle bloqueado debe decir '???'. Actual: " + name_lbl.text)
	assert(hp_lbl.text == "?? HP", "AssembledCard debe mostrar '?? HP'.")
	assert(type_icon.visible == false, "El icono de tipo debe estar oculto.")
	assert(locked_notice.visible == true, "El aviso de carta bloqueada debe estar visible.")
	var detail_name = main_scene.get_node("CollectionModal/DetailView/DetailsScroll/DetailsBox/HeaderPanel/HeaderMargin/HeaderVBox/NameRow/DetailName")
	assert(detail_name.text == "???", "DetailName debe ser '???'.")
	print("✓ Verificación 6: Detalle de Weedle bloqueado muestra carta misterio '???' y datos ocultos.")
	
	# 6. Volver a la cuadrícula
	main_scene._on_back_to_grid_pressed()
	assert(detail_view.visible == false, "DetailView debe ocultarse al volver a la cuadrícula.")
	assert(grid_view.visible == true, "GridView debe mostrarse.")
	print("✓ Verificación 7: Botón 'Volver a la Cuadrícula' funciona correctamente.")
	
	# 7. Comprobar Selección de Equipo (Combate Libre)
	main_scene._on_quick_battle_pressed()
	var team_modal = main_scene.get_node("TeamSelectModal")
	assert(team_modal.visible == true, "TeamSelectModal debe abrirse.")
	assert(main_scene.card_buttons_map.size() == 4, "En pestaña Jugador debe haber 4 cartas disponibles (los iniciales). Actual: %d" % main_scene.card_buttons_map.size())
	
	main_scene._on_tab_enemy_pressed()
	assert(main_scene.card_buttons_map.size() == GameData.all_pokemon_ids.size(), "En pestaña Enemigo IA debe haber %d cartas disponibles para elegir. Actual: %d" % [GameData.all_pokemon_ids.size(), main_scene.card_buttons_map.size()])
	print("✓ Verificación 8: Selección de Equipo permite al jugador usar sus 4 iniciales y a la IA todos los Pokémon del catálogo.")
	
	print("\n🎉 TODOS LOS TESTS DE COLECCIÓN EN CUADRÍCULA PASARON CON ÉXITO.")
	get_tree().quit(0)
