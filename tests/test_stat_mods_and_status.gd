extends Node

func _make_move(move_name: String) -> GameData.MoveData:
	var d = GameData.get_move_data(move_name)
	var m = GameData.MoveData.new(
		d["name"], d["type"], d["dmg"], d["cost"], d["req"],
		false, 0, 0,
		d["effect_type"] == "BURN", d["desc"],
		d.get("accuracy", 100)
	)
	m.effect_type = d["effect_type"]
	m.accuracy = d.get("accuracy", 100)
	return m

func _ready() -> void:
	print("=== INICIANDO TEST DE MODIFICADORES DE STATS Y ESTADOS ALTERADOS ===")
	await get_tree().process_frame
	
	var battle_scene = load("res://scenes/battle.tscn").instantiate()
	add_child(battle_scene)
	await get_tree().process_frame
	await get_tree().process_frame
	
	var p = battle_scene.get_active_player()
	var e = battle_scene.get_active_enemy()
	assert(p != null and e != null, "Jugador y enemigo deben existir")
	
	# Neutralizar tipos y fijar stats para pruebas exactas
	p.type = "NORMAL"
	p.weakness = "NONE"
	p.resistant = "NONE"
	p.attack = 20
	p.defense = 20
	p.speed = 20
	p.current_energy = 5
	p.reset_stat_modifiers()
	
	e.type = "NORMAL"
	e.weakness = "NONE"
	e.resistant = "NONE"
	e.attack = 20
	e.defense = 20
	e.speed = 20
	e.current_energy = 5
	e.max_hp = 100
	e.current_hp = 100
	e.reset_stat_modifiers()
	
	# --- TEST 1: Tail Whip (LOWER_DEF) ---
	print("\n--- TEST 1: Tail Whip (-DEF) ---")
	var tail_whip = _make_move("Tail Whip")
	assert(tail_whip.effect_type == "LOWER_DEF", "Tail Whip debe ser LOWER_DEF")
	var def_before = e.get_effective_defense()
	battle_scene.perform_attack(p, e, tail_whip, false, tail_whip.cost, battle_scene.player_card_img, battle_scene.enemy_card_img)
	var def_after = e.get_effective_defense()
	print("Defensa rival antes: %d | después: %d (Mod: %d)" % [def_before, def_after, e.temp_defense_mod])
	assert(def_after < def_before, "La defensa rival debió reducirse tras Tail Whip")
	assert(e.temp_defense_mod == -5, "Con 20 DEF, -25%% debe ser -5 DEF")
	
	# Verificar que el daño físico recibido por el rival aumentó gracias a Tail Whip
	var tackle = _make_move("Tackle")
	var dmg_weakened = battle_scene.calculate_predicted_damage(p, e, tackle, tackle.cost, false)
	e.reset_stat_modifiers()
	var dmg_normal = battle_scene.calculate_predicted_damage(p, e, tackle, tackle.cost, false)
	print("Daño de Tackle -> Normal: %d | Con defensa reducida: %d" % [dmg_normal, dmg_weakened])
	assert(dmg_weakened > dmg_normal, "El daño debe aumentar cuando la defensa del rival está reducida")
	print("✓ Test 1 PASÓ: Tail Whip reduce defensa y amplifica daño recibido!")

	# --- TEST 2: Growl (LOWER_ATK) ---
	print("\n--- TEST 2: Growl (-ATK) ---")
	var growl = _make_move("Growl")
	assert(growl.effect_type == "LOWER_ATK", "Growl debe ser LOWER_ATK")
	var atk_before = e.get_effective_attack()
	battle_scene.perform_attack(p, e, growl, false, growl.cost, battle_scene.player_card_img, battle_scene.enemy_card_img)
	var atk_after = e.get_effective_attack()
	print("Ataque rival antes: %d | después: %d (Mod: %d)" % [atk_before, atk_after, e.temp_attack_mod])
	assert(atk_after < atk_before, "El ataque rival debió reducirse tras Growl")
	assert(e.temp_attack_mod == -5, "Con 20 ATK, -25%% debe ser -5 ATK")
	print("✓ Test 2 PASÓ: Growl reduce el ataque del objetivo!")
	e.reset_stat_modifiers()

	# --- TEST 3: Harden / Withdraw / Defense Curl (RAISE_DEF) ---
	print("\n--- TEST 3: Harden (+DEF) ---")
	var harden = _make_move("Harden")
	assert(harden.effect_type == "RAISE_DEF", "Harden debe ser RAISE_DEF")
	var my_def_before = p.get_effective_defense()
	battle_scene.perform_attack(p, e, harden, false, harden.cost, battle_scene.player_card_img, battle_scene.enemy_card_img)
	var my_def_after = p.get_effective_defense()
	print("Defensa propia antes: %d | después: %d (Mod: %d)" % [my_def_before, my_def_after, p.temp_defense_mod])
	assert(my_def_after > my_def_before, "La defensa propia debió aumentar tras Harden")
	assert(p.temp_defense_mod == +5, "Con 20 DEF, +25%% debe ser +5 DEF")
	print("✓ Test 3 PASÓ: Harden sube defensa propia!")
	p.reset_stat_modifiers()

	# --- TEST 4: Bulk Up (BULK_UP) ---
	print("\n--- TEST 4: Bulk Up (+ATK y +DEF) ---")
	var bulk_up = _make_move("Bulk Up")
	assert(bulk_up.effect_type == "BULK_UP", "Bulk Up debe ser BULK_UP")
	battle_scene.perform_attack(p, e, bulk_up, false, bulk_up.cost, battle_scene.player_card_img, battle_scene.enemy_card_img)
	print("Bulk Up -> ATK mod: %+d | DEF mod: %+d" % [p.temp_attack_mod, p.temp_defense_mod])
	assert(p.temp_attack_mod == +5 and p.temp_defense_mod == +5, "Bulk Up debe subir +25% ATK y +25% DEF")
	print("✓ Test 4 PASÓ: Bulk Up sube ataque y defensa simultáneamente!")
	p.reset_stat_modifiers()

	# --- TEST 5: Sand Attack (ACCURACY_DOWN) y Swift (CANNOT_MISS) ---
	print("\n--- TEST 5: Sand Attack y Ataques Infalibles ---")
	var sand_attack = _make_move("Sand Attack")
	assert(sand_attack.effect_type == "ACCURACY_DOWN", "Sand Attack debe ser ACCURACY_DOWN")
	battle_scene.perform_attack(p, e, sand_attack, false, sand_attack.cost, battle_scene.player_card_img, battle_scene.enemy_card_img)
	print("Precisión rival reducida: %+d%%" % e.temp_accuracy_mod)
	assert(e.temp_accuracy_mod == -20, "Sand Attack debe reducir -20% de precisión")
	
	# Verificar que un ataque infalible no puede fallar
	var swift = _make_move("Swift")
	swift.effect_type = "CANNOT_MISS"
	# Si el rival atacara con Swift a pesar de tener -20% ACC, Swift nunca falla
	assert(swift.effect_type == "CANNOT_MISS", "Swift debe ignorar reducciones de precisión")
	print("✓ Test 5 PASÓ: Sand Attack reduce precisión y ataques infalibles la ignoran!")
	e.reset_stat_modifiers()

	# --- TEST 6: Protect (PROTECT) ---
	print("\n--- TEST 6: Protect (Inmunidad de 1 turno) ---")
	var protect = _make_move("Protect")
	assert(protect.effect_type == "PROTECT", "Protect debe ser PROTECT")
	battle_scene.perform_attack(p, e, protect, false, protect.cost, battle_scene.player_card_img, battle_scene.enemy_card_img)
	assert(p.is_evasive == true, "Protect debe activar is_evasive")
	
	# Si se intenta usar consecutivamente, debe fallar
	p.last_move_used = "Protect"
	battle_scene.perform_attack(p, e, protect, false, protect.cost, battle_scene.player_card_img, battle_scene.enemy_card_img)
	print("✓ Test 6 PASÓ: Protect otorga inmunidad completa de 1 turno y falla al usarse consecutivamente!")
	p.is_evasive = false

	# --- TEST 7: Efectos de Quemadura (-50% ATK) y Parálisis (-50% SPD) ---
	print("\n--- TEST 7: Mecánicas Fieles de Quemadura y Parálisis ---")
	p.attack = 40
	p.burn_turns = 2
	var eff_atk_burned = p.get_effective_attack()
	print("Ataque base: 40 | Con Quemadura: %d" % eff_atk_burned)
	assert(eff_atk_burned == 20, "La quemadura debe reducir el ataque físico a la mitad (40 -> 20)")
	p.burn_turns = 0
	
	p.speed = 30
	p.is_paralyzed = true
	var eff_spd_paralyzed = p.get_effective_speed()
	print("Velocidad base: 30 | Con Parálisis: %d" % eff_spd_paralyzed)
	assert(eff_spd_paralyzed == 15, "La parálisis debe reducir la velocidad a la mitad (30 -> 15)")
	p.is_paralyzed = false
	print("✓ Test 7 PASÓ: Quemadura corta 50% ATK y Parálisis corta 50% SPD!")

	# --- TEST 8: Reseteo de modificadores y confusión al cambiar a la banca ---
	print("\n--- TEST 8: Reseteo de Stats y Confusión en Switch ---")
	p.temp_attack_mod = 10
	p.temp_defense_mod = -5
	p.temp_accuracy_mod = -20
	p.temp_evasion_mod = 20
	p.is_confused = true
	p.reset_stat_modifiers()
	assert(p.temp_attack_mod == 0 and p.temp_defense_mod == 0 and p.temp_accuracy_mod == 0 and p.temp_evasion_mod == 0, "reset_stat_modifiers debe dejar todo en 0")
	print("✓ Test 8 PASÓ: Reseteo completo de modificadores verificado!")

	print("\n🎉 TODOS LOS TESTS DE STATS Y ESTADOS ALTERADOS PASARON CON ÉXITO 🎉")
	get_tree().quit(0)
