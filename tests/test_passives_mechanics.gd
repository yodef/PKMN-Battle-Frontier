extends Node

func _ready() -> void:
	print("--- INICIANDO TEST: MECÁNICAS DE PASIVAS ESENCIALES ---")
	test_all_passives()
	print("--- TODOS LOS TESTS DE PASIVAS PASARON EXITOSAMENTE ---")
	get_tree().quit(0)

func get_test_move(move_name: String) -> GameData.MoveData:
	var d = GameData.get_move_data(move_name)
	var m = GameData.MoveData.new(
		d["name"], d["type"], d["dmg"], d["cost"], d["req"],
		d["boost_cost"] > 0, d["boost_cost"], d["boost_dmg"],
		d["effect_type"] == "BURN", d["desc"]
	)
	m.effect_type = d["effect_type"]
	m.reduces_foe_speed = (m.effect_type == "SLOW_FOE")
	m.is_pichu_shock = (m.effect_type == "PICHU_SHOCK")
	m.causes_poison = (m.effect_type == "POISON_IF_FASTER" or m.effect_type == "POISON")
	return m

func test_all_passives() -> void:
	var battle_scene = load("res://scenes/battle.tscn")
	var battle = battle_scene.instantiate()
	add_child(battle)
	
	var dummy_v1 = Control.new()
	var dummy_v2 = Control.new()
	add_child(dummy_v1)
	add_child(dummy_v2)
	
	# ----------------------------------------------------
	# 1. TEST ROCK HEAD (Cabeza Roca) - Absorbe el 100% del recoil
	# ----------------------------------------------------
	var sudowoodo = GameData.create_pokemon_instance(196) # Sudowoodo (id: 196) con Rock Head
	assert(sudowoodo != null and sudowoodo.has_passive and sudowoodo.passive_name == "Rock Head", "Sudowoodo debe tener Rock Head")
	var target_dummy = GameData.create_pokemon_instance(19) # Rattata
	target_dummy.current_hp = 30
	target_dummy.max_hp = 30
	sudowoodo.current_hp = 20
	sudowoodo.max_hp = 20
	sudowoodo.current_energy = 5
	
	var take_down = get_test_move("Take Down") # RECOIL move
	assert(take_down.effect_type == "RECOIL", "Take Down debe ser movimiento RECOIL")
	
	battle.player_team = [sudowoodo]
	battle.enemy_team = [target_dummy]
	battle.perform_attack(sudowoodo, target_dummy, take_down, false, 2, dummy_v1, dummy_v2)
	assert(sudowoodo.current_hp == 20, "Sudowoodo no debió sufrir ningún daño de retroceso gracias a Rock Head")
	print("✓ Test 1: Rock Head absorbió 100% del recoil en Sudowoodo.")

	# ----------------------------------------------------
	# 2. TEST STURDY (Robustez) - Sobrevive golpe letal con 1 HP al 100% HP
	# ----------------------------------------------------
	var skarmory = GameData.create_pokemon_instance(236) # Skarmory (id: 236) con Sturdy
	assert(skarmory != null and skarmory.has_passive and skarmory.passive_name == "Sturdy", "Skarmory debe tener Sturdy")
	skarmory.max_hp = 12
	skarmory.current_hp = 12 # 100% Max HP
	var attacker_boss = GameData.create_pokemon_instance(7) # Charizard (id: 7)
	attacker_boss.current_energy = 8
	var lethal_fire = get_test_move("Flamethrower") # 14 DMG + 2 debilidad = 16 DMG (letal contra 12 HP)
	
	battle.player_team = [attacker_boss]
	battle.enemy_team = [skarmory]
	battle.perform_attack(attacker_boss, skarmory, lethal_fire, false, 3, dummy_v1, dummy_v2)
	assert(skarmory.current_hp == 1, "Skarmory debió resistir el golpe letal con 1 HP gracias a Sturdy (HP actual: %d)" % skarmory.current_hp)
	print("✓ Test 2: Sturdy salvó a Skarmory del KO letal dejándolo en 1 HP.")

	# ----------------------------------------------------
	# 3. TEST INTIMIDATE (Intimidación) - Debuff -2 DMG al entrar
	# ----------------------------------------------------
	var arcanine = GameData.create_pokemon_instance(62) # Arcanine (id: 62) con Intimidate
	assert(arcanine != null and arcanine.has_passive and arcanine.passive_name == "Intimidate", "Arcanine debe tener Intimidate")
	var enemy_pkmn = GameData.create_pokemon_instance(19) # Rattata
	battle.enemy_team = [enemy_pkmn]
	battle._trigger_entry_passives(arcanine, enemy_pkmn, true)
	assert(enemy_pkmn.foe_damage_debuff == 2, "El enemigo debió recibir debuff de -2 DMG por Intimidate")
	print("✓ Test 3: Intimidate redujo el ataque rival en -2 DMG.")

	# ----------------------------------------------------
	# 4. TEST LEVITATE (Levitación) - Inmunidad a Tierra y Tormenta de Arena
	# ----------------------------------------------------
	var gengar = GameData.create_pokemon_instance(98) # Gengar (id: 98) con Levitate
	assert(gengar != null and gengar.has_passive and gengar.passive_name == "Levitate", "Gengar debe tener Levitate")
	var ground_attacker = GameData.create_pokemon_instance(28) # Sandslash
	ground_attacker.current_energy = 5
	var eq_move = get_test_move("Earthquake") # GROUND move
	gengar.current_hp = 25
	gengar.max_hp = 25
	
	battle.player_team = [ground_attacker]
	battle.enemy_team = [gengar]
	var predicted = battle.calculate_predicted_damage(ground_attacker, gengar, eq_move, 3, false)
	assert(predicted == 0, "Predicción de daño contra Levitate con ataque GROUND debe ser 0")
	battle.perform_attack(ground_attacker, gengar, eq_move, false, 3, dummy_v1, dummy_v2)
	assert(gengar.current_hp == 25, "Gengar no debió recibir ningún daño de Earthquake debido a Levitate")
	
	# Test Tormenta de arena no le hace daño a Levitate
	battle.sandstorm_turns = 3
	battle._finish_round()
	assert(gengar.current_hp == 25, "Gengar con Levitate no debió recibir daño pasivo de Sandstorm")
	battle.sandstorm_turns = 0
	print("✓ Test 4: Levitate otorgó inmunidad completa a Tierra y a Sandstorm.")

	# ----------------------------------------------------
	# 5. TEST SYNCHRONIZE (Sincronía) - Refleja estados negativos
	# ----------------------------------------------------
	var alakazam = GameData.create_pokemon_instance(68) # Alakazam (id: 68) con Synchronize
	assert(alakazam != null and alakazam.has_passive and alakazam.passive_name == "Synchronize", "Alakazam debe tener Synchronize")
	var status_user = GameData.create_pokemon_instance(4) # Ivysaur
	status_user.current_energy = 5
	var poison_move = get_test_move("Poison Powder") # Aplica Poison
	alakazam.current_hp = 25
	status_user.is_poisoned = false
	
	battle.player_team = [status_user]
	battle.enemy_team = [alakazam]
	battle.perform_attack(status_user, alakazam, poison_move, false, 2, dummy_v1, dummy_v2)
	assert(alakazam.is_poisoned, "Alakazam debió ser envenenado por el ataque")
	assert(status_user.is_poisoned, "El atacante debió recibir Veneno reflejado por Synchronize")
	print("✓ Test 5: Synchronize reflejó el Veneno exitosamente al atacante.")

	# ----------------------------------------------------
	# 6. TEST GUTS (Agallas) - +3 DMG con estado y sin penalización de veneno
	# ----------------------------------------------------
	var machamp = GameData.create_pokemon_instance(71) # Machamp (id: 71) con Guts
	assert(machamp != null and machamp.has_passive and machamp.passive_name == "Guts", "Machamp debe tener Guts")
	var test_target = GameData.create_pokemon_instance(19) # Rattata
	test_target.current_hp = 40
	test_target.max_hp = 40
	machamp.current_energy = 5
	machamp.is_poisoned = true # Bajo veneno
	var punch_move = get_test_move("Vital Throw") # 9 DMG base (sin RNG de crítico)
	
	battle.player_team = [machamp]
	battle.enemy_team = [test_target]
	var predicted_guts = battle.calculate_predicted_damage(machamp, test_target, punch_move, 2, false)
	# 9 base + 3 guts + 2 debilidad tipo lucha contra normal = 14 DMG (sin el -1 de veneno)
	assert(predicted_guts == 14, "Daño previsto con Guts bajo veneno debe ser 14 (9 base + 3 bono + 2 debilidad, sin -1 penalización). Fue: %d" % predicted_guts)
	battle.perform_attack(machamp, test_target, punch_move, false, 2, dummy_v1, dummy_v2)
	assert(test_target.current_hp == 26, "Rattata debió recibir 14 DMG (40 - 14 = 26). HP actual: %d" % test_target.current_hp)
	print("✓ Test 6: Guts otorgó +3 DMG y anuló la penalización de veneno.")

	# ----------------------------------------------------
	# 7. TEST INNER FOCUS (Foco Interno) - Inmunidad a Flinch
	# ----------------------------------------------------
	var lucario = GameData.create_pokemon_instance(452) # Lucario (id: 452) con Inner Focus
	assert(lucario != null and lucario.has_passive and lucario.passive_name == "Inner Focus", "Lucario debe tener Inner Focus")
	var flinch_user = GameData.create_pokemon_instance(19) # Rattata
	flinch_user.current_energy = 5
	var bite_move = get_test_move("Bite") # FLINCH move
	lucario.is_flinched = false
	
	battle.player_team = [flinch_user]
	battle.enemy_team = [lucario]
	battle.perform_attack(flinch_user, lucario, bite_move, false, 2, dummy_v1, dummy_v2)
	assert(not lucario.is_flinched, "Lucario no debió sufrir Flinch gracias a Inner Focus")
	print("✓ Test 7: Inner Focus evitó el Flinch completamente.")

	# ----------------------------------------------------
	# 8. TEST NATURAL CURE (Cura Natural) - Cura estados al cambiar
	# ----------------------------------------------------
	var blissey = GameData.create_pokemon_instance(247) # Blissey (id: 247) con Natural Cure
	assert(blissey != null and blissey.has_passive and blissey.passive_name == "Natural Cure", "Blissey debe tener Natural Cure")
	blissey.burn_turns = 2
	blissey.is_poisoned = true
	blissey.is_paralyzed = true
	blissey.is_confused = true
	battle._cleanse_pokemon_status(blissey)
	assert(blissey.burn_turns == 0 and not blissey.is_poisoned and not blissey.is_paralyzed and not blissey.is_confused, "Natural Cure debió limpiar todos los estados alterados")
	print("✓ Test 8: Natural Cure limpió todos los estados alterados al cambiar.")

	# ----------------------------------------------------
	# 9. TEST CLOROFILA / SWIFT SWIM (Weather Rush) - +2 Speed en Clima
	# ----------------------------------------------------
	var ludicolo = GameData.create_pokemon_instance(277) # Ludicolo (id: 277) con Swift Swim
	assert(ludicolo != null and ludicolo.has_passive and ludicolo.passive_name in ["Swift Swim", "Chlorophyll"], "Ludicolo debe tener Swift Swim")
	var base_spd = ludicolo.get_effective_speed()
	battle.grassy_terrain_turns = 2
	var boosted_spd = battle.get_pokemon_effective_speed(ludicolo, target_dummy)
	assert(boosted_spd == base_spd + 3, "La velocidad con Swift Swim/Clorofila en clima debe ser base + 3")
	battle.grassy_terrain_turns = 0
	print("✓ Test 9: Swift Swim / Chlorophyll otorgó +3 Speed durante clima.")
