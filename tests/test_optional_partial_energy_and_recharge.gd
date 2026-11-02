extends Node

func _ready() -> void:
	print("\n=== TEST DE RECARGA DINÁMICA Y SELECCIÓN OPCIONAL DE ENERGÍA ===")
	
	GameData.is_campaign_mode = false
	
	# Instanciar batalla
	var battle_packed = load("res://scenes/battle.tscn")
	var battle = battle_packed.instantiate()
	add_child(battle)
	
	# -------------------------------------------------------------
	# TEST 1: RECARGA DINÁMICA SEGÚN RECOVER_AMOUNT DEL POKÉMON ACTIVO
	# -------------------------------------------------------------
	print("\n--- TEST 1: Botón de Recarga Dinámica (+%d⚡) ---")
	
	# Caso 1.1: Rattata (recover = 1 en CSV)
	GameData.player_team_ids = [19] # Rattata
	GameData.enemy_team_ids = [1]   # Charmander
	battle.start_new_game()
	await get_tree().process_frame
	await get_tree().process_frame
	
	var p = battle.get_active_player()
	var expected_text = "🔋 Recargar (+%d⚡)" % p.recover_amount
	assert(battle.btn_recover.text == expected_text, "Botón de %s debe ser '%s', pero dice: '%s'" % [p.name, expected_text, battle.btn_recover.text])
	print("✓ %s (recover = %d) muestra: '%s'" % [p.name, p.recover_amount, battle.btn_recover.text])
	
	# Caso 1.2: Bulbasaur (recover = 2 en CSV)
	GameData.player_team_ids = [0] # Bulbasaur
	battle.start_new_game()
	await get_tree().process_frame
	await get_tree().process_frame
	
	p = battle.get_active_player()
	expected_text = "🔋 Recargar (+%d⚡)" % p.recover_amount
	assert(battle.btn_recover.text == expected_text, "Botón de %s debe ser '%s', pero dice: '%s'" % [p.name, expected_text, battle.btn_recover.text])
	print("✓ %s (recover = %d) muestra: '%s'" % [p.name, p.recover_amount, battle.btn_recover.text])
	
	# Caso 1.3: Ivysaur (recover = 3 en CSV)
	GameData.player_team_ids = [4] # Ivysaur
	battle.start_new_game()
	await get_tree().process_frame
	await get_tree().process_frame
	
	p = battle.get_active_player()
	expected_text = "🔋 Recargar (+%d⚡)" % p.recover_amount
	assert(battle.btn_recover.text == expected_text, "Botón de %s debe ser '%s', pero dice: '%s'" % [p.name, expected_text, battle.btn_recover.text])
	print("✓ %s (recover = %d) muestra: '%s'" % [p.name, p.recover_amount, battle.btn_recover.text])
	
	# Caso 1.4: Venusaur (recover = 4 en CSV)
	GameData.player_team_ids = [5] # Venusaur
	battle.start_new_game()
	await get_tree().process_frame
	await get_tree().process_frame
	
	p = battle.get_active_player()
	expected_text = "🔋 Recargar (+%d⚡)" % p.recover_amount
	assert(battle.btn_recover.text == expected_text, "Botón de %s debe ser '%s', pero dice: '%s'" % [p.name, expected_text, battle.btn_recover.text])
	print("✓ %s (recover = %d) muestra: '%s'" % [p.name, p.recover_amount, battle.btn_recover.text])
	
	# -------------------------------------------------------------
	# TEST 2: APERTURA DE MODAL DE SELECCIÓN DE ENERGÍA Y REMATE
	# -------------------------------------------------------------
	print("\n--- TEST 2: Modal de selección de energía para rematar o regular gasto ---")
	
	# Venusaur: Move 1 = Giga Drain (Cost 2, Base 10 DMG, drain 50%)
	# Contra Charmander (FIRE), resiste PLANTA (-2 DMG).
	# Con 1⚡: 10 / 2 = 5 DMG base -> con resistencia -2 = 3 DMG efectivos.
	# Fijamos HP del rival en 3 para comprobar que 1⚡ (3 DMG) es exactamente suficiente para rematar.
	p.current_energy = 3
	var e = battle.get_active_enemy()
	e.current_hp = 3
	battle.update_ui()
	
	assert(battle.energy_modal.visible == false, "El modal de energía debe iniciar oculto")
	
	# Al presionar Move 1 (Giga Drain, coste 2, con 3⚡ disponibles), debe abrirse el modal
	battle._on_move1_pressed()
	assert(battle.energy_modal.visible == true, "El modal de energía debe ser visible tras pulsar el ataque")
	
	var options = battle.energy_modal_options.get_children()
	print("✓ Opciones generadas en el modal: %d opciones" % options.size())
	assert(options.size() >= 2, "Debe haber al menos 2 opciones (1⚡ parcial y 2⚡ completo)")
	
	var btn_1_energy: Button = options[0]
	var btn_2_energy: Button = options[1]
	
	print("  Opción 1 texto: %s" % btn_1_energy.text.replace("\n", " -- "))
	print("  Opción 2 texto: %s" % btn_2_energy.text.replace("\n", " -- "))
	
	# Verificar que la opción de 1⚡ indica Remate y calcula la resistencia
	assert("Remate" in btn_1_energy.text or "derrotar" in btn_1_energy.text, "La opción de 1⚡ debe sugerir remate al rival de 3 HP")
	assert("Resistido" in btn_1_energy.text, "La opción debe indicar el modificador de resistencia del rival")
	assert("Ahorras 2⚡" in btn_1_energy.text, "La opción de 1⚡ debe indicar que se ahorran 2⚡")
	print("✓ Opción de remate sugerida con precisión matemática y cálculo de tipo")
	
	# -------------------------------------------------------------
	# TEST 3: CANCELAR MODAL SIN GASTAR ENERGÍA
	# -------------------------------------------------------------
	print("\n--- TEST 3: Cancelar modal ---")
	battle.btn_cancel_energy.emit_signal("pressed")
	assert(battle.energy_modal.visible == false, "El modal debe cerrarse al cancelar")
	assert(p.current_energy == 3, "La energía no debe haber sido consumida al cancelar")
	assert(battle.is_player_turn == true, "Debe seguir siendo el turno del jugador")
	print("✓ Cancelación de modal funciona correctamente")
	
	# -------------------------------------------------------------
	# TEST 4: EJECUTAR ATAQUE PARCIAL (1⚡) Y REMATAR SIN DISPARAR EFECTO SECUNDARIO
	# -------------------------------------------------------------
	print("\n--- TEST 4: Ataque parcial ejecutado con 1⚡ gastando solo 1⚡ ---")
	# Reabrir modal
	battle._on_move1_pressed()
	options = battle.energy_modal_options.get_children()
	btn_1_energy = options[0]
	
	# Venusaur está con 20 HP de 32 (le bajamos HP para ver si Giga Drain drena)
	p.current_hp = 20
	var prev_p_hp = p.current_hp
	
	# Emitir click en opción de 1⚡
	btn_1_energy.emit_signal("pressed")
	
	# Verificar que el modal se cierra
	assert(battle.energy_modal.visible == false, "El modal debe cerrarse al elegir opción")
	# Verificar que gastó exactamente 1⚡ (quedando 2⚡)
	assert(p.current_energy == 2, "La energía debe ser 2 (se gastó solo 1⚡ de 3⚡), actual: %d" % p.current_energy)
	print("✓ Energía consumida con éxito: restante 2⚡ (ahorró 2⚡ para futuros turnos)")
	
	# Verificar que el rival recibió 3 DMG efectivos y quedó en 0 HP (derrotado)
	assert(e.current_hp == 0, "El rival debía ser rematado (recibir 3 DMG de 3 HP), actual: %d" % e.current_hp)
	print("✓ Daño parcial aplicado correctamente (3 DMG infligidos, enemigo rematado)")
	
	# Verificar que Giga Drain NO activó el efecto de drenado secundario porque fue parcial
	assert(p.current_hp == prev_p_hp, "Giga Drain NO debe drenar HP con ataque parcial (pagó 1 de 2⚡)")
	print("✓ Regla de efecto secundario respetada: sólo daño parcial, sin curación")
	
	# -------------------------------------------------------------
	# TEST 5: DESACTIVAR RECARGA CUANDO ENERGÍA ESTÁ LLENA
	# -------------------------------------------------------------
	print("\n--- TEST 5: Botón de recarga deshabilitado si energía al máximo ---")
	p.current_energy = p.max_energy
	battle.update_move_button_labels()
	assert(battle.btn_recover.disabled == true, "Botón recarga debe estar deshabilitado al tener energía máxima")
	print("✓ Botón de recarga deshabilitado correctamente cuando energía == max_energy")
	
	print("\n=======================================================")
	print("TODAS LAS VERIFICACIONES PASARON CON ÉXITO (EXIT CODE 0)")
	print("=======================================================")
	get_tree().quit(0)
