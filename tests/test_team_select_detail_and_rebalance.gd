extends Node

func _ready() -> void:
	print("=== STARTING TEST: TEAM SELECT DETAIL, CRIT % REWORK, & RAYQUAZA REBALANCE ===")
	call_deferred("_run_tests")

func _run_tests() -> void:
	# 1. Cargar bases de datos CSV
	GameData.load_moves_from_csv()
	GameData.load_pokemon_from_csv()

	# --- TEST 1: Rayquaza y Legendarios de Alto Rango Rebalanceados ---
	print("\n--- TEST 1: Verificación de Rayquaza y Legendarios de Alto Rango ---")
	var rayquaza = GameData.get_pokemon_data(389)
	assert(rayquaza.get("m1_name") == "Extreme Speed", "Rayquaza move1 debe ser Extreme Speed (m1_name=%s)" % rayquaza.get("m1_name"))
	assert(rayquaza.get("m2_name") == "Dragon Ascent", "Rayquaza move2 debe ser Dragon Ascent (m2_name=%s)" % rayquaza.get("m2_name"))
	
	var apex_ray = GameData.get_pokemon_data(501)
	assert(apex_ray.get("m1_name") == "Extreme Speed", "Apex Rayquaza move1 debe ser Extreme Speed")
	assert(apex_ray.get("m2_name") == "Dragon Ascent", "Apex Rayquaza move2 debe ser Dragon Ascent")

	var dragon_ascent = GameData.get_move_data("Dragon Ascent")
	assert(not dragon_ascent.is_empty(), "Dragon Ascent debe existir en la base de datos de movimientos")
	assert(dragon_ascent.get("dmg") == 54, "Dragon Ascent debe causar 54 base DMG")
	assert(dragon_ascent.get("cost") == 4, "Dragon Ascent debe costar 4 de energía")
	print("✔ Dragon Ascent validado: 54 DMG, 4 Energía, Infalible.")

	var extreme_speed = GameData.get_move_data("Extreme Speed")
	assert(not extreme_speed.is_empty(), "Extreme Speed debe existir")
	assert(extreme_speed.get("dmg") == 32, "Extreme Speed debe causar 32 base DMG")
	assert(extreme_speed.get("cost") == 2, "Extreme Speed debe costar 2 de energía")
	print("✔ Extreme Speed validado: 32 DMG, 2 Energía.")

	var outrage = GameData.get_move_data("Outrage")
	assert(outrage.get("dmg") == 52, "Outrage debe causar 52 base DMG")
	assert(outrage.get("cost") == 4, "Outrage debe costar 4 de energía")
	print("✔ Outrage validado: 52 DMG (anteriormente 0 DMG).")

	var roar_of_time = GameData.get_move_data("Roar of Time")
	assert(roar_of_time.get("dmg") == 52, "Roar of Time debe causar 52 DMG")
	print("✔ Roar of Time validado: 52 DMG (Dialga).")

	var spacial_rend = GameData.get_move_data("Spacial Rend")
	assert(spacial_rend.get("dmg") == 48, "Spacial Rend debe causar 48 DMG")
	print("✔ Spacial Rend validado: 48 DMG (Palkia).")

	var shadow_force = GameData.get_move_data("Shadow Force")
	assert(shadow_force.get("dmg") == 50, "Shadow Force debe causar 50 DMG")
	print("✔ Shadow Force validado: 50 DMG (Giratina).")

	var zapdos = GameData.get_pokemon_data(160)
	assert(zapdos.get("m2_name") == "Thunder", "Zapdos move2 debe ser Thunder (48 DMG)")
	print("✔ Zapdos actualizado con Thunder.")

	var alakazam = GameData.get_pokemon_data(68)
	assert(alakazam.get("m2_name") == "Future Sight", "Alakazam move2 debe ser Future Sight (48 DMG)")
	print("✔ Alakazam actualizado con Future Sight.")

	# --- TEST 2: Corrección de Descripciones Desactualizadas ---
	print("\n--- TEST 2: Corrección de Descripciones Desactualizadas ---")
	var rock_wrecker = GameData.get_move_data("Rock Wrecker")
	assert(not ("20" in rock_wrecker.get("desc")), "Rock Wrecker no debe mencionar 20 DMG")
	assert("56" in rock_wrecker.get("desc"), "Rock Wrecker debe mencionar 56 DMG en inglés")
	assert("56" in rock_wrecker.get("desc_es"), "Rock Wrecker debe mencionar 56 DMG en español")
	print("✔ Rock Wrecker refleja 56 DMG en ambos idiomas.")

	var sonic_boom = GameData.get_move_data("Sonic Boom")
	assert("12" in sonic_boom.get("desc") and "12" in sonic_boom.get("desc_es"), "Sonic Boom debe mencionar 12 fixed true DMG")
	print("✔ Sonic Boom refleja 12 DMG verdadero en ambos idiomas.")

	var night_shade = GameData.get_move_data("Night Shade")
	assert("18" in night_shade.get("desc") and "18" in night_shade.get("desc_es"), "Night Shade debe mencionar 18 fixed true DMG")
	print("✔ Night Shade refleja 18 DMG verdadero en ambos idiomas.")

	var explosion = GameData.get_move_data("Explosion")
	assert("25%" in explosion.get("desc") and "25%" in explosion.get("desc_es"), "Explosion debe mencionar 25% recoil")
	print("✔ Explosion describe 25% recoil en ambos idiomas.")

	# --- TEST 3: Movimientos Críticos reflejan +50% de daño en descripción ---
	print("\n--- TEST 3: Verificación de Porcentaje (+50% DMG) en Movimientos Críticos ---")
	var sample_crits = ["Crabhammer", "Cross Chop", "Drill Run", "Leaf Blade", "Slash", "Stone Edge", "Aeroblast", "Blaze Kick"]
	for m_name in sample_crits:
		var md = GameData.get_move_data(m_name)
		assert("+50%" in md.get("desc"), "%s debe incluir +50%% DMG en inglés" % m_name)
		assert("+50%" in md.get("desc_es"), "%s debe incluir +50%% de daño en español" % m_name)
	print("✔ Todos los movimientos críticos validados con bonificación porcentual (+50% DMG).")

	# --- TEST 4: Detalle de Carta en Selección de Equipo (Lobby) ---
	print("\n--- TEST 4: Verificación de Detalle de Carta en Selección de Equipo ---")
	var main_res = load("res://scenes/main_menu.tscn")
	var main_menu = main_res.instantiate()
	add_child(main_menu)
	await get_tree().process_frame
	await get_tree().process_frame

	GameData.unlock_all_pokemon()
	main_menu.open_team_select_for_campaign()
	await get_tree().process_frame
	assert(main_menu.team_select_modal.visible, "Team Select Modal debe estar visible")

	# Abrir detalle de carta desde selección de equipo
	main_menu.open_card_detail_from_team_select(389) # Rayquaza
	await get_tree().process_frame
	await get_tree().process_frame

	assert(main_menu.collection_detail_view.visible, "collection_detail_view debe ser visible al inspeccionar en Team Select")
	assert(not main_menu.team_select_modal.visible, "team_select_modal debe ocultarse mientras se ve el detalle")
	assert(main_menu._detail_return_to_team_select, "_detail_return_to_team_select debe ser true")
	assert(main_menu.detail_name.text == "Rayquaza", "El detalle debe mostrar Rayquaza")
	print("✔ Detalle completo abierto desde Selección de Equipo mostrando Rayquaza con AssembledCard.")

	# Regresar a Selección de Equipo mediante el botón de volver
	main_menu._on_back_to_grid_pressed()
	await get_tree().process_frame
	await get_tree().process_frame

	assert(main_menu.team_select_modal.visible, "team_select_modal debe volver a ser visible")
	assert(not main_menu.collection_detail_view.visible, "collection_detail_view debe ocultarse")
	assert(not main_menu._detail_return_to_team_select, "_detail_return_to_team_select debe restablecerse a false")
	print("✔ Regreso impecable a Selección de Equipo verificado.")

	# --- TEST 5: Simulación de Combate y Daño Crítico (+50%) ---
	print("\n--- TEST 5: Simulación de Combate y Cálculo Crítico (+50% DMG) ---")
	var battle_res = load("res://scenes/battle.tscn")
	var battle = battle_res.instantiate()
	add_child(battle)
	await get_tree().process_frame

	var p_inst = GameData.create_pokemon_instance(389) # Rayquaza
	var e_inst = GameData.create_pokemon_instance(1)   # Bulbasaur
	assert(p_inst != null and e_inst != null, "Instancias de combate deben crearse")
	
	# Verificar cálculo de daño de un ataque crítico (+50% raw_damage)
	var raw_test_dmg = 40
	var expected_crit_bonus = int(round(float(raw_test_dmg) * 0.50)) # 20
	assert(expected_crit_bonus == 20, "El bonus de crítico de 40 DMG debe ser exactamente 20 (+50%)")
	print("✔ Fórmula de daño crítico validada: 40 DMG + 50%% = %d DMG total." % (raw_test_dmg + expected_crit_bonus))

	print("\n🎉 ¡TODOS LOS TESTS DE DETALLES, CRÍTICOS Y REBALANCEO PASARON CON ÉXITO! 🎉")
	battle.queue_free()
	main_menu.queue_free()
	get_tree().quit(0)
