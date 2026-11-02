extends Node

func _ready() -> void:
	print("--- INICIANDO TEST DE SELECCIÓN DE EQUIPO EN CAMPAÑA Y BOTÓN DEV TIENDA ---")
	await get_tree().process_frame
	await get_tree().process_frame
	
	var main_scene = load("res://scenes/main_menu.tscn").instantiate()
	add_child(main_scene)
	await get_tree().process_frame
	await get_tree().process_frame
	
	# 1. Comprobar inicio con campaña vacía
	assert(GameData.campaign_player_team_state.is_empty(), "El estado del equipo de campaña debe iniciar vacío.")
	assert(GameData.player_unlocked_ids.size() == 4, "Debe haber 4 iniciales desbloqueados por defecto.")
	
	# 2. Abrir campaña desde el menú principal
	main_scene._on_campaign_pressed()
	await get_tree().process_frame
	
	var team_modal = main_scene.team_select_modal
	var camp_modal = main_scene.campaign_modal
	assert(team_modal.visible == true, "Al presionar Campaña por primera vez debe abrir el selector de equipo.")
	assert(camp_modal.visible == false, "El modal de campaña debe estar oculto mientras se elige equipo.")
	assert(main_scene.team_select_mode == "CAMPAIGN", "El modo de selección debe ser CAMPAIGN.")
	assert(main_scene.team_select_tabs.visible == false, "Los tabs de selección de rival deben estar ocultos en campaña.")
	assert(main_scene.selected_player_ids.size() >= 1, "Debe haber al menos 1 seleccionado.")
	print("✓ Verificación 1: Campaña abre directamente el selector de equipo personalizado.")
	
	# 3. Personalizar equipo para campaña: Elegir solo Charmander (ID 1) y Squirtle (ID 2)
	main_scene.selected_player_ids.clear()
	main_scene.toggle_pokemon_selection(1)
	main_scene.toggle_pokemon_selection(2)
	assert(main_scene.selected_player_ids.size() == 2, "Equipo debe tener 2 miembros.")
	assert(1 in main_scene.selected_player_ids and 2 in main_scene.selected_player_ids, "Debe contener ID 1 y 2.")
	
	# Confirmar equipo
	main_scene._on_start_battle_pressed()
	await get_tree().process_frame
	
	assert(team_modal.visible == false, "El selector de equipo debe cerrarse.")
	assert(camp_modal.visible == true, "El modal de campaña debe mostrarse ahora.")
	assert(GameData.campaign_player_team_state.size() == 2, "El equipo de campaña debe tener 2 Pokémon.")
	assert(GameData.campaign_player_team_state[0]["id"] == 1, "El líder debe ser Charmander (ID 1).")
	assert(GameData.campaign_player_team_state[1]["id"] == 2, "El segundo debe ser Squirtle (ID 2).")
	print("✓ Verificación 2: Confirmación de equipo guarda correctamente los Pokémon elegidos (Charmander y Squirtle).")
	
	# 4. Probar botón de cambiar equipo en el modal de campaña
	assert(main_scene.btn_change_campaign_team.visible == true, "El botón de cambiar equipo debe ser visible en el combate 1.")
	main_scene.open_team_select_for_campaign()
	await get_tree().process_frame
	
	assert(team_modal.visible == true, "El selector de equipo debe abrirse de nuevo.")
	# Cambiar a Bulbasaur (0) solamente
	main_scene.selected_player_ids.clear()
	main_scene.toggle_pokemon_selection(0)
	main_scene._on_start_battle_pressed()
	await get_tree().process_frame
	
	assert(GameData.campaign_player_team_state.size() == 1, "El equipo de campaña ahora debe tener 1 Pokémon.")
	assert(GameData.campaign_player_team_state[0]["id"] == 0, "El líder debe ser Bulbasaur (ID 0).")
	print("✓ Verificación 3: Botón de Cambiar Equipo permite reconfigurar el equipo libremente.")
	
	# 5. Probar Tienda y Botón Dev de Desbloquear Todos
	camp_modal.visible = false
	main_scene._on_shop_pressed()
	await get_tree().process_frame
	
	var shop_modal = main_scene.shop_modal
	assert(shop_modal.visible == true, "El modal de la tienda debe abrirse.")
	assert(main_scene.btn_unlock_all_dev != null, "El botón dev debe existir en la tienda.")
	
	main_scene._on_unlock_all_dev_pressed()
	await get_tree().process_frame
	
	assert(GameData.player_unlocked_ids.size() == GameData.all_pokemon_ids.size(), "Todos los Pokémon deben estar desbloqueados.")
	assert(GameData.is_pokemon_unlocked(9), "Blastoise (ID 9) debe estar desbloqueado.")
	assert(GameData.is_pokemon_unlocked(7), "Charizard (ID 7) debe estar desbloqueado.")
	assert(GameData.is_pokemon_unlocked(5), "Venusaur (ID 5) debe estar desbloqueado.")
	print("✓ Verificación 4: Botón Dev en Tienda desbloquea todos los %d Pokémon disponibles." % GameData.player_unlocked_ids.size())
	
	# 6. Ahora en selección de equipo de campaña, todos los Pokémon están disponibles
	shop_modal.visible = false
	main_scene.open_team_select_for_campaign()
	await get_tree().process_frame
	
	assert(main_scene.cards_data.size() == GameData.all_pokemon_ids.size(), "La lista de cartas del jugador ahora contiene todas las cartas.")
	# Elegir Pokémon Basic desbloqueados: Weedle (13), Rattata (19) y Spearow (21)
	main_scene.selected_player_ids.clear()
	main_scene.toggle_pokemon_selection(13)
	main_scene.toggle_pokemon_selection(19)
	main_scene.toggle_pokemon_selection(21)
	main_scene._on_start_battle_pressed()
	await get_tree().process_frame
	
	assert(GameData.campaign_player_team_state.size() == 3, "El equipo de torneo ahora tiene 3 Pokémon Basic.")
	assert(GameData.campaign_player_team_state[0]["id"] == 13, "Weedle está en el torneo.")
	assert(GameData.campaign_player_team_state[1]["id"] == 19, "Rattata está en el torneo.")
	assert(GameData.campaign_player_team_state[2]["id"] == 21, "Spearow está en el torneo.")
	print("✓ Verificación 5: Pokémon Basic recién desbloqueados pueden ser llevados al Torneo y Combate.")
	
	# Guardar capturas de prueba si hay soporte de renderizado
	var vp_tex = get_viewport().get_texture()
	if vp_tex:
		var img = vp_tex.get_image()
		if img:
			img.save_png("C:/Users/rafag/.gemini/antigravity/brain/dca5182f-4733-4c52-8dfc-ccfff3b26dd9/campaign_custom_team_screenshot.png")
	
	print("\n🎉 TODOS LOS TESTS DE CAMPAÑA Y TIENDA PASARON EXITOSAMENTE.")
	get_tree().quit(0)
