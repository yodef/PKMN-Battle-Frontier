extends Node

func _ready() -> void:
	print("=== INICIANDO TEST: CONSUMIBLES FUERA DE COMBATE Y MULTIPLICADORES ELEMENTALES ===")
	
	# --- PARTE 1: CONSUMIBLES FUERA DE COMBATE ---
	print("\n--- TEST 1: Uso de consumibles fuera de combate ---")
	
	# Preparar estado de campaña simulado
	GameData.campaign_submode = "STADIUM"
	var team = GameData.get_active_campaign_team_state()
	team.clear()
	
	# Crear Pokémon en equipo:
	# PKMN 0: Dañado (20 / 60 HP)
	var p0 = {
		"id": 1,
		"name": "Bulbasaur",
		"type": "GRASS",
		"stage": "Basic",
		"current_hp": 20,
		"max_hp": 60,
		"burn_turns": 3,
		"is_poisoned": true,
		"is_paralyzed": true
	}
	# PKMN 1: Fainted (0 / 80 HP)
	var p1 = {
		"id": 4,
		"name": "Charmander",
		"type": "FIRE",
		"stage": "Basic",
		"current_hp": 0,
		"max_hp": 80
	}
	# PKMN 2: Dañado severamente (10 / 100 HP)
	var p2 = {
		"id": 7,
		"name": "Squirtle",
		"type": "WATER",
		"stage": "Basic",
		"current_hp": 10,
		"max_hp": 100
	}
	team.append(p0)
	team.append(p1)
	team.append(p2)
	
	var inv = GameData.get_active_campaign_inventory()
	inv["potion"] = 2
	inv["super_potion"] = 2
	inv["hyper_potion"] = 1
	inv["revive"] = 2
	inv["remedy"] = 2
	
	# 1.1 Probar Poción (+25 HP) en Bulbasaur (20 -> 45)
	var ok_pot = GameData.use_potion_on_campaign_pkmn(0)
	assert(ok_pot == true, "use_potion_on_campaign_pkmn debe retornar true")
	assert(p0["current_hp"] == 45, "Bulbasaur debe curar 25 HP (20 + 25 = 45). Actual: %d" % p0["current_hp"])
	assert(inv["potion"] == 1, "Debe quedar 1 Poción en inventario. Actual: %d" % inv["potion"])
	print("✓ 1.1 Poción fuera de combate curó 25 HP exitosamente.")
	
	# 1.2 Probar Súper Poción (+60 HP) en Squirtle (10 -> 70)
	var ok_spot = GameData.use_super_potion_on_campaign_pkmn(2)
	assert(ok_spot == true, "use_super_potion_on_campaign_pkmn debe retornar true")
	assert(p2["current_hp"] == 70, "Squirtle debe curar 60 HP (10 + 60 = 70). Actual: %d" % p2["current_hp"])
	assert(inv["super_potion"] == 1, "Debe restar 1 Súper Poción")
	print("✓ 1.2 Súper Poción fuera de combate curó 60 HP exitosamente.")
	
	# 1.3 Probar Híper Poción (Full HP) en Squirtle (70 -> 100)
	var ok_hpot = GameData.use_hyper_potion_on_campaign_pkmn(2)
	assert(ok_hpot == true, "use_hyper_potion_on_campaign_pkmn debe retornar true")
	assert(p2["current_hp"] == 100, "Squirtle debe recuperar Full HP (100). Actual: %d" % p2["current_hp"])
	assert(inv["hyper_potion"] == 0, "Debe restar 1 Híper Poción")
	print("✓ 1.3 Híper Poción fuera de combate restauró 100% HP exitosamente.")
	
	# 1.4 Probar Poción en PKMN con vida llena (debe fallar)
	var pot_fail = GameData.use_potion_on_campaign_pkmn(2)
	assert(pot_fail == false, "Poción no debe aplicarse a Pokémon con HP lleno")
	print("✓ 1.4 Poción rechaza objetivos con HP lleno.")
	
	# 1.5 Probar Revive en Charmander debilitado (0 -> 40 HP = 50% de 80)
	var ok_rev = GameData.use_revive_on_campaign_pkmn(1)
	assert(ok_rev == true, "use_revive_on_campaign_pkmn debe retornar true en PKMN debilitado")
	assert(p1["current_hp"] == 40, "Charmander debe revivir con 50%% de HP (40). Actual: %d" % p1["current_hp"])
	assert(inv["revive"] == 1, "Debe restar 1 Revive")
	print("✓ 1.5 Revive fuera de combate reanima con 50% HP.")
	
	# 1.6 Probar Remedy en Bulbasaur (curar quemadura, veneno y parálisis)
	var ok_rem = GameData.use_remedy_on_campaign_pkmn(0)
	assert(ok_rem == true, "use_remedy_on_campaign_pkmn debe retornar true")
	assert(p0["burn_turns"] == 0, "Quemadura debe ser 0")
	assert(p0["is_poisoned"] == false, "Veneno debe ser false")
	assert(p0["is_paralyzed"] == false, "Parálisis debe ser false")
	assert(inv["remedy"] == 1, "Debe restar 1 Remedy")
	print("✓ 1.6 Remedy fuera de combate curó todos los estados negativos.")
	
	# --- PARTE 2: VENTAJAS ELEMENTALES COMO MULTIPLICADORES ---
	print("\n--- TEST 2: Ventajas elementales como multiplicadores ---")
	
	var battle_scene = load("res://scenes/battle.tscn").instantiate()
	add_child(battle_scene)
	
	# Verificar constantes
	assert(battle_scene.WEAKNESS_MULTIPLIER == 2.0, "WEAKNESS_MULTIPLIER debe ser 2.0 (x2)")
	assert(battle_scene.RESISTANCE_MULTIPLIER == 0.5, "RESISTANCE_MULTIPLIER debe ser 0.5 (x0.5)")
	print("✓ 2.1 Constantes de multiplicadores verificadas: x2.0 debilidad, x0.5 resistencia.")
	
	# Crear atacante y defensor con estadísticas neutras para probar multiplicadores
	var att = GameData.create_pokemon_instance(1) # Charmander (FIRE)
	att.attack = 10
	att.defense = 10
	
	var def_grass = GameData.create_pokemon_instance(0) # Bulbasaur (GRASS, débil a FIRE)
	def_grass.attack = 10
	def_grass.defense = 10
	def_grass.weakness = "FIRE"
	def_grass.resistant = "GROUND"
	
	var def_water = GameData.create_pokemon_instance(2) # Squirtle (WATER, resiste a FIRE)
	def_water.attack = 10
	def_water.defense = 10
	def_water.weakness = "ELECTRIC"
	def_water.resistant = "FIRE"
	
	var def_norm = GameData.create_pokemon_instance(16) # Pidgey (NORMAL, neutro a FIRE)
	def_norm.attack = 10
	def_norm.defense = 10
	def_norm.weakness = "ELECTRIC"
	def_norm.resistant = "NONE"
	
	# Move de Fuego de potencia 10
	var ember = GameData.MoveData.new("Ember", "FIRE", 10, 2, 1, false, 0, 0, false, "Fire attack")
	
	# Daño Neutro: 10 * (10/10) = 10
	var dmg_neutro = battle_scene.calculate_predicted_damage(att, def_norm, ember, 2, false)
	assert(dmg_neutro == 10, "Daño neutro esperado: 10. Obtenido: %d" % dmg_neutro)
	print("✓ 2.2 Daño neutro: %d DMG." % dmg_neutro)
	
	# Daño Súper Efectivo (x2): 10 * 2.0 = 20
	var dmg_weak = battle_scene.calculate_predicted_damage(att, def_grass, ember, 2, false)
	assert(dmg_weak == 20, "Daño súper efectivo con x2.0 esperado: 20. Obtenido: %d" % dmg_weak)
	print("✓ 2.3 Daño súper efectivo (x2.0): %d DMG (doble de 10)." % dmg_weak)
	
	# Daño Resistido (x0.5): 10 * 0.5 = 5
	var dmg_res = battle_scene.calculate_predicted_damage(att, def_water, ember, 2, false)
	assert(dmg_res == 5, "Daño resistido con x0.5 esperado: 5. Obtenido: %d" % dmg_res)
	print("✓ 2.4 Daño resistido (x0.5): %d DMG (mitad de 10)." % dmg_res)
	
	# Ataque real con perform_attack
	var dummy_c1 = Control.new()
	var dummy_c2 = Control.new()
	add_child(dummy_c1)
	add_child(dummy_c2)
	
	def_grass.current_hp = 100
	battle_scene.perform_attack(att, def_grass, ember, false, 2, dummy_c1, dummy_c2)
	assert(def_grass.current_hp == 80, "Bulbasaur debe recibir 20 DMG (100 - 20 = 80). Actual: %d" % def_grass.current_hp)
	print("✓ 2.5 perform_attack aplicó el multiplicador x2.0 correctamente en combate real.")
	
	def_water.current_hp = 100
	battle_scene.perform_attack(att, def_water, ember, false, 2, dummy_c1, dummy_c2)
	assert(def_water.current_hp == 95, "Squirtle debe recibir 5 DMG (100 - 5 = 95). Actual: %d" % def_water.current_hp)
	print("✓ 2.6 perform_attack aplicó el multiplicador x0.5 correctamente en combate real.")
	
	print("\n🎉 ¡TODOS LOS TESTS DE CONSUMIBLES Y MULTIPLICADORES ELEMENTALES PASARON CON ÉXITO! 🎉")
	get_tree().quit(0)
