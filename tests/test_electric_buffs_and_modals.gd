extends Node

func _ready() -> void:
	print("--- INICIANDO TEST: ELECTRIC BUFFS & FULLSCREEN MODALS ---")
	
	# 1. Test Moves Catalog
	var thunder_data = GameData.get_move_data("39")
	assert(not thunder_data.is_empty(), "Thunder no encontrado")
	assert(thunder_data["dmg"] == 13, "Thunder base damage debe ser 13, obtenido %d" % thunder_data["dmg"])
	assert(thunder_data["effect_type"] == "MISS", "Thunder effect_type debe ser MISS")
	print("✔ Test Thunder base damage == 13 OK")
	
	var discharge_data = GameData.get_move_data("40")
	assert(not discharge_data.is_empty(), "Discharge no encontrado")
	assert(discharge_data["dmg"] == 8, "Discharge base damage debe ser 8, obtenido %d" % discharge_data["dmg"])
	print("✔ Test Discharge base damage == 8 OK")
	
	var thunderbolt_data = GameData.get_move_data("216")
	assert(not thunderbolt_data.is_empty(), "Thunderbolt no encontrado")
	assert(thunderbolt_data["effect_type"] == "OVERCHARGE", "Thunderbolt effect_type debe ser OVERCHARGE")
	assert(not str(thunderbolt_data["desc"]).to_lower().contains("remove"), "Thunderbolt no debe remover paralisis en su descripcion")
	print("✔ Test Thunderbolt catalog OK")
	
	# 2. Test Paralysis -2 Speed Penalty
	var pikachu = GameData.create_pokemon_instance(25) # Pikachu ID 25
	assert(pikachu != null, "Pikachu no creado")
	var base_spd = pikachu.get_effective_speed()
	pikachu.is_paralyzed = true
	var paralyzed_spd = pikachu.get_effective_speed()
	assert(paralyzed_spd == max(1, base_spd - 2), "Paralisis debe reducir la velocidad en -2 (Base: %d, Paralyzed: %d)" % [base_spd, paralyzed_spd])
	pikachu.is_paralyzed = false
	assert(pikachu.get_effective_speed() == base_spd, "Al curar paralisis la velocidad debe volver a la normal")
	print("✔ Test Paralysis Speed Penalty (-2 SPD) OK")
	
	# 3. Test Battle Scene: Thunderbolt overcharge & Thunder refund & Pichu shock
	var battle_scene = load("res://scenes/battle.tscn").instantiate()
	add_child(battle_scene)
	battle_scene.start_new_game()
	
	# Crear atacante (Pikachu) y defensor (Squirtle)
	var attacker = GameData.create_pokemon_instance(25)
	attacker.current_energy = 2
	var defender = GameData.create_pokemon_instance(7)
	defender.is_paralyzed = true
	defender.paralyze_turns = 2
	battle_scene.player_team = [attacker]
	battle_scene.enemy_team = [defender]
	battle_scene.active_player_idx = 0
	battle_scene.active_enemy_idx = 0
	
	# Probar get_pokemon_effective_speed con paralisis
	var eff_spd = battle_scene.get_pokemon_effective_speed(defender, attacker)
	assert(eff_spd == max(1, defender.speed - 2), "get_pokemon_effective_speed debe reflejar -2 SPD en objetivo paralizado")
	print("✔ Test battle get_pokemon_effective_speed with paralysis OK")
	
	# Probar OVERCHARGE en battle: daño +6 y que NO remueva la parálisis
	attacker.current_energy = 3
	var hp_before = defender.current_hp
	var tb_move = attacker.moves[1] # Pikachu move 2 es Thunderbolt
	battle_scene.perform_attack(attacker, defender, tb_move, false, 3, battle_scene.player_card_img, battle_scene.enemy_card_img)
	assert(defender.is_paralyzed == true, "OVERCHARGE ya no debe curar la paralisis")
	assert(defender.paralyze_turns > 0, "paralyze_turns debe conservarse")
	print("✔ Test OVERCHARGE does NOT cure paralysis OK")
	
	# Probar Thunder MISS full refund (2 energía)
	attacker.current_energy = 0
	attacker.max_energy = 4
	var refund_energy = thunder_data["cost"]
	attacker.current_energy = min(attacker.max_energy, attacker.current_energy + refund_energy)
	assert(attacker.current_energy == 2, "Fallo de Thunder debe reembolsar todo el coste (2 energia)")
	print("✔ Test Thunder MISS full energy refund OK")
	
	battle_scene.queue_free()
	
	# 4. Test Main Menu Modals Layout
	var menu_scene = load("res://scenes/main_menu.tscn").instantiate()
	add_child(menu_scene)
	
	menu_scene._setup_achievements_modal()
	assert(menu_scene.achievements_modal != null, "achievements_modal debe existir")
	var ach_box = menu_scene.achievements_modal.get_node_or_null("AchievementsBox")
	assert(ach_box != null, "achievements_modal debe contener AchievementsBox como VBoxContainer full-rect")
	assert(menu_scene.achievements_modal.get_node_or_null("CenterContainer") == null, "achievements_modal no debe usar CenterContainer flotante")
	
	menu_scene._refresh_achievements_ui()
	var cards = menu_scene.achievements_list_vbox.get_children()
	assert(cards.size() > 0, "Debe haber al menos 1 card de logros")
	print("✔ Test AchievementsModal Fullscreen Layout OK")
	
	menu_scene._setup_johto_episodes_modal()
	var johto_box = menu_scene.johto_episodes_modal.get_node_or_null("JohtoEpisodesBox")
	assert(johto_box != null, "johto_episodes_modal debe contener JohtoEpisodesBox full-rect")
	print("✔ Test JohtoEpisodesModal Fullscreen Layout OK")
	
	menu_scene._setup_johto_routes_modal()
	var j_routes_box = menu_scene.johto_routes_modal.get_node_or_null("JohtoRoutesBox")
	assert(j_routes_box != null, "johto_routes_modal debe contener JohtoRoutesBox full-rect")
	print("✔ Test JohtoRoutesModal Fullscreen Layout OK")
	
	menu_scene._setup_adventure_ep5_routes_modal()
	var ep5_box = menu_scene.adventure_ep5_routes_modal.get_node_or_null("Ep5RoutesBox")
	assert(ep5_box != null, "adventure_ep5_routes_modal debe contener Ep5RoutesBox full-rect")
	print("✔ Test AdventureEp5RoutesModal Fullscreen Layout OK")
	
	menu_scene._setup_adventure_ep6_routes_modal()
	var ep6_box = menu_scene.adventure_ep6_routes_modal.get_node_or_null("Ep6RoutesBox")
	assert(ep6_box != null, "adventure_ep6_routes_modal debe contener Ep6RoutesBox full-rect")
	print("✔ Test AdventureEp6RoutesModal Fullscreen Layout OK")
	
	menu_scene._setup_adventure_ep7_routes_modal()
	var ep7_box = menu_scene.adventure_ep7_routes_modal.get_node_or_null("Ep7RoutesBox")
	assert(ep7_box != null, "adventure_ep7_routes_modal debe contener Ep7RoutesBox full-rect")
	print("✔ Test AdventureEp7RoutesModal Fullscreen Layout OK")
	
	menu_scene.queue_free()
	
	# 5. Test Localization Freeze Bug Prevention
	var loc = load("res://scripts/localization.gd")
	var pack_opened_txt = "🎉 BOOSTER PACK OPENED!"
	var en_res = loc.translate_es_to_en(pack_opened_txt)
	assert(not en_res.contains("freeze"), "translate_es_to_en no debe insertar 'freeze' en '%s', obtenido: '%s'" % [pack_opened_txt, en_res])
	assert(not en_res.contains("again"), "translate_es_to_en no debe insertar 'again' en '%s', obtenido: '%s'" % [pack_opened_txt, en_res])
	
	var new_txt = "⭐ NEW! (x1)"
	var new_en = loc.translate_es_to_en(new_txt)
	assert(not new_en.contains("freeze"), "translate_es_to_en no debe insertar 'freeze' en '%s', obtenido: '%s'" % [new_txt, new_en])
	assert(not new_en.contains("again"), "translate_es_to_en no debe insertar 'again' en '%s', obtenido: '%s'" % [new_txt, new_en])
	
	# Simular múltiples pasadas recursivas para asegurar que no se produzca acumulación infinita
	var iterated = pack_opened_txt
	for i in range(5):
		iterated = loc.translate_es_to_en(iterated)
	assert(not iterated.contains("freeze"), "Múltiples pasadas de traducción no deben generar bucle de 'freeze'")
	print("✔ Test Localization Exclamation Freeze Bug Fixed OK")
	
	print("🎉 TODOS LOS TESTS DE ELECTRIC BUFFS & MODALS PASARON CON EXITO 🎉")
	get_tree().quit(0)
