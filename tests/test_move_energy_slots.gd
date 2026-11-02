extends Node

func _ready() -> void:
	print("\n=== TEST DE SLOTS DE ENERGÍA Y DAÑO FRACCIONADO ===")
	GameData.is_campaign_mode = false
	
	var battle_scene = load("res://scenes/battle.tscn")
	var battle = battle_scene.instantiate()
	add_child(battle)
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	# -------------------------------------------------------------
	# TEST 1: REGLA MATEMÁTICA EXACTA DEL USUARIO (Coste 3, 12 DMG con efecto)
	# "si pagas 1 energia pegas 4 sin efecto, si pagas 2 pegas 8 sin efecto, si pagas 3 pegas 12 y se activa el efecto"
	# -------------------------------------------------------------
	print("\n--- TEST 1: Regla Matemática Exacta (Coste 3, 12 DMG) ---")
	var test_move_3cost = {
		"id": 999,
		"name": "Super Ataque",
		"type": "NORMAL",
		"base_damage": 12,
		"cost": 3,
		"min_energy_req": 1,
		"boost_cost": 0,
		"boost_damage": 0,
		"effect_type": "SLOW_FOE",
		"reduces_foe_speed": true,
		"can_boost": false,
		"description": "Prueba de daño proporcional"
	}
	
	var dmg_1 = battle.calculate_move_damage(test_move_3cost, 1)
	var dmg_2 = battle.calculate_move_damage(test_move_3cost, 2)
	var dmg_3 = battle.calculate_move_damage(test_move_3cost, 3)
	
	print("  1⚡ gastada -> Daño calculado: %d (Esperado: 4)" % dmg_1)
	print("  2⚡ gastadas -> Daño calculado: %d (Esperado: 8)" % dmg_2)
	print("  3⚡ gastadas -> Daño calculado: %d (Esperado: 12)" % dmg_3)
	
	assert(dmg_1 == 4, "1⚡ debe causar exactamente 4 DMG")
	assert(dmg_2 == 8, "2⚡ debe causar exactamente 8 DMG")
	assert(dmg_3 == 12, "3⚡ debe causar exactamente 12 DMG")
	print("✓ Fórmula de daño fraccionado proporcional verificada al 100%")
	
	# -------------------------------------------------------------
	# TEST 2: SLOTS VISUALES EN COMBATE REAL (Ivysaur vs Squirtle)
	# Ivysaur: Move 1 = Polvo Venenoso (Cost 1), Move 2 = Látigo Cepa (Cost 2, Base 8, -1 SPD)
	# -------------------------------------------------------------
	print("\n--- TEST 2: Generación e interacción con Slots en Látigo Cepa (Coste 2) ---")
	GameData.player_team_ids = [4] # Ivysaur
	GameData.enemy_team_ids = [2]  # Squirtle
	battle.start_new_game()
	await get_tree().process_frame
	await get_tree().process_frame
	
	var p = battle.get_active_player()
	var e = battle.get_active_enemy()
	p.current_energy = 3
	battle.set_controls_enabled(true)
	battle.update_ui()
	await get_tree().process_frame
	
	# Verificar que Move2Slots contiene el Label de costo requerido y 2 botones de slot (1⚡ y 2⚡)
	var slots2_all = battle.move2_slots.get_children()
	var cost_labels2 = slots2_all.filter(func(c): return c is Label)
	var slot_buttons2 = slots2_all.filter(func(c): return c is Button)
	print("  Elementos en Move 2 (Látigo Cepa): %d labels, %d botones" % [cost_labels2.size(), slot_buttons2.size()])
	assert(cost_labels2.size() == 1, "Debe haber 1 Label de costo requerido")
	assert(cost_labels2[0].text == "Req: 2⚡", "El label debe mostrar 'Req: 2⚡'")
	assert(slot_buttons2.size() == 2, "Látigo Cepa (Coste 2) debe generar 2 slots: 1⚡ y 2⚡")
	assert(slot_buttons2[0].text == "1⚡", "El slot 0 debe decir '1⚡'")
	assert(slot_buttons2[1].text == "2⚡", "El slot 1 debe decir '2⚡'")
	assert(slot_buttons2[0].custom_minimum_size == Vector2(28, 28), "El botón debe ser redondo 28x28")
	
	# Por defecto con 3 de energía disponible, debe estar seleccionado el coste completo (2⚡)
	assert(battle.selected_energy_move2 == 2, "Por defecto con energía suficiente debe seleccionarse 2⚡")
	print("  Texto actual de BtnMove2 (con 2⚡ seleccionado):")
	print("  \"%s\"" % battle.btn_move2.text.replace("\n", " -- "))
	assert("Uses: 2/2⚡" in battle.btn_move2.text, "Debe indicar Uses: 2/2⚡")
	
	# Ahora el jugador hace clic en el slot 1⚡:
	print("\n  -> Jugador hace clic en el Slot 1⚡ para cambiar a gasto parcial:")
	slot_buttons2[0].emit_signal("pressed")
	await get_tree().process_frame
	
	assert(battle.selected_energy_move2 == 1, "selected_energy_move2 debe haber cambiado a 1")
	print("  Texto actualizado de BtnMove2 (con 1⚡ seleccionado):")
	print("  \"%s\"" % battle.btn_move2.text.replace("\n", " -- "))
	assert("[Partial]" in battle.btn_move2.text, "BtnMove2 debe actualizarse inmediatamente a [Partial]")
	assert("Uses: 1/2⚡" in battle.btn_move2.text, "BtnMove2 debe mostrar 'Uses: 1/2⚡'")
	print("✓ El botón de Move alteró sus detalles en tiempo real sin abrir ninguna ventana emergente")
	
	# -------------------------------------------------------------
	# TEST 3: EJECUCIÓN DIRECTA SIN VENTANA EMERGENTE
	# -------------------------------------------------------------
	print("\n--- TEST 3: Ejecución de ataque con coste parcial seleccionado (1⚡) ---")
	var initial_energy = p.current_energy # 3
	var foe_initial_spd = battle.get_pokemon_effective_speed(e, p)
	
	# Presionar el botón del ataque 2 (Látigo Cepa con 1⚡ seleccionado)
	battle.is_player_turn = true
	battle.can_player_act = true
	battle.is_busy = false
	battle._on_move2_pressed()
	
	# Verificar que el modal de energía NUNCA se abrió
	assert(battle.energy_modal.visible == false, "El EnergyModal NO debe abrirse, el ataque debe ejecutarse directo")
	print("✓ Ninguna ventana emergente se abrió")
	
	# Verificar consumo de energía: gastó exactamente 1⚡
	assert(p.current_energy == initial_energy - 1, "Debe haber consumido solo 1⚡ (le quedan %d⚡)" % p.current_energy)
	print("✓ Gastó exactamente 1⚡ de energía (Restante: %d⚡)" % p.current_energy)
	
	# Verificar que el efecto secundario de velocidad NO se activó por ser gasto parcial
	assert(e.temp_speed_mod == 0, "Al pagar 1⚡ parcial, la velocidad del rival NO debe reducirse")
	print("✓ Efecto secundario NO activado debido a energía parcial")
	
	# -------------------------------------------------------------
	# TEST 4: RESPETO DEL MÍNIMO REQUERIDO (Hydro Pump min_req 3)
	# -------------------------------------------------------------
	print("\n--- TEST 4: Respeto del mínimo de energía requerido (Blastoise Hydro Pump) ---")
	GameData.player_team_ids = [9] # Blastoise
	battle.start_new_game()
	await get_tree().process_frame
	await get_tree().process_frame
	
	var blastoise = battle.get_active_player()
	blastoise.current_energy = 8
	battle.set_controls_enabled(true)
	battle.update_ui()
	await get_tree().process_frame
	
	# Hydro Pump: cost 3, min_energy_req 3
	var hp_slots_all = battle.move2_slots.get_children()
	var hp_buttons = hp_slots_all.filter(func(c): return c is Button)
	var hp_labels = hp_slots_all.filter(func(c): return c is Label)
	print("  Slots generados para Hidrobomba (Cost 3, Min 3): %d label(s), %d slot button(s)" % [hp_labels.size(), hp_buttons.size()])
	assert(hp_labels.size() == 1, "Debe haber 1 label de costo requerido")
	assert(hp_labels[0].text == "Req: 3⚡", "El label debe indicar Req: 3⚡")
	assert(hp_buttons.size() == 1, "Hidrobomba solo debe ofrecer el slot de su mínimo (3⚡)")
	assert(hp_buttons[0].text == "3⚡", "El slot debe ser '3⚡'")
	assert(battle.selected_energy_move2 == 3, "Debe pagar 3⚡ obligatoriamente")
	print("✓ Se respeta estrictamente el mínimo de energía del movimiento")
	
	# -------------------------------------------------------------
	# TEST 5: CAPTURA DE PANTALLA
	# -------------------------------------------------------------
	print("\n--- TEST 5: Captura visual de los slots sobre los botones de Move ---")
	battle.set_controls_enabled(true)
	# Seleccionar Ivysaur vs Squirtle de nuevo para captura limpia
	GameData.player_team_ids = [4]
	GameData.enemy_team_ids = [2]
	battle.start_new_game()
	await get_tree().process_frame
	await get_tree().process_frame
	
	var ivysaur = battle.get_active_player()
	ivysaur.current_energy = 4
	battle.set_controls_enabled(true)
	battle.update_ui()
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Capturar estado 1: Slot 2⚡ seleccionado en Látigo Cepa
	var img = get_viewport().get_texture().get_image()
	img.save_png("res://tests/move_slots_full_screenshot.png")
	img.save_png("C:/Users/rafag/.gemini/antigravity/brain/dca5182f-4733-4c52-8dfc-ccfff3b26dd9/move_slots_full_screenshot.png")
	print("✓ Captura guardada: move_slots_full_screenshot.png")
	
	# Cambiar a Slot 1⚡ en Látigo Cepa y capturar estado 2
	var ivysaur_buttons2 = battle.move2_slots.get_children().filter(func(c): return c is Button)
	ivysaur_buttons2[0].emit_signal("pressed")
	await get_tree().process_frame
	await get_tree().process_frame
	
	var img2 = get_viewport().get_texture().get_image()
	img2.save_png("res://tests/move_slots_partial_screenshot.png")
	img2.save_png("C:/Users/rafag/.gemini/antigravity/brain/dca5182f-4733-4c52-8dfc-ccfff3b26dd9/move_slots_partial_screenshot.png")
	print("✓ Captura guardada: move_slots_partial_screenshot.png")
	
	# Estado 3: Rival a 3 HP (Knockout con 1⚡ gracias a ventaja de tipo +2)
	# Ivysaur Grass vs Squirtle Water: 4 DMG base + 2 debilidad = 6 DMG vs 3 HP -> Knockout!
	var sq = battle.get_active_enemy()
	sq.current_hp = 3
	battle.update_ui()
	await get_tree().process_frame
	await get_tree().process_frame
	
	print("  Texto de BtnMove2 con rival a 3 HP:")
	print("  \"%s\"" % battle.btn_move2.text.replace("\n", " -- "))
	assert("Knockout" in battle.btn_move2.text or "Remate" in battle.btn_move2.text, "Debe mostrar indicador de Knockout!")
	
	var img3 = get_viewport().get_texture().get_image()
	img3.save_png("res://tests/move_slots_remate_screenshot.png")
	img3.save_png("C:/Users/rafag/.gemini/antigravity/brain/dca5182f-4733-4c52-8dfc-ccfff3b26dd9/move_slots_remate_screenshot.png")
	print("✓ Captura guardada: move_slots_remate_screenshot.png")
	
	print("\n=======================================================")
	print("✓ TODOS LOS TESTS DE SLOTS DE ENERGÍA Y DAÑO PASARON CON ÉXITO")
	print("=======================================================\n")
	get_tree().quit(0)
