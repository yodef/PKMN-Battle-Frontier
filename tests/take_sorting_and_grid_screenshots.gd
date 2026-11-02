extends Node

func _ready() -> void:
	await get_tree().create_timer(0.3).timeout
	var main_scene = load("res://scenes/main_menu.tscn").instantiate()
	add_child(main_scene)
	await get_tree().create_timer(0.2).timeout
	
	# Desbloquear todas las cartas para ver la cuadrícula completa en capturas
	GameData.unlock_all_pokemon()
	main_scene.refresh_cards_data_from_catalog()
	
	# 1. Colección ordenada por Nº DEX
	main_scene._on_collection_pressed()
	main_scene._on_col_sort_pressed("DEX")
	await get_tree().create_timer(0.3).timeout
	var img_col_dex = get_viewport().get_texture().get_image()
	if img_col_dex:
		img_col_dex.save_png("C:/Users/rafag/.gemini/antigravity/brain/dca5182f-4733-4c52-8dfc-ccfff3b26dd9/collection_sort_dex_screenshot.png")
		
	# 2. Colección ordenada Alfabéticamente (A - Z)
	main_scene._on_col_sort_pressed("NAME")
	await get_tree().create_timer(0.3).timeout
	var img_col_alpha = get_viewport().get_texture().get_image()
	if img_col_alpha:
		img_col_alpha.save_png("C:/Users/rafag/.gemini/antigravity/brain/dca5182f-4733-4c52-8dfc-ccfff3b26dd9/collection_sort_alpha_screenshot.png")
		
	# 3. Selección de Equipo - Pestaña Jugador con cuadrícula, orden Nº Dex y 3 seleccionados
	main_scene.collection_modal.visible = false
	main_scene._on_quick_battle_pressed()
	main_scene._on_team_sort_pressed("DEX")
	main_scene.selected_player_ids.clear()
	main_scene.selected_player_ids.append(0) # Bulbasaur (Líder)
	main_scene.selected_player_ids.append(1) # Charmander (2º)
	main_scene.selected_player_ids.append(2) # Squirtle (3º)
	main_scene.update_team_select_ui()
	await get_tree().create_timer(0.3).timeout
	var img_team_player = get_viewport().get_texture().get_image()
	if img_team_player:
		img_team_player.save_png("C:/Users/rafag/.gemini/antigravity/brain/dca5182f-4733-4c52-8dfc-ccfff3b26dd9/team_select_grid_player_screenshot.png")
		
	# 4. Selección de Equipo - Pestaña Rival IA con cuadrícula, orden A-Z
	main_scene._on_tab_enemy_pressed()
	main_scene._on_team_sort_pressed("NAME")
	main_scene.selected_enemy_ids.clear()
	main_scene.selected_enemy_ids.append(9) # Blastoise
	main_scene.selected_enemy_ids.append(8) # Wartortle
	main_scene.selected_enemy_ids.append(3) # Pichu
	main_scene.update_team_select_ui()
	await get_tree().create_timer(0.3).timeout
	var img_team_enemy = get_viewport().get_texture().get_image()
	if img_team_enemy:
		img_team_enemy.save_png("C:/Users/rafag/.gemini/antigravity/brain/dca5182f-4733-4c52-8dfc-ccfff3b26dd9/team_select_grid_enemy_screenshot.png")
		
	print("Todas las capturas de ordenamiento y cuadrícula se han guardado exitosamente.")
	get_tree().quit(0)
