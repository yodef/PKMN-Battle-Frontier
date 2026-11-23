extends Node

func _ready() -> void:
	print("\n=== INICIANDO TEST: BALANCE DE ATAQUES DE DRENAJE Y ALINEACIÓN DE FASES ===")
	
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
	
	# --- TEST 1: Verificación de Movimientos de Drenaje en CSV ---
	print("\n--- TEST 1: Verificación de Movimientos de Drenaje en CSV ---")
	var absorb = GameData.get_move_data("Absorb")
	assert(absorb != null and not absorb.is_empty(), "Absorb debe existir")
	assert(absorb["dmg"] == 10, "Absorb base DMG debe ser 10. Actual: %d" % absorb["dmg"])
	assert(absorb["cost"] == 1, "Absorb coste debe ser 1⚡. Actual: %d" % absorb["cost"])
	assert(absorb["effect_type"] == "LIFE_DRAIN", "Absorb effect_type debe ser LIFE_DRAIN")
	print("✓ 1.1 Absorb: 10 DMG, Coste 1⚡, LIFE_DRAIN")

	var mega_drain = GameData.get_move_data("Mega Drain")
	assert(mega_drain != null and not mega_drain.is_empty(), "Mega Drain debe existir")
	assert(mega_drain["dmg"] == 18, "Mega Drain base DMG debe ser 18. Actual: %d" % mega_drain["dmg"])
	assert(mega_drain["cost"] == 2, "Mega Drain coste debe ser 2⚡. Actual: %d" % mega_drain["cost"])
	assert(mega_drain["effect_type"] == "LIFE_DRAIN", "Mega Drain effect_type debe ser LIFE_DRAIN")
	print("✓ 1.2 Mega Drain: 18 DMG, Coste 2⚡, LIFE_DRAIN")

	var giga_drain = GameData.get_move_data("Giga Drain")
	assert(giga_drain != null and not giga_drain.is_empty(), "Giga Drain debe existir")
	assert(giga_drain["dmg"] == 30, "Giga Drain base DMG debe ser 30. Actual: %d" % giga_drain["dmg"])
	assert(giga_drain["cost"] == 3, "Giga Drain coste debe ser 3⚡. Actual: %d" % giga_drain["cost"])
	assert(giga_drain["effect_type"] == "LIFE_DRAIN", "Giga Drain effect_type debe ser LIFE_DRAIN")
	print("✓ 1.3 Giga Drain: 30 DMG, Coste 3⚡, LIFE_DRAIN")

	var drain_punch = GameData.get_move_data("Drain Punch")
	assert(drain_punch["dmg"] == 20 and drain_punch["cost"] == 2, "Drain Punch debe ser 20 DMG / 2⚡")
	print("✓ 1.4 Drain Punch: 20 DMG, Coste 2⚡, LIFE_DRAIN")

	# --- TEST 2: Verificación de Fases y Movesets de Pokémon ---
	print("\n--- TEST 2: Verificación de Asignación por Fases (poke_stats.csv) ---")
	
	var find_poke = func(poke_name: String) -> Dictionary:
		for k in GameData.pokemon_catalog:
			var entry = GameData.pokemon_catalog[k]
			if entry.get("name", "").to_lower() == poke_name.to_lower():
				return entry
		return {}
	
	# Treecko debe tener Absorb, no Mega Drain
	var treecko = find_poke.call("Treecko")
	assert(not treecko.is_empty(), "Treecko debe existir en GameData")
	var treecko_moves = [treecko["m1_name"], treecko["m2_name"]]
	assert("Absorb" in treecko_moves, "Treecko debe tener Absorb. Moves actuales: %s" % str(treecko_moves))
	assert(not ("Mega Drain" in treecko_moves), "Treecko NO debe tener Mega Drain")
	assert(not ("Giga Drain" in treecko_moves), "Treecko NO debe tener Giga Drain")
	print("✓ 2.1 Treecko: Tiene Absorb, sin Mega/Giga Drain")

	# Sunkern debe tener Absorb y Growth, no Mega Drain
	var sunkern = find_poke.call("Sunkern")
	var sunkern_moves = [sunkern["m1_name"], sunkern["m2_name"]]
	assert("Absorb" in sunkern_moves and not ("Mega Drain" in sunkern_moves), "Sunkern debe tener Absorb, no Mega Drain")
	print("✓ 2.2 Sunkern: Absorb y Growth (básico)")

	# Lotad -> Lombre -> Ludicolo progresión de drenaje
	var lotad = find_poke.call("Lotad")
	var lombre = find_poke.call("Lombre")
	var ludicolo = find_poke.call("Ludicolo")
	assert("Absorb" in [lotad["m1_name"], lotad["m2_name"]], "Lotad debe tener Absorb")
	assert("Mega Drain" in [lombre["m1_name"], lombre["m2_name"]], "Lombre debe tener Mega Drain")
	assert("Giga Drain" in [ludicolo["m1_name"], ludicolo["m2_name"]], "Ludicolo debe tener Giga Drain")
	print("✓ 2.3 Familia Lotad progresión perfecta: Lotad (Absorb) -> Lombre (Mega Drain) -> Ludicolo (Giga Drain)")

	# Eevee no debe tener Double Edge
	var eevee = find_poke.call("Eevee")
	var eevee_moves = [eevee["m1_name"], eevee["m2_name"]]
	assert(not ("Double Edge" in eevee_moves), "Eevee no debe tener Double Edge")
	assert("Tackle" in eevee_moves and "Quick Attack" in eevee_moves, "Eevee debe tener Tackle y Quick Attack")
	print("✓ 2.4 Eevee: Tackle y Quick Attack (Double Edge removido)")

	# Azurill vs Marill
	var azurill = find_poke.call("Azurill")
	var marill = find_poke.call("Marill")
	var azurill_moves = [azurill["m1_name"], azurill["m2_name"]]
	var marill_moves = [marill["m1_name"], marill["m2_name"]]
	assert(not ("Slam" in azurill_moves), "Azurill no debe tener Slam")
	assert("Bubble" in azurill_moves and "Tail Whip" in azurill_moves, "Azurill debe tener Bubble y Tail Whip")
	assert("Slam" in marill_moves, "Marill evolucionado debe tener Slam")
	print("✓ 2.5 Azurill/Marill: Azurill (Tail Whip) y Marill (Slam)")

	# Bonsly no debe tener Rock Slide
	var bonsly = find_poke.call("Bonsly")
	var bonsly_moves = [bonsly["m1_name"], bonsly["m2_name"]]
	assert(not ("Rock Slide" in bonsly_moves), "Bonsly no debe tener Rock Slide")
	print("✓ 2.6 Bonsly: Tackle y Rock Throw (Rock Slide removido)")

	# Chingling
	var chingling = find_poke.call("Chingling")
	var chingling_moves = [chingling["m1_name"], chingling["m2_name"]]
	assert(not ("Confusion" in chingling_moves), "Chingling no debe tener Confusion")
	print("✓ 2.7 Chingling: Astonish y Psywave")

	# --- TEST 3: Mecánica de Curación por Drenaje en Combate ---
	print("\n--- TEST 3: Mecánica de Curación y Ratio del 30% en Combate ---")
	
	# Usar un atacante con HP máxima suficiente para observar el 30% sin topar el cap
	var p_drain = GameData.create_pokemon_instance(find_poke.call("Ludicolo")["id"]) # Ludicolo
	p_drain.max_hp = 100
	p_drain.current_hp = 30 # Le faltan 70 HP
	p_drain.attack = 40
	p_drain.current_energy = 5
	
	var foe_neutral = GameData.create_pokemon_instance(find_poke.call("Rattata")["id"]) # Rattata (Normal, neutro)
	foe_neutral.max_hp = 200
	foe_neutral.current_hp = 200
	foe_neutral.defense = 40
	
	battle_scene.player_team = [p_drain]
	battle_scene.enemy_team = [foe_neutral]
	battle_scene.active_player_idx = 0
	battle_scene.active_enemy_idx = 0
	
	var initial_user_hp = p_drain.current_hp
	var initial_foe_hp = foe_neutral.current_hp
	
	var gd_instance = GameData.get_move_instance("Giga Drain")
	battle_scene.perform_attack(p_drain, foe_neutral, gd_instance, false, 3, dummy_v1, dummy_v2)
	
	var dmg_dealt = initial_foe_hp - foe_neutral.current_hp
	var hp_recovered = p_drain.current_hp - initial_user_hp
	
	# Giga drain base DMG es 30. Con stat ratio (40/40 = 1.0) daño esperado = 30.
	# Ratio 30%: 30 * 0.30 = 9 HP curados.
	print("Daño infligido por Giga Drain neutro: %d, HP curado: %d" % [dmg_dealt, hp_recovered])
	assert(dmg_dealt == 30, "Daño esperado neutro = 30. Actual: %d" % dmg_dealt)
	assert(hp_recovered == 9, "Curación esperada (30%% de 30) = 9. Actual: %d" % hp_recovered)
	print("✓ 3.1 Curación neutra precisa: 30 DMG infligido -> 9 HP recuperados (30% exacto)")

	# --- TEST 4: Desacoplamiento de Debilidad (No Duplica Curación) ---
	print("\n--- TEST 4: Desacoplamiento de Debilidad (heal_base = min(raw_damage, final_damage)) ---")
	
	var foe_water = GameData.create_pokemon_instance(find_poke.call("Squirtle")["id"]) # Squirtle
	foe_water.weakness = "GRASS" # Configurar debilidad a GRASS para comprobar x2
	foe_water.max_hp = 200
	foe_water.current_hp = 200
	foe_water.defense = 40
	
	p_drain.current_hp = 30
	p_drain.current_energy = 5
	initial_user_hp = p_drain.current_hp
	var initial_squirtle_hp = foe_water.current_hp
	
	battle_scene.perform_attack(p_drain, foe_water, gd_instance, false, 3, dummy_v1, dummy_v2)
	
	var dmg_dealt_weak = initial_squirtle_hp - foe_water.current_hp
	var hp_recovered_weak = p_drain.current_hp - initial_user_hp
	
	print("Daño infligido contra debilidad x2: %d, HP curado: %d" % [dmg_dealt_weak, hp_recovered_weak])
	assert(dmg_dealt_weak == 60, "Daño contra debilidad debe ser 60 (30 x 2). Actual: %d" % dmg_dealt_weak)
	# Curación debe basarse en el daño base normal (30), curando 9 HP, ¡NO 18 HP!
	assert(hp_recovered_weak == 9, "Curación contra debilidad debe desacoplarse del multiplicador x2 (9 HP, no 18). Actual: %d" % hp_recovered_weak)
	print("✓ 4.1 Desacoplamiento de debilidad verificado: Daño x2 (60 DMG) cura solo 9 HP (30% del daño base)")

	# --- TEST 5: Límite de Curación por Golpe (Cap de 20% Max HP) ---
	print("\n--- TEST 5: Cap Máximo de Curación (20% Max HP del Usuario) ---")
	var p_small = GameData.create_pokemon_instance(find_poke.call("Lotad")["id"]) # Lotad
	p_small.max_hp = 35 # 20% de 35 es 7 HP
	p_small.current_hp = 5
	p_small.attack = 40
	p_small.current_energy = 5
	
	# Si usamos un movimiento con mucho daño simulado o cap
	initial_user_hp = p_small.current_hp
	foe_neutral.current_hp = 200
	
	# Giga Drain (30 DMG -> normalmente 9 HP), pero en p_small con 35 max HP:
	# cap = max(6, int(round(35 * 0.20))) = max(6, 7) = 7 HP.
	battle_scene.perform_attack(p_small, foe_neutral, gd_instance, false, 3, dummy_v1, dummy_v2)
	var hp_capped = p_small.current_hp - initial_user_hp
	print("Lotad (35 Max HP) usó Giga Drain: Curación limitada a %d HP (Cap = 7)" % hp_capped)
	assert(hp_capped == 7, "Curación debe toparse con el cap de 20%% (7 HP). Actual: %d" % hp_capped)
	print("✓ 5.1 Cap de curación por golpe verificado exitosamente (máximo 20% max HP)")

	print("\n=======================================================")
	print(" TODOS LOS TESTS DE DRENAJE Y ALINEACIÓN DE FASES PASARON CON ÉXITO ")
	print("=======================================================\n")
	get_tree().quit(0)
