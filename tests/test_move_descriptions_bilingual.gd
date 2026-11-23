extends Node

func _ready() -> void:
	print("\n=== INICIANDO TESTS: DESCRIPCIONES DE MOVIMIENTOS BILINGÜES (EN / ES) ===")
	
	GameData.load_types_from_csv()
	GameData.load_moves_from_csv()
	GameData.load_pokemon_from_csv()

	# -------------------------------------------------------------
	# TEST 1: INTEGRIDAD DE LA BASE DE DATOS DE MOVIMIENTOS
	# -------------------------------------------------------------
	print("\n--- TEST 1: Todos los movimientos tienen descripciones válidas en EN y ES ---")
	var total_moves = 0
	var missing_en = []
	var missing_es = []
	
	for key in GameData.moves_catalog:
		# Los catálogos tienen entradas numéricas y por nombre; filtramos para iterar solo los IDs numéricos
		if not key.is_valid_int():
			continue
		var m = GameData.moves_catalog[key]
		total_moves += 1
		var desc_en = str(m.get("desc", m.get("description", ""))).strip_edges()
		var desc_es = str(m.get("desc_es", m.get("description_es", ""))).strip_edges()
		var m_name = str(m.get("name", "Unknown"))
		
		if desc_en.is_empty():
			missing_en.append(m_name)
		if desc_es.is_empty():
			missing_es.append(m_name)

	print("Total de movimientos únicos verificados: %d" % total_moves)
	assert(missing_en.is_empty(), "No deben existir movimientos sin descripción en inglés. Faltan: %s" % str(missing_en))
	assert(missing_es.is_empty(), "No deben existir movimientos sin descripción en español. Faltan: %s" % str(missing_es))
	print("✔ Test 1 Superado: El 100%% de los movimientos (%d) posee descripciones en ambos idiomas." % total_moves)

	# -------------------------------------------------------------
	# TEST 2: MOVIMIENTOS PREVIAMENTE SIN DESCRIPCIÓN (11 MOVES)
	# -------------------------------------------------------------
	print("\n--- TEST 2: Verificación de los 11 movimientos completados ---")
	var previously_empty = [
		"Aqua Tail", "Bubble Beam", "Power Whip", "Psychic", "Razor Leaf",
		"Rock Throw", "Spark", "Water Gun", "Body Slam", "Ice Fang", "Psywave"
	]
	
	for move_name in previously_empty:
		var md = GameData.get_move_data(move_name)
		assert(not md.is_empty(), "El movimiento %s debe existir en el catálogo" % move_name)
		var d_en = str(md.get("desc", ""))
		var d_es = str(md.get("desc_es", ""))
		assert(not d_en.is_empty(), "%s debe tener descripción en inglés" % move_name)
		assert(not d_es.is_empty(), "%s debe tener descripción en español" % move_name)
		print("  • %s: EN -> '%s' | ES -> '%s'" % [move_name, d_en, d_es])
	print("✔ Test 2 Superado: Los 11 movimientos poseen textos descriptivos de alta calidad.")

	# -------------------------------------------------------------
	# TEST 3: MOVIMIENTOS DE DRENAJE (ABSORB, MEGA DRAIN, GIGA DRAIN, ETC.)
	# -------------------------------------------------------------
	print("\n--- TEST 3: Movimientos de drenaje reflejan el 30% de curación ---")
	var drain_moves = ["Absorb", "Mega Drain", "Giga Drain", "Drain Punch", "Leech Life", "Dream Eater"]
	for d_name in drain_moves:
		var md = GameData.get_move_data(d_name)
		var d_en = str(md.get("desc", ""))
		var d_es = str(md.get("desc_es", ""))
		assert("30%" in d_en, "%s en inglés debe especificar 30%% de daño recuperado. Actual: %s" % [d_name, d_en])
		assert("30%" in d_es, "%s en español debe especificar 30%% de daño recuperado. Actual: %s" % [d_name, d_es])
		assert(not ("50%" in d_en), "%s no debe mencionar 50%%" % d_name)
	
	var giga_drain = GameData.get_move_data("Giga Drain")
	assert(giga_drain["cost"] == 3, "Giga Drain debe costar 3⚡")
	assert(giga_drain["dmg"] == 30, "Giga Drain debe causar 30 DMG")
	print("✔ Test 3 Superado: Movimientos de drenaje calibrados al 30% en ambos idiomas.")

	# -------------------------------------------------------------
	# TEST 4: MOVIMIENTOS DE CARGA Y 2 TURNOS (SOLAR BEAM, DIG, BOUNCE)
	# -------------------------------------------------------------
	print("\n--- TEST 4: Movimientos de 2 turnos detallan mecánica de carga e impacto ---")
	var solar_beam = GameData.get_move_data("Solar Beam")
	assert("turn 1" in solar_beam["desc"].to_lower() and "turn 2" in solar_beam["desc"].to_lower(), "Solar Beam EN debe describir turn 1 y 2")
	assert("turno 1" in solar_beam["desc_es"].to_lower() and "turno 2" in solar_beam["desc_es"].to_lower(), "Solar Beam ES debe describir turno 1 y 2")
	
	var dig = GameData.get_move_data("Dig")
	assert("underground" in dig["desc"].to_lower(), "Dig EN debe describir estar underground")
	assert("tierra" in dig["desc_es"].to_lower(), "Dig ES debe describir estar bajo tierra")
	
	var bounce = GameData.get_move_data("Bounce")
	assert("bounces" in bounce["desc"].to_lower() and "turn 2" in bounce["desc"].to_lower(), "Bounce EN debe describir rebote y turno 2")
	assert("salta" in bounce["desc_es"].to_lower() and "turno 2" in bounce["desc_es"].to_lower(), "Bounce ES debe describir salto y turno 2")
	print("✔ Test 4 Superado: Movimientos de carga describen con precisión sus 2 turnos.")

	# -------------------------------------------------------------
	# TEST 5: MOVIMIENTOS DE VENTAJA ELEMENTAL (MULTIPLICADOR X2)
	# -------------------------------------------------------------
	print("\n--- TEST 5: Movimientos de ventaja elemental mencionan debilidad y multiplicador x2 ---")
	var counter_cut = GameData.get_move_data("Counter-Cut")
	assert("weakness" in counter_cut["desc"].to_lower() and "x2" in counter_cut["desc"].to_lower(), "Counter-Cut EN debe mencionar Weakness y x2")
	assert("debilidad" in counter_cut["desc_es"].to_lower() and "x2" in counter_cut["desc_es"].to_lower(), "Counter-Cut ES debe mencionar Debilidad y x2")
	
	var hidden_power = GameData.get_move_data("Hidden Power")
	assert("weakness" in hidden_power["desc"].to_lower() and "x2" in hidden_power["desc"].to_lower(), "Hidden Power EN debe mencionar Weakness y x2")
	assert("debilidad" in hidden_power["desc_es"].to_lower() and "x2" in hidden_power["desc_es"].to_lower(), "Hidden Power ES debe mencionar Debilidad y x2")
	print("✔ Test 5 Superado: Ataques de ventaja elemental reflejan el multiplicador x2.")

	# -------------------------------------------------------------
	# TEST 6: FUNCIONES GET_MOVE_DESCRIPTION Y CAMBIO DINÁMICO DE IDIOMA
	# -------------------------------------------------------------
	print("\n--- TEST 6: Cambio dinámico de idioma en MoveData y GameData.get_move_description ---")
	var move_inst = GameData.get_move_instance("Solar Beam")
	
	# Inglés
	GameData.set_language("en", false)
	assert(GameData.get_move_description(move_inst).begins_with("Charges sunlight on turn 1"), "En inglés debe devolver texto en inglés")
	
	# Español
	GameData.set_language("es", false)
	assert(GameData.get_move_description(move_inst).begins_with("Carga luz solar en el turno 1"), "En español debe devolver texto en español")
	
	# Restablecer idioma a inglés
	GameData.set_language("en", false)
	assert(GameData.get_move_description(move_inst).begins_with("Charges sunlight on turn 1"), "Debe alternar limpiamente de vuelta a inglés")
	print("✔ Test 6 Superado: get_move_description responde de forma fluida y reactiva al cambio de idioma.")

	print("\n🎉 TODOS LOS TESTS DE DESCRIPCIONES DE MOVIMIENTOS BILINGÜES PASARON CON ÉXITO.")
	get_tree().quit(0)
