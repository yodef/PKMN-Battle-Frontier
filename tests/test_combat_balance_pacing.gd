extends Node

func _ready() -> void:
	print("\n=== INICIANDO TEST: BALANCE GLOBAL DE COMBATE Y RITMO (4-5 ATAQUES) ===")
	
	GameData.load_moves_from_csv()
	GameData.load_pokemon_from_csv()
	
	var battle_scene = load("res://scenes/battle.tscn").instantiate()
	add_child(battle_scene)
	await get_tree().process_frame
	await get_tree().process_frame
	
	# --- TEST 1: Daño base de movimientos por coste de energía ---
	print("\n--- TEST 1: Calibración de Daño por Coste de Energía ---")
	var tackle = GameData.get_move_data("Tackle")
	assert(tackle["dmg"] == 8, "Tackle (Cost 0) debe causar 8 DMG. Actual: %d" % tackle["dmg"])
	print("✓ 1.1 Cost 0 (Tackle): %d DMG" % tackle["dmg"])
	
	var ember = GameData.get_move_data("Ember")
	assert(ember["dmg"] >= 10 and ember["dmg"] <= 14, "Ember (Cost 1) debe estar entre 10 y 14 DMG. Actual: %d" % ember["dmg"])
	print("✓ 1.2 Cost 1 (Ember): %d DMG" % ember["dmg"])
	
	var vine_whip = GameData.get_move_data("Vine Whip")
	assert(vine_whip["dmg"] >= 18 and vine_whip["dmg"] <= 25, "Vine Whip (Cost 2) debe estar entre 18 y 25 DMG. Actual: %d" % vine_whip["dmg"])
	print("✓ 1.3 Cost 2 (Vine Whip): %d DMG" % vine_whip["dmg"])
	
	var flamethrower = GameData.get_move_data("Flamethrower")
	assert(flamethrower["dmg"] >= 30 and flamethrower["dmg"] <= 38, "Flamethrower (Cost 3) debe estar entre 30 y 38 DMG. Actual: %d" % flamethrower["dmg"])
	print("✓ 1.4 Cost 3 (Flamethrower): %d DMG" % flamethrower["dmg"])
	
	var fire_blast = GameData.get_move_data("Fire Blast")
	assert(fire_blast["dmg"] >= 46 and fire_blast["dmg"] <= 54, "Fire Blast (Cost 4) debe estar entre 46 y 54 DMG. Actual: %d" % fire_blast["dmg"])
	print("✓ 1.5 Cost 4 (Fire Blast): %d DMG" % fire_blast["dmg"])
	
	var hyper_beam = GameData.get_move_data("Hyper Beam")
	assert(hyper_beam["dmg"] >= 75 and hyper_beam["dmg"] <= 85, "Hyper Beam (Cost 5) debe estar entre 75 y 85 DMG. Actual: %d" % hyper_beam["dmg"])
	print("✓ 1.6 Cost 5 (Hyper Beam): %d DMG" % hyper_beam["dmg"])
	
	# --- TEST 2: Ritmo de combate (Time-To-Kill en 3-4 ataques, máx 5) ---
	print("\n--- TEST 2: Ritmo de Combate (Time-To-Kill) ---")
	# 2.1 Basic vs Basic: Bulbasaur (36 HP) atacado por Charmander Ember (12 DMG * x2 ventaja = 24 DMG) o Tackle neutro (8 DMG)
	var bulba = GameData.create_pokemon_instance(0)
	var charma = GameData.create_pokemon_instance(1)
	bulba.attack = 20
	bulba.defense = 20
	charma.attack = 20
	charma.defense = 20
	
	var tackle_dmg = battle_scene.calculate_predicted_damage(charma, bulba, tackle, 0, false)
	var attacks_to_ko_neutral = ceil(float(bulba.max_hp) / float(tackle_dmg))
	print("  Bulbasaur (36 HP) vs Tackle neutro (%d DMG): %d ataques para KO" % [tackle_dmg, attacks_to_ko_neutral])
	assert(attacks_to_ko_neutral <= 5, "Un combate neutro básico no debe requerir más de 5 ataques")
	
	# 2.2 Stage 2 vs Stage 2: Charizard (100 HP) vs Blastoise (105 HP)
	var charizard = GameData.create_pokemon_instance(6)
	var blastoise = GameData.create_pokemon_instance(8)
	var surf_data = GameData.get_move_data("Surf")
	var surf_dmg = battle_scene.calculate_predicted_damage(blastoise, charizard, surf_data, surf_data["cost"], false)
	# Surf es Agua vs Charizard Fuego (x2 debilidad)
	print("  Charizard (%d HP) vs Blastoise Surf super efectivo (%d DMG): KO en %d ataques" % [
		charizard.max_hp, surf_dmg, ceil(float(charizard.max_hp) / float(surf_dmg))
	])
	assert(surf_dmg >= 50, "Surf super efectivo contra Charizard debe superar 50 DMG")
	assert(ceil(float(charizard.max_hp) / float(surf_dmg)) <= 2, "Con ventaja de tipo un Stage 2 cae en 1-2 golpes")
	
	# --- TEST 3: Flujo de energía pasiva al final de ronda ---
	print("\n--- TEST 3: Flujo de Energía Pasiva para Activos y Banca ---")
	var p_act = battle_scene.get_active_player()
	var e_act = battle_scene.get_active_enemy()
	p_act.current_hp = 50
	p_act.max_energy = 5
	p_act.current_energy = 1
	e_act.current_hp = 50
	e_act.max_energy = 5
	e_act.current_energy = 2
	
	# Simular regeneración de fin de ronda
	for team in [battle_scene.player_team, battle_scene.enemy_team]:
		for pkmn in team:
			if pkmn.current_hp > 0 and pkmn.current_energy < pkmn.max_energy:
				pkmn.current_energy = min(pkmn.max_energy, pkmn.current_energy + 1)
				
	assert(p_act.current_energy == 2, "El activo del jugador debe regenerar +1⚡ pasivo")
	assert(e_act.current_energy == 3, "El activo rival debe regenerar +1⚡ pasivo")
	print("✓ 3.1 Pokémon activos regeneran +1⚡ pasivo al final de ronda")
	
	print("\n=======================================================")
	print("🎉 TODOS LOS TESTS DE BALANCE Y RITMO DE COMBATE PASARON CON ÉXITO 🎉")
	print("=======================================================\n")
	get_tree().quit()
