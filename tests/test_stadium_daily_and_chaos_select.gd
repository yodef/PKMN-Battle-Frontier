extends Node

func _ready() -> void:
	print("--- INICIANDO TEST: STADIUM DAILY REWARDS & CHAOS ODYSSEY SELECT ---")
	test_chaos_team_selection()
	test_stadium_daily_stage_rewards()
	test_stadium_save_load()
	print("--- TODOS LOS TESTS DE STADIUM DAILY Y CHAOS SELECT COMPLETADOS EXITOSAMENTE ---")
	get_tree().quit(0)

func test_chaos_team_selection() -> void:
	print("[TEST] Verificando selección de equipo en Chaos Odyssey y Stadium...")
	# Asegurar que el catálogo de GameData esté cargado
	if GameData.pokemon_catalog.is_empty():
		GameData.load_pokemon_catalog()
		
	var main_scene = load("res://scenes/main_menu.tscn").instantiate()
	add_child(main_scene)
	
	# Encontrar IDs para pruebas:
	# 1. Un legendario puro (ej. Mewtwo)
	var mewtwo_id = GameData.get_pokemon_id_by_name("Mewtwo")
	var cat_mewtwo = GameData.pokemon_catalog.get(mewtwo_id)
	assert(cat_mewtwo != null, "Mewtwo debe existir en el catálogo")
	
	# 2. Un básico de línea legendaria (ej. Dratini)
	var dratini_id = GameData.get_pokemon_id_by_name("Dratini")
	var cat_dratini = GameData.pokemon_catalog.get(dratini_id)
	assert(cat_dratini != null, "Dratini debe existir en el catálogo")
	assert(GameData.is_line_legendary(dratini_id), "Dratini debe ser de línea legendaria")
	
	# 3. Un básico común (ej. Caterpie)
	var caterpie_id = GameData.get_pokemon_id_by_name("Caterpie")
	var cat_caterpie = GameData.pokemon_catalog.get(caterpie_id)
	assert(cat_caterpie != null, "Caterpie debe existir en el catálogo")
	assert(not GameData.is_line_legendary(caterpie_id), "Caterpie NO debe ser de línea legendaria")
	
	# Configurar modo Chaos Odyssey
	main_scene.team_select_mode = "CAMPAIGN"
	GameData.campaign_submode = "CHAOS"
	main_scene.selected_player_ids.clear()
	
	# En Chaos Odyssey: Seleccionar Dratini (debe permitirlo como líder)
	main_scene.toggle_pokemon_selection(dratini_id)
	assert(main_scene.selected_player_ids.has(dratini_id), "Dratini (básico legendario) debe poder seleccionarse en Chaos Odyssey")
	
	# En Chaos Odyssey: Seleccionar Mewtwo (debe permitirlo para banca)
	main_scene.toggle_pokemon_selection(mewtwo_id)
	assert(main_scene.selected_player_ids.has(mewtwo_id), "Mewtwo (legendario) debe poder seleccionarse en banca de Chaos Odyssey")
	assert(main_scene.selected_player_ids.size() == 2, "Deben haber 2 Pokémon seleccionados (1 líder, 1 banca)")
	
	# En Chaos Odyssey: Intentar seleccionar Caterpie (debe bloquearlo)
	main_scene.toggle_pokemon_selection(caterpie_id)
	assert(not main_scene.selected_player_ids.has(caterpie_id), "Caterpie común NO debe poder seleccionarse en Chaos Odyssey")
	assert(main_scene.selected_player_ids.size() == 2, "El tamaño del equipo debe seguir siendo 2")
	
	# Deseleccionar Mewtwo
	main_scene.toggle_pokemon_selection(mewtwo_id)
	assert(not main_scene.selected_player_ids.has(mewtwo_id), "Mewtwo debe haberse deseleccionado")
	assert(main_scene.selected_player_ids.size() == 1, "Debe quedar 1 Pokémon")
	
	# Ahora probar en Tournament (Stadium estándar)
	GameData.campaign_submode = "TOURNAMENT"
	main_scene.selected_player_ids.clear()
	
	# En Stadium: Caterpie debe ser seleccionable (es básico no legendario)
	main_scene.toggle_pokemon_selection(caterpie_id)
	assert(main_scene.selected_player_ids.has(caterpie_id), "Caterpie debe poder seleccionarse en Stadium")
	
	# En Stadium: Mewtwo NO debe ser seleccionable (legendarios prohibidos)
	main_scene.toggle_pokemon_selection(mewtwo_id)
	assert(not main_scene.selected_player_ids.has(mewtwo_id), "Mewtwo NO debe poder seleccionarse en Stadium estándar")
	
	remove_child(main_scene)
	main_scene.queue_free()
	print("✓ Selección de equipo en Chaos Odyssey y Stadium validada correctamente")

