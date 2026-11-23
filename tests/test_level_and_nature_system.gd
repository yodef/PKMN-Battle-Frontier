extends Node

func _ready() -> void:
	print("\n=== INICIANDO TESTS: SISTEMA DE NIVELES (1-10) Y NATURALEZAS CON MENTAS ===")
	
	GameData.load_types_from_csv()
	GameData.load_moves_from_csv()
	GameData.load_pokemon_from_csv()
	
	var find_poke = func(poke_name: String) -> Dictionary:
		for k in GameData.pokemon_catalog:
			var entry = GameData.pokemon_catalog[k]
			if entry.get("name", "").to_lower() == poke_name.to_lower():
				return entry
		return {}

	var charmander_entry = find_poke.call("Charmander")
	var charmeleon_entry = find_poke.call("Charmeleon")
	var charizard_entry = find_poke.call("Charizard")
	var bulbasaur_entry = find_poke.call("Bulbasaur")

	assert(not charmander_entry.is_empty(), "Charmander debe existir en el catálogo")
	assert(not charmeleon_entry.is_empty(), "Charmeleon debe existir en el catálogo")
	assert(not charizard_entry.is_empty(), "Charizard debe existir en el catálogo")
	assert(not bulbasaur_entry.is_empty(), "Bulbasaur debe existir en el catálogo")

	var cid_charmander: int = charmander_entry["id"]
	var cid_charmeleon: int = charmeleon_entry["id"]
	var cid_charizard: int = charizard_entry["id"]
	var cid_bulbasaur: int = bulbasaur_entry["id"]

	# Reset state
	GameData.erase_profile()
	GameData.set_active_campaign_gold(10000)
	GameData.player_mints = 0

	# -------------------------------------------------------------
	# TEST 1: ESTADO INICIAL NEUTRAL Y NIVEL 1
	# -------------------------------------------------------------
	print("\n--- TEST 1: Estado inicial por defecto (Lv 1 y Neutral) ---")
	assert(GameData.get_pokemon_line_level(cid_charmander) == 1, "Charmander debe iniciar en Lv 1")
	assert(GameData.get_pokemon_line_level(cid_charmeleon) == 1, "Charmeleon debe iniciar en Lv 1")
	assert(GameData.get_pokemon_line_level(cid_charizard) == 1, "Charizard debe iniciar en Lv 1")
	assert(GameData.get_pokemon_line_nature(cid_charmander) == "neutral", "Charmander debe ser Neutral por defecto")
	assert(GameData.get_pokemon_line_nature(cid_charmeleon) == "neutral", "Charmeleon debe ser Neutral por defecto")
	assert(GameData.get_pokemon_line_nature(cid_charizard) == "neutral", "Charizard debe ser Neutral por defecto")
	print("✔ Test 1 Superado: Estado inicial Lv 1 y Neutral verificado.")

	# -------------------------------------------------------------
	# TEST 2: MEJORA DE NIVEL COMPARTIDA EN TODA LA LÍNEA EVOLUTIVA
	# -------------------------------------------------------------
	print("\n--- TEST 2: Subir a Charmeleon debe subir toda la línea (Charmander, Charmeleon, Charizard) ---")
	var cost_lv1_to_2 = GameData.get_card_level_up_cost(1)
	assert(cost_lv1_to_2 == 100, "Costo de Lv 1 a Lv 2 debe ser 100G")
	
	var initial_gold = GameData.get_active_campaign_gold()
	var res_upg = GameData.upgrade_pokemon_line_level(cid_charmeleon)
	assert(res_upg.get("success", false), "La mejora de Charmeleon debe ser exitosa")
	assert(GameData.get_active_campaign_gold() == initial_gold - cost_lv1_to_2, "El oro debe reducirse exactamente en el costo")
	
	# Verificar que Charmander y Charizard ahora también son Lv 2
	assert(GameData.get_pokemon_line_level(cid_charmander) == 2, "Charmander debe estar en Lv 2")
	assert(GameData.get_pokemon_line_level(cid_charmeleon) == 2, "Charmeleon debe estar en Lv 2")
	assert(GameData.get_pokemon_line_level(cid_charizard) == 2, "Charizard debe estar en Lv 2")
	
	# Verificar que Bulbasaur sigue en Lv 1 (no afectado)
	assert(GameData.get_pokemon_line_level(cid_bulbasaur) == 1, "Bulbasaur no debe haber subido de nivel")
	print("✔ Test 2 Superado: La mejora de Charmeleon elevó a toda la línea a Lv 2 sin afectar a otras líneas.")

	# -------------------------------------------------------------
	# TEST 3: ESCALADO HASTA NIVEL 10 Y BALANCE DE STATS
	# -------------------------------------------------------------
	print("\n--- TEST 3: Escalado progresivo de costos hasta Lv 10 y límite de nivel ---")
	while GameData.get_pokemon_line_level(cid_charmander) < GameData.MAX_CARD_LEVEL:
		var curr_lvl = GameData.get_pokemon_line_level(cid_charmander)
		var expected_cost = GameData.LEVEL_UP_GOLD_COSTS[curr_lvl]
		assert(GameData.get_card_level_up_cost(curr_lvl) == expected_cost, "Costo para Lv %d debe coincidir" % curr_lvl)
		var up_res = GameData.upgrade_pokemon_line_level(cid_charizard)
		assert(up_res.get("success", false), "Debe poder subir de nivel")

	assert(GameData.get_pokemon_line_level(cid_charmander) == 10, "Charmander debe ser Lv 10")
	assert(GameData.get_pokemon_line_level(cid_charmeleon) == 10, "Charmeleon debe ser Lv 10")
	assert(GameData.get_pokemon_line_level(cid_charizard) == 10, "Charizard debe ser Lv 10")
	assert(GameData.get_card_level_up_cost(10) == 0, "No debe haber costo de mejora a Lv 10 (máximo)")
	
	var overflow_res = GameData.upgrade_pokemon_line_level(cid_charmander)
	assert(not overflow_res.get("success", false), "No se debe poder subir más allá de Lv 10")
	assert(overflow_res.get("error", "") == "MAX_LEVEL", "Error debe ser MAX_LEVEL")

	# Stats en Lv 10 vs base stats
	var base_stats = {
		"hp": int(GameData.pokemon_catalog[cid_charizard]["hp"]),
		"atk": int(GameData.pokemon_catalog[cid_charizard]["attack"]),
		"def": int(GameData.pokemon_catalog[cid_charizard]["defense"]),
		"spd": int(GameData.pokemon_catalog[cid_charizard]["speed"])
	}
	var eff_stats_lv10 = GameData.get_pokemon_effective_stats(cid_charizard)
	print("Charizard Base Stats: HP=%d, ATK=%d, DEF=%d, SPD=%d" % [base_stats["hp"], base_stats["atk"], base_stats["def"], base_stats["spd"]])
	print("Charizard Lv 10 Stats (Neutral): HP=%d, ATK=%d, DEF=%d, SPD=%d" % [eff_stats_lv10["hp"], eff_stats_lv10["attack"], eff_stats_lv10["defense"], eff_stats_lv10["speed"]])
	
	assert(eff_stats_lv10["hp"] > base_stats["hp"], "HP efectivo en Lv 10 debe ser mayor que base")
	assert(eff_stats_lv10["attack"] > base_stats["atk"], "ATK efectivo en Lv 10 debe ser mayor que base")
	assert(eff_stats_lv10["defense"] > base_stats["def"], "DEF efectivo en Lv 10 debe ser mayor que base")
	assert(eff_stats_lv10["speed"] == base_stats["spd"] + 2, "SPD debe haber ganado +2 (+1 en Lv 5 y +1 en Lv 10)")
	print("✔ Test 3 Superado: Escalado hasta Lv 10 y stats equilibrados.")

	# -------------------------------------------------------------
	# TEST 4: COMPRA DE MENTAS EN EL CAMPAMENTO
	# -------------------------------------------------------------
	print("\n--- TEST 4: Compra de Menta por 500G en el Campamento ---")
	GameData.player_mints = 0
	var gold_before_mint = GameData.get_active_campaign_gold()
	var buy_res = GameData.buy_mint_at_camp()
	assert(buy_res.get("success", false), "La compra de menta debe ser exitosa con oro suficiente")
	assert(GameData.player_mints == 1, "Debe tener 1 menta")
	assert(GameData.get_active_campaign_gold() == gold_before_mint - GameData.MINT_COST_GOLD, "El oro debe reducirse en 500G")

	# Intentar comprar sin oro
	GameData.set_active_campaign_gold(200)
	var buy_fail = GameData.buy_mint_at_camp()
	assert(not buy_fail.get("success", false), "No debe poder comprar menta con menos de 500G")
	assert(buy_fail.get("error", "") == "NOT_ENOUGH_GOLD", "Error debe ser NOT_ENOUGH_GOLD")
	assert(GameData.player_mints == 1, "El contador de mentas no debe cambiar")
	print("✔ Test 4 Superado: Compra de mentas validada con control de oro.")

	# -------------------------------------------------------------
	# TEST 5: USO DE MENTA, PRIORIZACIÓN DE STATS Y EFECTO EN TODA LA LÍNEA
	# -------------------------------------------------------------
	print("\n--- TEST 5: Aplicación de Naturaleza Firme (Adamant: +ATK, -DEF) compartida en toda la línea ---")
	# Usamos la menta en Charmander
	var nat_res = GameData.set_pokemon_line_nature(cid_charmander, "adamant", true)
	assert(nat_res.get("success", false), "El cambio de naturaleza debe ser exitoso")
	assert(GameData.player_mints == 0, "La menta debe haberse consumido")

	# Verificar que toda la línea tiene naturaleza Firme
	assert(GameData.get_pokemon_line_nature(cid_charmander) == "adamant", "Charmander debe ser Adamant")
	assert(GameData.get_pokemon_line_nature(cid_charmeleon) == "adamant", "Charmeleon debe ser Adamant")
	assert(GameData.get_pokemon_line_nature(cid_charizard) == "adamant", "Charizard debe ser Adamant")
	assert(GameData.get_pokemon_line_nature(cid_bulbasaur) == "neutral", "Bulbasaur debe permanecer Neutral")

	# Verificar stats con Firme (Adamant) vs Neutral en Lv 10
	var stats_adamant = GameData.get_pokemon_effective_stats(cid_charizard)
	print("Charizard Lv 10 Stats (Adamant): HP=%d, ATK=%d, DEF=%d, SPD=%d" % [stats_adamant["hp"], stats_adamant["attack"], stats_adamant["defense"], stats_adamant["speed"]])
	
	assert(stats_adamant["attack"] > eff_stats_lv10["attack"], "ATK en Firme debe ser mayor que Neutral en Lv 10")
	assert(stats_adamant["defense"] < eff_stats_lv10["defense"], "DEF en Firme debe ser menor que Neutral en Lv 10")
	assert(stats_adamant["hp"] == eff_stats_lv10["hp"], "HP no se ve afectado por Firme")
	print("✔ Test 5 Superado: Naturaleza Firme aplicada a toda la línea con priorización de stats.")

	# -------------------------------------------------------------
	# TEST 6: INSTANCIAS DE JUGADOR VS IA / SALVADERA
	# -------------------------------------------------------------
	print("\n--- TEST 6: Instancias de combate Jugador (con mejoras) vs Enemigo IA (stats base) ---")
	var p_inst = GameData.create_pokemon_instance(cid_charizard, true)
	var e_inst = GameData.create_pokemon_instance(cid_charizard, false)
	
	assert(p_inst.level == 10, "Instancia de jugador debe ser Lv 10")
	assert(p_inst.nature == "adamant", "Instancia de jugador debe ser Firme")
	assert(p_inst.attack == stats_adamant["attack"], "Ataque de jugador debe tener stats efectivos")
	
	assert(e_inst.level == 1, "Instancia enemiga debe ser Lv 1")
	assert(e_inst.nature == "neutral", "Instancia enemiga debe ser Neutral")
	assert(e_inst.attack == base_stats["atk"], "Ataque enemigo debe ser el base")
	print("✔ Test 6 Superado: Separación limpia entre mejoras del jugador y estadísticas base de enemigos.")

	# -------------------------------------------------------------
	# TEST 7: PERSISTENCIA (SAVE / LOAD)
	# -------------------------------------------------------------
	print("\n--- TEST 7: Guardado y Carga de Perfil ---")
	GameData.player_mints = 3
	var save_data = GameData.get_save_dict()
	assert(save_data.has("economy") and save_data["economy"].get("mints", 0) == 3, "El save_dict debe contener economy.mints = 3")
	assert(save_data.has("line_upgrades"), "El save_dict debe contener 'line_upgrades'")
	
	# Reiniciamos temporalmente
	GameData.player_mints = 0
	GameData.player_line_upgrades = {}
	assert(GameData.get_pokemon_line_level(cid_charizard) == 1, "Tras reset, debe ser Lv 1")
	assert(GameData.get_pokemon_line_nature(cid_charizard) == "neutral", "Tras reset, debe ser Neutral")
	
	# Cargamos
	GameData.apply_save_dict(save_data)
	assert(GameData.player_mints == 3, "Debe restaurar 3 mentas")
	assert(GameData.get_pokemon_line_level(cid_charmander) == 10, "Debe restaurar Lv 10")
	assert(GameData.get_pokemon_line_nature(cid_charmander) == "adamant", "Debe restaurar Adamant")
	assert(GameData.get_pokemon_line_level(cid_charizard) == 10, "Charizard debe restaurar Lv 10")
	assert(GameData.get_pokemon_line_nature(cid_charizard) == "adamant", "Charizard debe restaurar Adamant")
	print("✔ Test 7 Superado: Persistencia de datos validada.")

	print("\n🎉 TODOS LOS TESTS DEL SISTEMA DE NIVELES Y NATURALEZAS PASARON SATISFACTORIAMENTE.")
	get_tree().quit(0)
