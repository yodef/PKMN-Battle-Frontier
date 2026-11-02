extends Node

func _ready() -> void:
	print("\n=== TEST DE REGLAS DE TORNEO, RIVALES, RECOMPENSAS Y REVIVE ===")
	
	# -------------------------------------------------------------
	# TEST 1: EQUIPOS RIVALES DEL TORNEO
	# Match 1: 1 Basic
	# Match 2: 2 Basic
	# Match 3: 1 Basic + 1 Stage 1
	# -------------------------------------------------------------
	print("\n--- TEST 1: Equipos Rivales del Torneo ---")
	
	var r1 = GameData.get_campaign_rival_team(1)
	assert(r1.size() == 1, "Combate 1 debe tener exactamente 1 Pokémon rival, tiene: %d" % r1.size())
	var p1 = GameData.pokemon_catalog[r1[0]]
	assert(str(p1.get("stage", "")).strip_edges().to_lower() == "basic", "Rival 1 debe ser fase Basic, es: %s" % p1.get("stage"))
	print("✓ Combate 1: 1 Pokémon Basic -> %s (#%s)" % [p1["name"], p1["pokedex_num"]])
	
	var r2 = GameData.get_campaign_rival_team(2)
	assert(r2.size() == 2, "Combate 2 debe tener exactamente 2 Pokémon rivales, tiene: %d" % r2.size())
	for rid in r2:
		var p = GameData.pokemon_catalog[rid]
		assert(str(p.get("stage", "")).strip_edges().to_lower() == "basic", "Rival en Combate 2 debe ser Basic, %s es %s" % [p["name"], p.get("stage")])
	print("✓ Combate 2: 2 Pokémon Basic -> %s y %s" % [GameData.pokemon_catalog[r2[0]]["name"], GameData.pokemon_catalog[r2[1]]["name"]])
	
	var r3 = GameData.get_campaign_rival_team(3)
	assert(r3.size() == 2, "Combate 3 debe tener exactamente 2 Pokémon rivales, tiene: %d" % r3.size())
	var has_basic = false
	var has_stage1 = false
	for rid in r3:
		var p = GameData.pokemon_catalog[rid]
		var st = str(p.get("stage", "")).strip_edges().to_lower()
		if st == "basic":
			has_basic = true
		elif st == "stage 1":
			has_stage1 = true
	assert(has_basic, "Combate 3 debe incluir 1 Pokémon Basic")
	assert(has_stage1, "Combate 3 debe incluir 1 Pokémon Stage 1")
	print("✓ Combate 3: 1 Basic y 1 Stage 1 -> %s (%s) y %s (%s)" % [
		GameData.pokemon_catalog[r3[0]]["name"], GameData.pokemon_catalog[r3[0]]["stage"],
		GameData.pokemon_catalog[r3[1]]["name"], GameData.pokemon_catalog[r3[1]]["stage"]
	])
	
	# -------------------------------------------------------------
	# TEST 2: RESTRICCIÓN DE EQUIPO INICIAL DEL JUGADOR (SOLO BASIC)
	# -------------------------------------------------------------
	print("\n--- TEST 2: Restricción de selección de equipo para el Torneo (Solo Basic) ---")
	
	# Intentar inicializar con una mezcla: Bulbasaur (0, Basic), Ivysaur (4, Stage 1), Venusaur (5, Stage 2)
	GameData.init_campaign_team([0, 4, 5])
	assert(GameData.campaign_player_team_state.size() == 1, "Solo debió aceptar el Pokémon Basic (Bulbasaur), aceptó: %d" % GameData.campaign_player_team_state.size())
	assert(GameData.campaign_player_team_state[0]["id"] == 0, "El Pokémon admitido debe ser Bulbasaur")
	print("✓ init_campaign_team rechazó correctamente a Ivysaur (Stage 1) y Venusaur (Stage 2)")
	
	# Inicializar correctamente con 3 Basic: Bulbasaur (0), Charmander (1), Squirtle (2)
	GameData.init_campaign_team([0, 1, 2])
	assert(GameData.campaign_player_team_state.size() == 3, "Debe aceptar 3 Pokémon Basic")
	print("✓ init_campaign_team aceptó equipo completo de 3 Pokémon Basic")
	
	# -------------------------------------------------------------
	# TEST 3: TIENDA, PRECIOS (POCIÓN 3 G, REVIVE 6 G) Y RECOMPENSAS
	# -------------------------------------------------------------
	print("\n--- TEST 3: Precios de Tienda y Economía del Torneo ---")
	
	GameData.campaign_gold = 10
	assert(GameData.campaign_inventory["potion"] == 0, "Pociones iniciales 0")
	assert(GameData.campaign_inventory["revive"] == 0, "Revives iniciales 0")
	
	# Comprar Poción por 3 G (debe quedar en 7 G)
	var bought_pot = GameData.buy_campaign_potion()
	assert(bought_pot == true, "Debe poder comprar poción con 10 G")
	assert(GameData.campaign_gold == 7, "Oro restante debe ser 7 G (10 - 3), actual: %d" % GameData.campaign_gold)
	assert(GameData.campaign_inventory["potion"] == 1, "Inventario de pociones debe ser 1")
	print("✓ Poción comprada por 3 G exitosamente (Oro restante: 7 G)")
	
	# Comprar Revive por 6 G (debe quedar en 1 G)
	var bought_rev = GameData.buy_campaign_revive()
	assert(bought_rev == true, "Debe poder comprar revive con 7 G")
	assert(GameData.campaign_gold == 1, "Oro restante debe ser 1 G (7 - 6), actual: %d" % GameData.campaign_gold)
	assert(GameData.campaign_inventory["revive"] == 1, "Inventario de revives debe ser 1")
	print("✓ Revive comprado por 6 G exitosamente (Oro restante: 1 G)")
	
	# Intentar comprar otro Revive o Poción sin suficiente oro (tiene 1 G)
	assert(GameData.buy_campaign_potion() == false, "No debe permitir comprar poción sin al menos 3 G")
	assert(GameData.buy_campaign_revive() == false, "No debe permitir comprar revive sin al menos 6 G")
	print("✓ Control de fondos en tienda verificado correctamente")
	
	# -------------------------------------------------------------
	# TEST 4: USO DE REVIVE Y POCIÓN
	# -------------------------------------------------------------
	print("\n--- TEST 4: Lógica de uso de Revive y Poción en campaña ---")
	
	# Bulbasaur: HP máximo 10
	var bulba = GameData.campaign_player_team_state[0]
	bulba["current_hp"] = 0 # En estado KO
	
	# Intentar curar con Poción a Bulbasaur KO -> debe fallar
	var pot_on_ko = GameData.use_potion_on_campaign_pkmn(0)
	assert(pot_on_ko == false, "Poción NO debe curar a un Pokémon en estado KO")
	assert(bulba["current_hp"] == 0, "Bulbasaur debe permanecer en KO")
	assert(GameData.campaign_inventory["potion"] == 1, "La poción no debió ser consumida")
	print("✓ Poción rechaza curar a Pokémon en KO")
	
	# Usar Revive en Bulbasaur KO -> debe revivirlo con 50% HP (5 de 10)
	var rev_success = GameData.use_revive_on_campaign_pkmn(0)
	assert(rev_success == true, "Revive debe funcionar sobre Pokémon en KO")
	assert(bulba["current_hp"] == 5, "Bulbasaur debió revivir con 50%% HP (5/10), actual: %d" % bulba["current_hp"])
	assert(GameData.campaign_inventory["revive"] == 0, "El Revive debe haberse consumido (quedan 0)")
	print("✓ Revive revivió a Bulbasaur exitosamente al 50%% de HP (%d/%d)" % [bulba["current_hp"], bulba["max_hp"]])
	
	# Intentar usar Revive en Pokémon vivo -> debe fallar
	GameData.campaign_inventory["revive"] = 1
	var rev_on_alive = GameData.use_revive_on_campaign_pkmn(0)
	assert(rev_on_alive == false, "Revive NO debe poder usarse en Pokémon que no esté en KO")
	assert(GameData.campaign_inventory["revive"] == 1, "Revive no debió consumirse")
	print("✓ Revive rechaza aplicarse a Pokémon vivos")
	
	# Usar Poción en Bulbasaur vivo herido (5 HP -> 10 HP máx)
	var pot_on_alive = GameData.use_potion_on_campaign_pkmn(0)
	assert(pot_on_alive == true, "Poción debe curar a Pokémon vivo herido")
	assert(bulba["current_hp"] == 10, "Bulbasaur debe tener 10/10 HP tras la poción, actual: %d" % bulba["current_hp"])
	assert(GameData.campaign_inventory["potion"] == 0, "Poción debe haberse consumido (quedan 0)")
	print("✓ Poción curó a Bulbasaur vivo hasta HP máximo (10/10)")
	
	# -------------------------------------------------------------
	# TEST 5: RECOMPENSAS DE COMBATE EN BATTLE SCENE
	# -------------------------------------------------------------
	print("\n--- TEST 5: Recompensas de Combate del Torneo en battle.gd ---")
	
	var battle_packed = load("res://scenes/battle.tscn")
	var battle = battle_packed.instantiate()
	add_child(battle)
	
	GameData.is_campaign_mode = true
	GameData.campaign_match_number = 1
	GameData.campaign_gold = 0
	GameData.init_campaign_team([0, 1, 2])
	battle.start_new_game()
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Simular victoria en Combate 1: rival es derrotado
	for e in battle.enemy_team:
		e.current_hp = 0
		
	var ended = battle.check_team_defeat()
	assert(ended == true, "El combate debe finalizar al morir todos los rivales")
	assert(GameData.campaign_gold == 4, "Combate 1 debe otorgar 4 G, actual: %d G" % GameData.campaign_gold)
	assert(GameData.campaign_match_number == 2, "Debe avanzar al Combate 2")
	print("✓ Victoria en Combate 1 otorgó exactamente +4 G (Total: %d G)" % GameData.campaign_gold)
	
	# Simular victoria en Combate 2:
	battle.start_new_game()
	await get_tree().process_frame
	for e in battle.enemy_team:
		e.current_hp = 0
	ended = battle.check_team_defeat()
	assert(ended == true, "El combate 2 debe finalizar")
	assert(GameData.campaign_gold == 11, "Combate 2 debe otorgar +7 G (4 + 7 = 11 G), actual: %d G" % GameData.campaign_gold)
	assert(GameData.campaign_match_number == 3, "Debe avanzar al Combate 3")
	print("✓ Victoria en Combate 2 otorgó exactamente +7 G (Total: %d G)" % GameData.campaign_gold)
	
	# Simular victoria en Combate 3 (Cierre):
	battle.start_new_game()
	await get_tree().process_frame
	for e in battle.enemy_team:
		e.current_hp = 0
	ended = battle.check_team_defeat()
	assert(ended == true, "El combate 3 debe finalizar")
	assert(GameData.campaign_gold == 11, "Combate 3 debe otorgar +0 G (Total permanece en 11 G), actual: %d G" % GameData.campaign_gold)
	assert(GameData.campaign_match_number == 4, "Torneo debe marcarse como completado (match 4)")
	print("✓ Victoria en Combate 3 otorgó +0 G (Cierre de Torneo, total acumulado: %d G)" % GameData.campaign_gold)
	
	# -------------------------------------------------------------
	# TEST 6: HISTORIAL DE CHAT DE COMBATE
	# -------------------------------------------------------------
	print("\n--- TEST 6: Historial de combate y ritmo pausado ---")
	battle.combat_history.clear()
	battle.log_action("Línea 1: Ataque inicial")
	assert(battle.combat_history.size() == 1, "Debe contener 1 línea")
	assert("Línea 1" in battle.log_label.text, "Texto debe contener Línea 1")
	
	battle.log_action("Línea 2: Contraataque del rival")
	assert(battle.combat_history.size() == 2, "Debe contener 2 líneas en historial")
	assert("Línea 1" in battle.log_label.text, "Texto debe mantener visible Línea 1 como contexto previo")
	assert("Línea 2" in battle.log_label.text, "Texto debe mostrar Línea 2 como acción actual")
	print("✓ Historial de combate multilínea funcionando correctamente")
	
	print("\n=======================================================")
	print("TODAS LAS VERIFICACIONES PASARON CON ÉXITO (EXIT CODE 0)")
	print("=======================================================")
	get_tree().quit(0)
