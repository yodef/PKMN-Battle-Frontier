extends Node

func _ready() -> void:
	print("\n=== INICIANDO TEST: BALANCE DE EXPERIENCIA REQUERIDA PARA EVOLUCIONAR ===")
	
	GameData.load_types_from_csv()
	GameData.load_moves_from_csv()
	GameData.load_pokemon_from_csv()
	
	var find_poke = func(poke_name: String) -> Dictionary:
		for k in GameData.pokemon_catalog:
			var entry = GameData.pokemon_catalog[k]
			if entry.get("name", "").to_lower() == poke_name.to_lower():
				return entry
		return {}

	# --- TEST 1: Verificación de EXP en Pokémon Básicos de Línea de 3 Fases (50 EXP) ---
	print("\n--- TEST 1: Verificación Básicos (3 fases -> 50 EXP) ---")
	var starters = ["Bulbasaur", "Charmander", "Squirtle", "Chikorita", "Cyndaquil", "Totodile", "Treecko", "Torchic", "Mudkip", "Turtwig", "Chimchar", "Piplup", "Pichu", "Ralts", "Ghastly", "Dratini"]
	for s_name in starters:
		var p_data = find_poke.call(s_name)
		assert(not p_data.is_empty(), "%s debe existir" % s_name)
		var exp_req = GameData.get_pokemon_required_exp(p_data["id"])
		assert(exp_req == 50, "%s debe requerir exactamente 50 EXP. Actual: %d" % [s_name, exp_req])
	print("✓ 1.1 Todos los Básicos de 3 fases verificados: 50 EXP requerida")

	# --- TEST 2: Verificación de EXP en Pokémon Básicos de Línea de 2 Fases (80 EXP) ---
	print("\n--- TEST 2: Verificación Básicos de 2 fases (Forma Final -> 80 EXP) ---")
	var two_stage_basics = ["Rattata", "Spearow", "Ekans", "Sandshrew", "Vulpix", "Growlithe", "Meowth", "Psyduck", "Ponyta", "Eevee", "Magikarp", "Sneasel", "Houndour", "Phanpy", "Buizel"]
	for b_name in two_stage_basics:
		var p_data = find_poke.call(b_name)
		assert(not p_data.is_empty(), "%s debe existir" % b_name)
		var exp_req = GameData.get_pokemon_required_exp(p_data["id"])
		assert(exp_req == 80, "%s debe requerir exactamente 80 EXP. Actual: %d" % [b_name, exp_req])
	print("✓ 2.1 Todos los Básicos de 2 fases verificados: 80 EXP requerida")

	# --- TEST 3: Verificación de EXP en Stage 1 que Evoluciona a Stage 2 (120 EXP) ---
	print("\n--- TEST 3: Verificación Stage 1 intermedia (Hacia Stage 2 -> 120 EXP) ---")
	var stage1_evos = ["Ivysaur", "Charmeleon", "Wartortle", "Pidgeotto", "Kirlia", "Haunter", "Dragonair", "Bayleef", "Quilava", "Croconaw", "Grovyle", "Combusken", "Marshtomp", "Grotle", "Monferno", "Prinplup", "Pikachu", "Chansey"]
	for s1_name in stage1_evos:
		var p_data = find_poke.call(s1_name)
		assert(not p_data.is_empty(), "%s debe existir" % s1_name)
		var exp_req = GameData.get_pokemon_required_exp(p_data["id"])
		assert(exp_req == 120, "%s debe requerir exactamente 120 EXP. Actual: %d" % [s1_name, exp_req])
	print("✓ 3.1 Todos los Stage 1 intermedios verificados: 120 EXP requerida")

	# --- TEST 4: Verificación de Fases Finales (0 EXP, no evolucionan) ---
	print("\n--- TEST 4: Verificación Fases Finales (0 EXP) ---")
	var final_stages = ["Venusaur", "Charizard", "Blastoise", "Raticate", "Ninetales", "Arcanine", "Gengar", "Dragonite", "Mewtwo", "Zapdos"]
	for f_name in final_stages:
		var p_data = find_poke.call(f_name)
		assert(not p_data.is_empty(), "%s debe existir" % f_name)
		var exp_req = GameData.get_pokemon_required_exp(p_data["id"])
		assert(exp_req == 0, "%s debe requerir 0 EXP. Actual: %d" % [f_name, exp_req])
	print("✓ 4.1 Fases finales y legendarios verificados: 0 EXP requerida")

	# --- TEST 5: Simulación de Combate y Progreso de EXP en Múltiples Turnos ---
	print("\n--- TEST 5: Simulación de Combate y Acumulación Gradual de EXP ---")
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
	
	GameData.is_campaign_mode = true
	var bulba = GameData.create_pokemon_instance(find_poke.call("Bulbasaur")["id"])
	assert(bulba.get_required_exp() == 50, "Instancia de Bulbasaur debe requerir 50 EXP")
	assert(bulba.max_exp == 50, "max_exp de Bulbasaur debe ser 50")
	bulba.current_exp = 0
	
	var foe = GameData.create_pokemon_instance(find_poke.call("Rattata")["id"])
	foe.max_hp = 200
	foe.current_hp = 200
	foe.defense = 40
	
	battle_scene.player_team = [bulba]
	battle_scene.enemy_team = [foe]
	battle_scene.active_player_idx = 0
	battle_scene.active_enemy_idx = 0
	
	# Ataques de prueba deterministas con 100% precisión
	var strike_move = GameData.MoveData.new("Training Strike", "NORMAL", 20, 1, 1, false, 0, 0, false, "Deals 20 damage.")
	strike_move.accuracy = 100
	bulba.attack = 40
	bulba.current_energy = 5
	
	# Ataque 1: 20 DMG -> 20/50 EXP (no listo para evolucionar)
	var hp_before = foe.current_hp
	battle_scene.perform_attack(bulba, foe, strike_move, false, 1, dummy_v1, dummy_v2)
	var dealt1 = hp_before - foe.current_hp
	assert(dealt1 == 20, "Debe infligir 20 DMG")
	assert(bulba.current_exp == 20, "Ataque 1 (20 DMG) debe dejar EXP en 20. Actual: %d" % bulba.current_exp)
	assert(not bulba.can_evolve_exp(), "No debe poder evolucionar tras un solo ataque de 20 DMG (20/50)")
	print("✓ 5.1 Ataque 1: 20 DMG infligidos -> 20/50 EXP acumulada (progreso balanceado)")
	
	# Ataque 2: 20 DMG -> 40/50 EXP
	bulba.current_energy = 5
	hp_before = foe.current_hp
	battle_scene.perform_attack(bulba, foe, strike_move, false, 1, dummy_v1, dummy_v2)
	var dealt2 = hp_before - foe.current_hp
	assert(dealt2 == 20, "Debe infligir 20 DMG")
	assert(bulba.current_exp == 40, "Ataque 2 debe acumular 40 EXP. Actual: %d" % bulba.current_exp)
	assert(not bulba.can_evolve_exp(), "No debe poder evolucionar todavía (40/50)")
	print("✓ 5.2 Ataque 2: 20 DMG infligidos -> 40/50 EXP acumulada")
	
	# Ataque 3: 20 DMG -> El daño es 20, pero la EXP debe topar en exactamente 50/50
	bulba.current_energy = 5
	hp_before = foe.current_hp
	battle_scene.perform_attack(bulba, foe, strike_move, false, 1, dummy_v1, dummy_v2)
	var dealt3 = hp_before - foe.current_hp
	assert(dealt3 == 20, "Debe infligir 20 DMG")
	assert(bulba.current_exp == 50, "Ataque 3 debe topar la EXP en exactamente 50/50. Actual: %d" % bulba.current_exp)
	assert(bulba.can_evolve_exp(), "Ahora SÍ debe estar listo para evolucionar (50/50 EXP)")
	print("✓ 5.3 Ataque 3: 20 DMG infligidos -> Capped en 50/50 EXP exactos ⭐ LISTO PARA EVOLUCIONAR")

	# --- TEST 6: Evolución a Stage 1 y Salto a 120 EXP de Meta ---
	print("\n--- TEST 6: Evolución a Stage 1 y Actualización de Meta a 120 EXP ---")
	GameData.campaign_player_team_state = [{
		"id": bulba.id,
		"name": "Bulbasaur",
		"current_hp": bulba.current_hp,
		"max_hp": bulba.max_hp,
		"speed": bulba.speed,
		"texture_path": bulba.texture_path,
		"current_exp": 50,
		"max_exp": 50,
		"burn_turns": 0,
		"is_poisoned": false,
		"is_flinched": false
	}]
	var ivysaur_id = find_poke.call("Ivysaur")["id"]
	GameData.unlock_pokemon(ivysaur_id)
	GameData.add_campaign_stone("Leaf", 1)
	var evo_res = GameData.evolve_campaign_pokemon_with_option(0, ivysaur_id)
	print("Evo result: ", evo_res)
	assert(bool(evo_res.get("success", false)), "Evolución a Ivysaur debe ser exitosa")
	var evolved_state = GameData.campaign_player_team_state[0]
	assert(evolved_state["name"] == "Ivysaur", "Nombre debe ser Ivysaur")
	assert(evolved_state["current_exp"] == 0, "Nueva etapa debe reiniciar su EXP a 0. Actual: %d" % evolved_state["current_exp"])
	assert(evolved_state["max_exp"] == 120, "Nueva etapa (Stage 1) debe tener meta de 120 EXP. Actual: %d" % evolved_state["max_exp"])
	print("✓ 6.1 Evolución completada: Ivysaur arranca en 0/120 EXP para aspirar a Venusaur")

	print("\n=======================================================")
	print(" TODOS LOS TESTS DE REBALANCEO DE EXP PASARON CON ÉXITO ")
	print("=======================================================\n")
	get_tree().quit(0)