func test_stadium_daily_stage_rewards() -> void:
	print("[TEST] Verificando recompensas diarias de etapas en Pokémon Stadium...")
	var today = Time.get_date_string_from_system()
	
	# Resetear estado de recompensas
	GameData.tournament_rewards_last_date = ""
	GameData.tournament_claimed_matches_today.clear()
	
	assert(not GameData.is_tournament_match_reward_claimed_today(1), "Match 1 no debe estar reclamado aún")
	assert(not GameData.is_tournament_match_reward_claimed_today(2), "Match 2 no debe estar reclamado aún")
	
	# Reclamar match 1 hoy
	GameData.claim_tournament_match_reward_today(1)
	assert(GameData.is_tournament_match_reward_claimed_today(1), "Match 1 debe estar reclamado hoy")
	assert(not GameData.is_tournament_match_reward_claimed_today(2), "Match 2 debe seguir sin reclamar")
	assert(GameData.tournament_rewards_last_date == today, "La fecha debe coincidir con hoy")
	
	# Reclamar match 2 hoy
	GameData.claim_tournament_match_reward_today(2)
	assert(GameData.is_tournament_match_reward_claimed_today(1), "Match 1 debe seguir reclamado")
	assert(GameData.is_tournament_match_reward_claimed_today(2), "Match 2 debe estar reclamado hoy")
	
	# Simular cambio de día (ayer)
	GameData.tournament_rewards_last_date = "2000-01-01"
	assert(not GameData.is_tournament_match_reward_claimed_today(1), "Al ser un nuevo día, match 1 debe considerarse no reclamado")
	assert(not GameData.is_tournament_match_reward_claimed_today(2), "Al ser un nuevo día, match 2 debe considerarse no reclamado")
	
	# Reclamar match 1 en el nuevo día
	GameData.claim_tournament_match_reward_today(1)
	assert(GameData.tournament_rewards_last_date == today, "Debe actualizar la fecha al día de hoy")
	assert(GameData.is_tournament_match_reward_claimed_today(1), "Match 1 debe estar reclamado hoy")
	assert(not GameData.is_tournament_match_reward_claimed_today(2), "Match 2 no debe estar en la lista del nuevo día")
	
	print("✓ Lógica de recompensas diarias por etapa verificada exitosamente")

func test_stadium_save_load() -> void:
	print("[TEST] Verificando serialización y guardado de recompensas diarias...")
	var today = Time.get_date_string_from_system()
	GameData.tournament_rewards_last_date = today
	GameData.tournament_claimed_matches_today = [1, 3, 5]
	
	var save_dict = GameData.get_save_dict()
	var camp_dict = save_dict.get("campaign", {})
	assert(camp_dict.get("tournament_rewards_last_date") == today, "Debe guardar tournament_rewards_last_date")
	assert(camp_dict.get("tournament_claimed_matches_today") == [1, 3, 5], "Debe guardar tournament_claimed_matches_today")
	
	# Resetear y restaurar
	GameData.tournament_rewards_last_date = ""
	GameData.tournament_claimed_matches_today.clear()
	GameData.apply_save_dict(save_dict)
	
	assert(GameData.tournament_rewards_last_date == today, "Debe restaurar tournament_rewards_last_date")
	assert(GameData.tournament_claimed_matches_today == [1, 3, 5], "Debe restaurar tournament_claimed_matches_today")
	assert(GameData.is_tournament_match_reward_claimed_today(1), "Match 1 debe estar reclamado tras cargar partida")
	assert(GameData.is_tournament_match_reward_claimed_today(3), "Match 3 debe estar reclamado tras cargar partida")
	assert(not GameData.is_tournament_match_reward_claimed_today(2), "Match 2 no debe estar reclamado")
	
	print("✓ Serialización y guardado en perfil verificados exitosamente")
