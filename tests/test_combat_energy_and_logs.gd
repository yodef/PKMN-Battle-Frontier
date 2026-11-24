extends Node

func _ready() -> void:
	print("\n=======================================================")
	print("🧪 TEST: RECARGA DE ENERGÍA DE ACTIVOS/BANCA & COMBAT LOGS")
	print("=======================================================\n")
	
	await get_tree().process_frame
	await get_tree().process_frame

	var battle_scene = preload("res://scenes/battle.tscn").instantiate()
	add_child(battle_scene)
	
	await get_tree().process_frame
	await get_tree().process_frame

	# -------------------------------------------------------------
	# TEST 1: RECARGA PASIVA DE ENERGÍA (SOLO BANCA, ACTIVOS NO)
	# -------------------------------------------------------------
	print("--- TEST 1: Eliminación de recarga pasiva para Pokémon activos ---")
	var p_act = battle_scene.get_active_player()
	var e_act = battle_scene.get_active_enemy()
	assert(p_act != null, "Debe haber Pokémon activo del jugador")
	assert(e_act != null, "Debe haber Pokémon activo del rival")
	
	p_act.current_hp = 50
	p_act.max_energy = 5
	p_act.current_energy = 1
	
	e_act.current_hp = 50
	e_act.max_energy = 5
	e_act.current_energy = 2
	
	# Añadir Pokémon a la banca del jugador y del rival
	var p_bench = GameData.create_pokemon_instance(0) # Bulbasaur
	p_bench.current_hp = 30
	p_bench.max_energy = 5
	p_bench.current_energy = 1
	battle_scene.player_team.append(p_bench)
	
	var e_bench = GameData.create_pokemon_instance(3) # Charmander
	e_bench.current_hp = 30
	e_bench.max_energy = 5
	e_bench.current_energy = 2
	battle_scene.enemy_team.append(e_bench)
	
	# Ejecutar _finish_round de battle.gd
	battle_scene.round_step = 1 # para que ejecute _finish_round
	battle_scene._finish_round()
	
	assert(p_act.current_energy == 1, "El Pokémon activo del jugador NO debe recibir recarga pasiva. Actual: %d" % p_act.current_energy)
	assert(e_act.current_energy == 2, "El Pokémon activo del rival NO debe recibir recarga pasiva. Actual: %d" % e_act.current_energy)
	assert(p_bench.current_energy == 2, "El Pokémon en banca del jugador SÍ debe recibir +1⚡ pasivo. Actual: %d" % p_bench.current_energy)
	assert(e_bench.current_energy == 3, "El Pokémon en banca del rival SÍ debe recibir +1⚡ pasivo. Actual: %d" % e_bench.current_energy)
	print("✓ 1.1 Pokémon activos se mantienen sin recarga pasiva; la banca recibe +1⚡")
	
	# Verificar que el log de recarga mencione "Bench Recharge" / "Recarga en Banca"
	var last_logs = battle_scene.combat_history
	var found_bench_recharge = false
	for log_entry in last_logs:
		if "Bench Recharge" in log_entry or "Recarga en Banca" in log_entry:
			found_bench_recharge = true
			print("  Combat log verificado: %s" % log_entry)
			break
	assert(found_bench_recharge, "El log debe registrar la recarga exclusiva de la banca")
	print("✓ 1.2 Combat log registra correctamente 'Bench Recharge'")

	# -------------------------------------------------------------
	# TEST 2: RECARGA ACTIVA VOLUNTARIA / DESCANSO
	# -------------------------------------------------------------
	print("\n--- TEST 2: Acción voluntaria de Recargar / Descansar ---")
	battle_scene.is_player_turn = true
	battle_scene.can_player_act = true
	battle_scene.is_busy = false
	var prev_en = p_act.current_energy
	battle_scene._on_recover_pressed()
	assert(p_act.current_energy > prev_en, "La acción de Recarga debe restaurar energía al activo")
	print("✓ 2.1 La acción manual de Recargar (+%d⚡) restaura energía al Pokémon activo (⚡%d/%d)" % [p_act.current_energy - prev_en, p_act.current_energy, p_act.max_energy])

	# -------------------------------------------------------------
	# TEST 3: LOCALIZACIÓN BILINGÜE DE COMBAT LOGS ACTUALIZADOS
	# -------------------------------------------------------------
	print("\n--- TEST 3: Traducción y Formato de Combat Logs (ES / EN) ---")
	var Localization = preload("res://scripts/localization.gd")
	
	# 3.1 Golpe Crítico (+50% DMG)
	var crit_single_en = "[color=yellow]Critical Hit! (+50% DMG: +8)[/color]"
	var crit_single_es = Localization.translate_en_to_es(crit_single_en)
	assert("¡Golpe Crítico!" in crit_single_es and "+50%" in crit_single_es, "Crítico individual debe traducirse con +50%%: %s" % crit_single_es)
	print("✓ 3.1 Crítico individual: %s -> %s" % [crit_single_en, crit_single_es])
	
	# 3.2 Golpe Crítico Multi-Hit
	var crit_multi_en = "[color=yellow](3 hits: 8+12!+8 = 28 DMG) [color=orange](1 Critical Hit! +50% DMG)[/color][/color]"
	var crit_multi_es = Localization.translate_en_to_es(crit_multi_en)
	assert("impactos:" in crit_multi_es and "¡Golpe Crítico!" in crit_multi_es, "Multi-hit crítico debe traducirse: %s" % crit_multi_es)
	print("✓ 3.2 Crítico multi-hit: %s -> %s" % [crit_multi_en, crit_multi_es])
	
	# 3.3 Drenado de Vida (30% heal)
	var drain_en = "[color=green]Drained health and recovered +9 HP! (30% heal)[/color]"
	var drain_es = Localization.translate_en_to_es(drain_en)
	assert("¡Drenó salud y recuperó" in drain_es and "30%" in drain_es, "Drenado de vida debe traducirse con 30%%: %s" % drain_es)
	print("✓ 3.3 Drenado 30%: " + drain_en + " -> " + drain_es)
	
	# 3.4 Daño de Retroceso (25% / 30% recoil)
	var recoil_en = "[color=red]Recoil: takes 12 DMG! (25% recoil)[/color]"
	var recoil_es = Localization.translate_en_to_es(recoil_en)
	assert("Retroceso:" in recoil_es and "25%" in recoil_es, "Retroceso debe traducirse: %s" % recoil_es)
	print("✓ 3.4 Retroceso 25%: " + recoil_en + " -> " + recoil_es)
	
	# 3.5 Salpicadura a la banca (-6 DMG)
	var splash_en = "[color=cyan]Surf splashed the bench (-6 DMG to Bulbasaur, Charmander)![/color]"
	var splash_es = Localization.translate_en_to_es(splash_en)
	assert("salpicó a la banca (-6 DMG a" in splash_es, "Salpicadura de banca (-6 DMG) debe traducirse: %s" % splash_es)
	print("✓ 3.5 Salpicadura banca -6 DMG: %s -> %s" % [splash_en, splash_es])
	
	# 3.6 Daño Verdadero Fijo
	var fixed_en = "[color=cyan]Fixed True Damage (bypasses defense & resistance)![/color]"
	var fixed_es = Localization.translate_en_to_es(fixed_en)
	assert("Daño Verdadero Fijo" in fixed_es, "Daño verdadero debe traducirse: %s" % fixed_es)
	print("✓ 3.6 Daño Verdadero: %s -> %s" % [fixed_en, fixed_es])
	
	# 3.7 Recarga en Banca vs Activo
	var bench_rec_en = "🔋 [color=#FFD54F]Bench Recharge (+1⚡):[/color] Bulbasaur (⚡2/5)"
	var bench_rec_es = Localization.translate_en_to_es(bench_rec_en)
	assert("Recarga en Banca (+1⚡):" in bench_rec_es, "Recarga en banca debe traducirse: %s" % bench_rec_es)
	print("✓ 3.7 Recarga en banca: %s -> %s" % [bench_rec_en, bench_rec_es])
	
	# 3.8 Estados alterados en combat log
	var sleep_en = "💤 [b]Charizard[/b] [color=lightblue]is fast asleep and cannot move! (1 rounds remaining)[/color]"
	var sleep_es = Localization.translate_en_to_es(sleep_en)
	assert("profundamente dormido" in sleep_es, "Sueño debe traducirse: %s" % sleep_es)
	
	var freeze_en = "❄️ [b]Blastoise[/b] [color=cyan]is frozen solid and cannot move![/color]"
	var freeze_es = Localization.translate_en_to_es(freeze_en)
	assert("congelado" in freeze_es, "Congelamiento debe traducirse: %s" % freeze_es)
	
	var para_en = "⚡ [b]Pikachu[/b] [color=yellow]is fully paralyzed! It cannot move![/color]"
	var para_es = Localization.translate_en_to_es(para_en)
	assert("paralizado" in para_es, "Parálisis debe traducirse: %s" % para_es)
	
	var conf_en = "🌀 [b]Psyduck[/b] [color=magenta]is confused! It hurt itself in its confusion for 2 DMG! (1/3)[/color]"
	var conf_es = Localization.translate_en_to_es(conf_en)
	assert("confuso" in conf_es, "Confusión debe traducirse: %s" % conf_es)
	print("✓ 3.8 Estados alterados (Sueño, Congelamiento, Parálisis, Confusión) traducidos correctamente")
	
	print("\n=======================================================")
	print("🎉 TODOS LOS TESTS DE ENERGÍA Y COMBAT LOGS PASARON CON ÉXITO 🎉")
	print("=======================================================\n")
	get_tree().quit()
