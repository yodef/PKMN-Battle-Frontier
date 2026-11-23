extends Node

func _ready() -> void:
	print("\n=== INICIANDO TEST: MOVIMIENTOS DE CARGA Y DOS TURNOS (SOLAR BEAM, DIG, BOUNCE, REST) ===")
	
	GameData.load_moves_from_csv()
	GameData.load_pokemon_from_csv()
	
	var battle_scene = load("res://scenes/battle.tscn").instantiate()
	add_child(battle_scene)
	await get_tree().process_frame
	await get_tree().process_frame
	
	var dummy_v1 = TextureRect.new()
	var dummy_v2 = TextureRect.new()
	add_child(dummy_v1)
	add_child(dummy_v2)
	battle_scene.player_card_img = dummy_v1
	battle_scene.enemy_card_img = dummy_v2
	
	# --- TEST 1: Definición de datos en CSV ---
	print("\n--- TEST 1: Verificación de configuración en CSV ---")
	var solar_beam = GameData.get_move_data("Solar Beam")
	assert(solar_beam != null and not solar_beam.is_empty(), "Solar Beam debe existir")
	assert(solar_beam["effect_type"] == "CHARGE", "Solar Beam effect_type debe ser CHARGE. Actual: %s" % solar_beam["effect_type"])
	assert(solar_beam["dmg"] == 56, "Solar Beam base DMG debe ser 56. Actual: %d" % solar_beam["dmg"])
	assert(solar_beam["cost"] == 4, "Solar Beam coste debe ser 4. Actual: %d" % solar_beam["cost"])
	print("✓ 1.1 Solar Beam: 56 DMG, Coste 4⚡, Type GRASS, Effect CHARGE")
	
	var dig = GameData.get_move_data("Dig")
	assert(dig != null and not dig.is_empty(), "Dig debe existir")
	assert(dig["effect_type"] == "DIG", "Dig effect_type debe ser DIG. Actual: %s" % dig["effect_type"])
	assert(dig["dmg"] == 18, "Dig base DMG debe ser 18. Actual: %d" % dig["dmg"])
	assert(dig["cost"] == 2, "Dig coste debe ser 2. Actual: %d" % dig["cost"])
	print("✓ 1.2 Dig: 18 DMG, Coste 2⚡, Type GROUND, Effect DIG")
	
	var bounce = GameData.get_move_data("Bounce")
	assert(bounce != null and not bounce.is_empty(), "Bounce debe existir")
	assert(bounce["effect_type"] == "BOUNCE", "Bounce effect_type debe ser BOUNCE. Actual: %s" % bounce["effect_type"])
	assert(bounce["type"] == "FLYING", "Bounce tipo debe ser FLYING. Actual: %s" % bounce["type"])
	assert(bounce["dmg"] == 22, "Bounce base DMG debe ser 22. Actual: %d" % bounce["dmg"])
	print("✓ 1.3 Bounce: 22 DMG, Coste 2⚡, Type FLYING, Effect BOUNCE")
	
	# --- TEST 2: Mecánica de 2 turnos de Solar Beam ---
	print("\n--- TEST 2: Turno 1 Carga y Turno 2 Impacto de Solar Beam ---")
	var p1 = GameData.create_pokemon_instance(5) # Venusaur (Grass)
	var e1 = GameData.create_pokemon_instance(9) # Blastoise (Water, débil a Grass)
	p1.current_energy = 5
	p1.attack = 40
	e1.defense = 40
	var e1_initial_hp = e1.current_hp
	battle_scene.player_team = [p1]
	battle_scene.enemy_team = [e1]
	battle_scene.active_player_idx = 0
	battle_scene.active_enemy_idx = 0
	
	# Turno 1: Venusaur inicia Solar Beam
	var sb_instance = GameData.get_move_instance("Solar Beam")
	battle_scene.perform_attack(p1, e1, sb_instance, false, 4, dummy_v1, dummy_v2)
	assert(p1.current_energy == 1, "Venusaur gastó 4⚡ (le queda 1⚡). Actual: %d" % p1.current_energy)
	assert(e1.current_hp == e1_initial_hp, "En turno 1, rival no debe recibir daño (absorbe luz). Actual: %d" % e1.current_hp)
	assert(p1.charging_move == "Solar Beam", "Venusaur debe tener charging_move == 'Solar Beam'. Actual: %s" % p1.charging_move)
	print("✓ 2.1 Turno 1 Solar Beam: gastó 4⚡, 0 DMG recibido por el rival, charging_move = 'Solar Beam'")
	
	# Turno 2: Inicio de turno de Venusaur libera Solar Beam
	var handled = battle_scene._process_turn_start_status(p1, e1, dummy_v1, dummy_v2, true)
	assert(handled == true, "_process_turn_start_status debe retornar true para movimiento cargado")
	assert(p1.charging_move == "", "charging_move debe limpiarse tras disparar")
	assert(p1.current_energy == 1, "No debe gastar energía extra en el Turno 2 (sigue en 1⚡). Actual: %d" % p1.current_energy)
	var dmg_taken = e1_initial_hp - e1.current_hp
	assert(dmg_taken > 50, "Solar Beam contra Blastoise (débil a Grass x2) debe ser devastador (>50 DMG). Actual: %d" % dmg_taken)
	print("✓ 2.2 Turno 2 Solar Beam: disparo automático sin coste extra, infligió %d DMG devastador" % dmg_taken)
	
	# --- TEST 3: Mecánica de 2 turnos de Dig (Excavar) ---
	print("\n--- TEST 3: Turno 1 Madriguera subterránea y Turno 2 Ataque de Dig ---")
	var p2 = GameData.create_pokemon_instance(50) # Diglett
	var e2 = GameData.create_pokemon_instance(25) # Pikachu
	p2.current_energy = 3
	p2.attack = 30
	e2.defense = 30
	var e2_initial_hp = e2.current_hp
	var p2_initial_hp = p2.current_hp
	battle_scene.player_team = [p2]
	battle_scene.enemy_team = [e2]
	battle_scene.active_player_idx = 0
	battle_scene.active_enemy_idx = 0
	
	# Turno 1: Diglett cava
	var dig_inst = GameData.get_move_instance("Dig")
	battle_scene.perform_attack(p2, e2, dig_inst, false, 2, dummy_v1, dummy_v2)
	assert(p2.current_energy == 1, "Diglett gastó 2⚡ (le queda 1⚡). Actual: %d" % p2.current_energy)
	assert(e2.current_hp == e2_initial_hp, "En turno 1, rival no recibe daño al cavar. Actual: %d" % e2.current_hp)
	assert(p2.is_digging == true, "Diglett debe tener is_digging == true")
	assert(p2.charging_move == "Dig", "Diglett debe tener charging_move == 'Dig'")
	print("✓ 3.1 Turno 1 Dig: gastó 2⚡, 0 DMG al rival, is_digging = true, charging_move = 'Dig'")
	
	# Turno rival intermedio: Pikachu intenta atacar con Quick Attack (tipo Normal, no Ground)
	var quick_attack = GameData.get_move_instance("Quick Attack")
	battle_scene.perform_attack(e2, p2, quick_attack, false, 1, dummy_v2, dummy_v1)
	assert(p2.current_hp == p2_initial_hp, "Diglett subterráneo es inmune a ataques no-Ground. Actual HP: %d" % p2.current_hp)
	print("✓ 3.2 Turno rival: Quick Attack falló completamente contra Diglett bajo tierra (0 DMG recibido)")
	
	# Turno 2: Diglett emerge y golpea
	var dig_handled = battle_scene._process_turn_start_status(p2, e2, dummy_v1, dummy_v2, true)
	assert(dig_handled == true, "_process_turn_start_status debe manejar el ataque de Dig")
	assert(p2.is_digging == false, "is_digging debe limpiarse al emerger")
	assert(p2.charging_move == "", "charging_move debe limpiarse")
	var dig_dmg = e2_initial_hp - e2.current_hp
	assert(dig_dmg >= 15, "Dig debe causar daño de impacto al emerger (>= 15 DMG). Actual: %d" % dig_dmg)
	print("✓ 3.3 Turno 2 Dig: emergió de la tierra y causó %d DMG a Pikachu" % dig_dmg)
	
	# --- TEST 4: Vulnerabilidad de Dig frente a Earthquake (x2 daño) ---
	print("\n--- TEST 4: Earthquake impacta a Pokémon bajo tierra con x2 DMG ---")
	var p3 = GameData.create_pokemon_instance(19) # Rattata (Normal type: neutral a Ground)
	var e3 = GameData.create_pokemon_instance(76) # Golem con Earthquake
	p3.current_hp = 120
	p3.max_hp = 120
	p3.is_digging = true
	p3.charging_move = "Dig"
	p3.defense = 20
	e3.attack = 20
	battle_scene.player_team = [p3]
	battle_scene.enemy_team = [e3]
	battle_scene.active_player_idx = 0
	battle_scene.active_enemy_idx = 0
	var earthquake = GameData.get_move_instance("Earthquake")
	battle_scene.perform_attack(e3, p3, earthquake, false, 4, dummy_v2, dummy_v1)
	assert(p3.is_digging == false, "Earthquake debe sacar al Pokémon de la tierra (is_digging = false)")
	assert(p3.charging_move == "", "Earthquake interrumpe el movimiento de carga (charging_move = '')")
	var eq_dmg = 120 - p3.current_hp
	assert(eq_dmg == 96, "Earthquake debe causar 48 * 2 = 96 DMG contra rival bajo tierra. Actual: %d" % eq_dmg)
	print("✓ 4.1 Earthquake conectó x2 DMG (96 DMG) e interrumpió al rival bajo tierra")
	
	# --- TEST 5: Movimientos de descanso (REST: Hyper Beam) ---
	print("\n--- TEST 5: Cooldown / Descanso tras Hyper Beam ---")
	var p4 = GameData.create_pokemon_instance(143) # Snorlax
	var e4 = GameData.create_pokemon_instance(143) # Snorlax
	p4.current_energy = 5
	p4.attack = 40
	e4.defense = 40
	battle_scene.player_team = [p4]
	battle_scene.enemy_team = [e4]
	battle_scene.active_player_idx = 0
	battle_scene.active_enemy_idx = 0
	var hyper_beam = GameData.get_move_instance("Hyper Beam")
	battle_scene.perform_attack(p4, e4, hyper_beam, false, 5, dummy_v1, dummy_v2)
	assert(p4.rest_next_turn == true, "Tras Hyper Beam, rest_next_turn debe ser true")
	assert(p4.current_energy == 0, "Energía debe ser 0")
	print("✓ 5.1 Hyper Beam impactó y marcó rest_next_turn = true")
	
	var rest_handled = battle_scene._process_turn_start_status(p4, e4, dummy_v1, dummy_v2, true)
	assert(rest_handled == true, "Turno de descanso debe ser procesado y retornar true")
	assert(p4.rest_next_turn == false, "rest_next_turn debe limpiarse tras descansar")
	assert(p4.current_energy == 1, "Descanso debe recargar +1⚡ de fatiga. Actual: %d" % p4.current_energy)
	print("✓ 5.2 Turno de descanso completado: recuperó +1⚡ y limpió descanso")

	# --- TEST 6: Mecánica de 2 turnos de Bounce (Bote) ---
	print("\n--- TEST 6: Turno 1 En el aire (Evasión) y Turno 2 Caída en picado de Bounce ---")
	var p5 = GameData.create_pokemon_instance(325) # Spoink (Bounce)
	var e5 = GameData.create_pokemon_instance(19)  # Rattata
	p5.current_energy = 3
	p5.attack = 30
	e5.defense = 30
	var e5_initial_hp = e5.current_hp
	var p5_initial_hp = p5.current_hp
	battle_scene.player_team = [p5]
	battle_scene.enemy_team = [e5]
	battle_scene.active_player_idx = 0
	battle_scene.active_enemy_idx = 0
	
	# Turno 1: Spoink usa Bounce
	var bounce_inst = GameData.get_move_instance("Bounce")
	battle_scene.perform_attack(p5, e5, bounce_inst, false, 2, dummy_v1, dummy_v2)
	assert(p5.current_energy == 1, "Spoink gastó 2⚡ (le queda 1⚡). Actual: %d" % p5.current_energy)
	assert(e5.current_hp == e5_initial_hp, "En turno 1, rival no recibe daño mientras salta. Actual: %d" % e5.current_hp)
	assert(p5.is_evasive == true, "Spoink debe estar en el aire con is_evasive = true")
	assert(p5.charging_move == "Bounce", "Spoink debe tener charging_move = 'Bounce'")
	print("✓ 6.1 Turno 1 Bounce: gastó 2⚡, 0 DMG, is_evasive = true, charging_move = 'Bounce'")
	
	# Turno rival intermedio: Rattata intenta atacar a Spoink en el aire
	var tackle_inst = GameData.get_move_instance("Tackle")
	battle_scene.perform_attack(e5, p5, tackle_inst, false, 0, dummy_v2, dummy_v1)
	assert(p5.current_hp == p5_initial_hp, "Spoink en el aire evade el ataque. Actual HP: %d" % p5.current_hp)
	print("✓ 6.2 Turno rival: Tackle evadido completamente mientras Spoink estaba en el aire")
	
	# Turno 2: Spoink cae en picado y golpea
	var bounce_handled = battle_scene._process_turn_start_status(p5, e5, dummy_v1, dummy_v2, true)
	assert(bounce_handled == true, "_process_turn_start_status debe manejar el impacto de Bounce")
	assert(p5.is_evasive == false, "is_evasive debe limpiarse al caer")
	assert(p5.charging_move == "", "charging_move debe limpiarse")
	var bounce_dmg = e5_initial_hp - e5.current_hp
	assert(bounce_dmg >= 20, "Bounce debe causar daño al caer (>= 20 DMG). Actual: %d" % bounce_dmg)
	print("✓ 6.3 Turno 2 Bounce: cayó en picado e infligió %d DMG" % bounce_dmg)

	print("\n=== TODOS LOS TESTS DE MOVIMIENTOS DE 2 TURNOS Y TIMING PASARON AL 100%! ===")
	get_tree().quit(0)
