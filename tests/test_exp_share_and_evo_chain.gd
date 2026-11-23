extends Node

func _ready() -> void:
	print("\n=== INICIANDO TESTS: EXP SHARE REBALANCE & CADENA EVOLUTIVA POKÉDEX ===")
	
	GameData.load_types_from_csv()
	GameData.load_moves_from_csv()
	GameData.load_pokemon_from_csv()
	
	var find_poke = func(poke_name: String) -> Dictionary:
		for k in GameData.pokemon_catalog:
			var entry = GameData.pokemon_catalog[k]
			if entry.get("name", "").to_lower() == poke_name.to_lower():
				return entry
		return {}

	# -------------------------------------------------------------
	# TEST 1: EXP SHARE CUANDO EL PKMN ACTIVO YA ESTÁ AL MÁXIMO DE EXP
	# -------------------------------------------------------------
	print("\n--- TEST 1: Exp Share cuando el activo está a MAX EXP (50/50) ---")
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
	
	var active_bulba = GameData.create_pokemon_instance(find_poke.call("Bulbasaur")["id"])
	active_bulba.current_exp = 50 # Ya al máximo (50/50)
	assert(active_bulba.get_required_exp() == 50)
	
	var bench_pika = GameData.create_pokemon_instance(find_poke.call("Pichu")["id"])
	bench_pika.held_item = "exp_share"
	bench_pika.current_exp = 0
	assert(bench_pika.get_required_exp() == 50)
	
	var bench_charm = GameData.create_pokemon_instance(find_poke.call("Charmander")["id"])
	bench_charm.held_item = "" # No lleva exp share
	bench_charm.current_exp = 0
	
	var enemy = GameData.create_pokemon_instance(find_poke.call("Rattata")["id"])
	enemy.max_hp = 300
	enemy.current_hp = 300
	enemy.defense = 40
	
	battle_scene.player_team = [active_bulba, bench_pika, bench_charm]
	battle_scene.enemy_team = [enemy]
	battle_scene.active_player_idx = 0
	battle_scene.active_enemy_idx = 0
	
	var test_strike = GameData.MoveData.new("Power Strike", "NORMAL", 20, 1, 1, false, 0, 0, false, "Deals 20 damage.")
	test_strike.accuracy = 100
	active_bulba.attack = 40
	active_bulba.current_energy = 5
	
	# Ataque 1: Inflige 20 daño efectivo
	battle_scene.perform_attack(active_bulba, enemy, test_strike, false, 1, dummy_v1, dummy_v2)
	assert(active_bulba.current_exp == 50, "El activo ya estaba al maximo, debe seguir en 50")
	# Exp share recibe el 30% del daño efectivo (20 * 0.30 = 6)
	assert(bench_pika.current_exp == 6, "El benched con Exp Share debe recibir 6 EXP (30%% de 20). Actual: %d" % bench_pika.current_exp)
	assert(bench_charm.current_exp == 0, "El benched sin Exp Share debe permanecer en 0 EXP")
	print("✓ 1.1 El activo con MAX EXP no recibe más, y el Pokémon en banca con Exp Share recibe exactamente el 30% (6 EXP)")

	# -------------------------------------------------------------
	# TEST 2: EXP SHARE CUANDO EL PKMN ACTIVO NO REQUIERE EXP (STAGE 2 / FASE FINAL)
	# -------------------------------------------------------------
	print("\n--- TEST 2: Exp Share con PKMN activo que no requiere EXP (Venusaur / Stage 2) ---")
	var active_venu = GameData.create_pokemon_instance(find_poke.call("Venusaur")["id"])
	assert(active_venu.get_required_exp() == 0, "Venusaur no requiere EXP")
	active_venu.attack = 40
	active_venu.current_energy = 5
	
	battle_scene.player_team = [active_venu, bench_pika, bench_charm]
	battle_scene.active_player_idx = 0
	
	var strike30 = GameData.MoveData.new("Mega Strike", "NORMAL", 30, 1, 1, false, 0, 0, false, "Deals 30 damage.")
	strike30.accuracy = 100
	
	# Ataque 2: Inflige 30 daño efectivo
	battle_scene.perform_attack(active_venu, enemy, strike30, false, 1, dummy_v1, dummy_v2)
	assert(active_venu.current_exp == 0, "Venusaur no debe acumular EXP")
	# Bench pika estaba en 6, 30 * 0.30 = 9 -> 6 + 9 = 15
	assert(bench_pika.current_exp == 15, "Pichu debe tener 15 EXP (6 + 9). Actual: %d" % bench_pika.current_exp)
	assert(bench_charm.current_exp == 0, "Charmander sin Exp Share sigue en 0 EXP")
	print("✓ 2.1 El activo en Stage 2 no requiere EXP, pero Exp Share en banca otorga 30% del daño (9 EXP -> 15 total)")

	# -------------------------------------------------------------
	# TEST 3: RESOLUCIÓN DE CADENAS EVOLUTIVAS (ESTRUCTURA DE DATOS)
	# -------------------------------------------------------------
	print("\n--- TEST 3: Resolución de Cadenas Evolutivas ---")
	var b_id = find_poke.call("Bulbasaur")["id"]
	var i_id = find_poke.call("Ivysaur")["id"]
	var v_id = find_poke.call("Venusaur")["id"]
	
	# 3.1 Detección del Pokémon raíz
	assert(GameData.get_root_pokemon_id(b_id) == b_id, "Root de Bulbasaur debe ser Bulbasaur")
	assert(GameData.get_root_pokemon_id(i_id) == b_id, "Root de Ivysaur debe ser Bulbasaur")
	assert(GameData.get_root_pokemon_id(v_id) == b_id, "Root de Venusaur debe ser Bulbasaur")
	print("✓ 3.1 Root de cualquier fase en línea Bulbasaur->Ivysaur->Venusaur se resuelve a Bulbasaur")

	# 3.2 Cadena completa para Bulbasaur
	var bulba_chain = GameData.get_full_evolution_chain(b_id)
	assert(bulba_chain.has_line == true, "Bulbasaur tiene linea evolutiva")
	assert(bulba_chain.root.name == "Bulbasaur")
	assert(bulba_chain.root.children.size() == 1)
	assert(bulba_chain.root.children[0].name == "Ivysaur")
	assert(bulba_chain.root.children[0].req_exp == 50)
	assert(bulba_chain.root.children[0].children.size() == 1)
	assert(bulba_chain.root.children[0].children[0].name == "Venusaur")
	assert(bulba_chain.root.children[0].children[0].req_exp == 120)
	print("✓ 3.2 Árbol de Bulbasaur contiene a Ivysaur (50 EXP) y Venusaur (120 EXP)")

	# 3.3 Cadena ramificada de Eevee (7 evoluciones)
	var eevee_id = find_poke.call("Eevee")["id"]
	var eevee_chain = GameData.get_full_evolution_chain(eevee_id)
	assert(eevee_chain.has_line == true)
	assert(eevee_chain.root.children.size() >= 7, "Eevee debe tener al menos 7 evoluciones registradas")
	var eevee_child_names = []
	for c in eevee_chain.root.children:
		eevee_child_names.append(c.name)
	assert("Vaporeon" in eevee_child_names)
	assert("Jolteon" in eevee_child_names)
	assert("Flareon" in eevee_child_names)
	print("✓ 3.3 Eevee resuelve correctamente sus múltiples ramificaciones: %s" % str(eevee_child_names))

	# 3.4 Cadena ramificada de Gloom (Vileplume y Bellossom)
	var gloom_id = find_poke.call("Gloom")["id"]
	var gloom_chain = GameData.get_full_evolution_chain(gloom_id)
	assert(gloom_chain.root.name == "Oddish", "Root de Gloom debe ser Oddish")
	assert(gloom_chain.root.children.size() == 1) # Gloom
	var gloom_child = gloom_chain.root.children[0]
	assert(gloom_child.name == "Gloom")
	assert(gloom_child.children.size() == 2, "Gloom debe ramificar a Vileplume y Bellossom")
	var gloom_evo_names = [gloom_child.children[0].name, gloom_child.children[1].name]
	assert("Vileplume" in gloom_evo_names and "Bellossom" in gloom_evo_names)
	print("✓ 3.4 Gloom ramifica correctamente a Vileplume y Bellossom con raíz Oddish")

	# 3.5 Pokémon sin evolución (Lapras / Tauros / Snorlax si standalone)
	var lapras_id = find_poke.call("Lapras")["id"]
	var lapras_chain = GameData.get_full_evolution_chain(lapras_id)
	assert(lapras_chain.has_line == false, "Lapras no debe tener linea evolutiva")
	print("✓ 3.5 Lapras correctamente identificado como Single Stage (has_line = false)")

	# -------------------------------------------------------------
	# TEST 4: CONSTRUCCIÓN DEL COMPONENTE VISUAL (UI BUILDER)
	# -------------------------------------------------------------
	print("\n--- TEST 4: Verificación del Componente Visual (build_evolution_chain_view) ---")
	# Configurar desbloqueos: Desbloquear Bulbasaur pero NO Ivysaur ni Venusaur
	GameData.player_unlocked_ids.clear()
	GameData.player_unlocked_ids.append(b_id)
	assert(GameData.is_pokemon_unlocked(b_id) == true)
	assert(GameData.is_pokemon_unlocked(i_id) == false)
	assert(GameData.is_pokemon_unlocked(v_id) == false)
	
	var clicked_id: int = -1
	var on_click_cb = func(target_id: int):
		clicked_id = target_id
		
	var ui_panel = GameData.build_evolution_chain_view(b_id, on_click_cb)
	assert(ui_panel != null, "build_evolution_chain_view debe retornar un Control válido")
	assert(ui_panel is PanelContainer)
	add_child(ui_panel)
	await get_tree().process_frame
	
	# Verificar que el árbol visual contenga la mención de desbloqueada/no desbloqueada
	var found_owned = false
	var found_locked = false
	var stack = [ui_panel]
	while not stack.is_empty():
		var node = stack.pop_back()
		if node is Label:
			var txt = (node as Label).text
			if "OBTENIDA" in txt or "OWNED" in txt or "ACTUAL" in txt or "CURRENT" in txt:
				found_owned = true
			if "BLOQUEADA" in txt or "LOCKED" in txt or "No en Colección" in txt or "Not in Collection" in txt:
				found_locked = true
		for ch in node.get_children():
			stack.push_back(ch)
			
	assert(found_owned, "Debe mostrarse badge de Owned/Current para Bulbasaur")
	assert(found_locked, "Debe mostrarse mención explícita de No en Colección/Locked para fases no desbloqueadas")
	print("✓ 4.1 La UI muestra badges de colección y estado bloqueado/no desbloqueado con claridad")

	# Test para Pokémon sin evolución (Lapras)
	var lapras_ui = GameData.build_evolution_chain_view(lapras_id)
	assert(lapras_ui != null)
	add_child(lapras_ui)
	var found_no_evo_text = false
	stack = [lapras_ui]
	while not stack.is_empty():
		var node = stack.pop_back()
		if node is Label:
			var txt = (node as Label).text
			if "No tiene evoluciones" in txt or "Does not evolve" in txt:
				found_no_evo_text = true
		for ch in node.get_children():
			stack.push_back(ch)
	assert(found_no_evo_text, "Debe mostrar aviso de Pokémon de fase única sin evoluciones")
	print("✓ 4.2 Pokémon sin evolución muestran aviso elegante de Single Stage")

	print("\n==================================================================")
	print(" TODOS LOS TESTS DE EXP SHARE Y CADENA EVOLUTIVA PASARON AL 100% ")
	print("==================================================================")
	get_tree().quit(0)
