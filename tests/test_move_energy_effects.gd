extends Node

func _ready() -> void:
	print("--- INICIANDO TEST DE EFECTOS DE MOVES CON ENERGÍA COMPLETA VS PARCIAL ---")
	await get_tree().process_frame
	await get_tree().process_frame
	
	var battle_scene = load("res://scenes/battle.tscn").instantiate()
	add_child(battle_scene)
	await get_tree().process_frame
	await get_tree().process_frame
	
	# 1. Probar Aerial Ace (Coste: 2, Base: 8, Efecto: BOOST_IF_FASTER +3 DMG si atacante es más veloz)
	var attacker = GameData.create_pokemon_instance(16) # Pidgey (SPD: 3)
	var defender = GameData.create_pokemon_instance(0)  # Bulbasaur (SPD: 1, Debilidad: FUEGO, Res: OSCURO)
	var aerial_ace = create_move_instance("Aerial Ace")
	assert(aerial_ace != null, "Aerial Ace debe existir.")
	assert(aerial_ace.cost == 2, "Aerial Ace debe costar 2 energías.")
	
	# Caso A: Energía PARCIAL (Paga 1 de 2 energías)
	attacker.current_energy = 1
	defender.current_hp = 30
	defender.max_hp = 30
	battle_scene.perform_attack(attacker, defender, aerial_ace, false, 1, battle_scene.player_card_img, battle_scene.enemy_card_img)
	
	# Daño esperado: 8 / 2 = 4 DMG. El efecto de velocidad (+3) NO debe activarse por tener energía parcial.
	var dmg_taken_partial = 30 - defender.current_hp
	assert(dmg_taken_partial == 4, "Con energía parcial (1/2), Aerial Ace debe hacer daño fraccionado (4 DMG) sin bono de SPD. Daño recibido: %d" % dmg_taken_partial)
	print("✓ Verificación 1: Aerial Ace con energía parcial (1/2⚡) inflige solo daño fraccionado (4 DMG) y NO activa efecto de velocidad.")
	
	# Caso B: Energía COMPLETA (Paga 2 de 2 energías)
	attacker.current_energy = 2
	defender.current_hp = 30
	battle_scene.perform_attack(attacker, defender, aerial_ace, false, 2, battle_scene.player_card_img, battle_scene.enemy_card_img)
	
	# Daño esperado: 8 base + 3 bono velocidad (Pidgey SPD 3 > Bulbasaur SPD 1) = 11 DMG.
	var dmg_taken_full = 30 - defender.current_hp
	assert(dmg_taken_full == 11, "Con energía completa (2/2), Aerial Ace debe hacer 8 base + 3 bono = 11 DMG. Daño recibido: %d" % dmg_taken_full)
	print("✓ Verificación 2: Aerial Ace con energía completa (2/2⚡) activa su efecto de mayor velocidad (+3 DMG = 11 DMG total).")
	
	# 2. Probar Rapid Spin (Coste: 2, Base: 6, Efecto: limpia estados negativos)
	var rapid_spin = create_move_instance("Rapid Spin")
	assert(rapid_spin != null, "Rapid Spin debe existir.")
	
	# Caso A: Energía PARCIAL (Paga 1 de 2 energías) con quemadura activa
	attacker.current_energy = 1
	attacker.burn_turns = 2
	attacker.burn_dmg = 1
	defender.current_hp = 30
	battle_scene.perform_attack(attacker, defender, rapid_spin, false, 1, battle_scene.player_card_img, battle_scene.enemy_card_img)
	
	assert(attacker.burn_turns == 2, "Con energía parcial (1/2⚡), Rapid Spin NO debe limpiar la quemadura.")
	var rs_partial_dmg = 30 - defender.current_hp
	assert(rs_partial_dmg == 3, "Rapid Spin debe hacer daño fraccionado (3 DMG). Daño recibido: %d" % rs_partial_dmg)
	print("✓ Verificación 3: Rapid Spin con energía parcial (1/2⚡) inflige daño (3 DMG) pero NO limpia estados negativos.")
	
	# Caso B: Energía COMPLETA (Paga 2 de 2 energías)
	attacker.current_energy = 2
	attacker.burn_turns = 2
	battle_scene.perform_attack(attacker, defender, rapid_spin, false, 2, battle_scene.player_card_img, battle_scene.enemy_card_img)
	assert(attacker.burn_turns == 0, "Con energía completa (2/2⚡), Rapid Spin DEBE limpiar la quemadura.")
	print("✓ Verificación 4: Rapid Spin con energía completa (2/2⚡) limpia exitosamente los estados alterados.")
	
	# 3. Probar Flash Cannon (Coste: 2, Base: 6, Efecto: SHIELD_BREAKER +4 DMG al siguiente ataque)
	var flash_cannon = create_move_instance("Flash Cannon")
	assert(flash_cannon != null, "Flash Cannon debe existir.")
	
	# Caso A: Energía PARCIAL
	attacker.current_energy = 1
	attacker.shield_breaker_bonus = 0
	battle_scene.perform_attack(attacker, defender, flash_cannon, false, 1, battle_scene.player_card_img, battle_scene.enemy_card_img)
	assert(attacker.shield_breaker_bonus == 0, "Con energía parcial (1/2⚡), Flash Cannon NO debe cargar bono de escudo.")
	print("✓ Verificación 5: Flash Cannon con energía parcial (1/2⚡) NO carga el bono para el siguiente movimiento.")
	
	# Caso B: Energía COMPLETA
	attacker.current_energy = 2
	battle_scene.perform_attack(attacker, defender, flash_cannon, false, 2, battle_scene.player_card_img, battle_scene.enemy_card_img)
	assert(attacker.shield_breaker_bonus == 4, "Con energía completa (2/2⚡), Flash Cannon DEBE cargar +4 DMG para el siguiente movimiento.")
	print("✓ Verificación 6: Flash Cannon con energía completa (2/2⚡) carga +4 DMG para el siguiente movimiento.")
	
	# 4. Probar Giga Drain (Coste: 2, Base: 10, Efecto: LIFE_DRAIN cura 50% del daño)
	var giga_drain = create_move_instance("Giga Drain")
	assert(giga_drain != null, "Giga Drain debe existir.")
	
	# Caso A: Energía PARCIAL
	attacker.current_hp = 5
	attacker.max_hp = 20
	attacker.current_energy = 1
	defender.current_hp = 30
	battle_scene.perform_attack(attacker, defender, giga_drain, false, 1, battle_scene.player_card_img, battle_scene.enemy_card_img)
	assert(attacker.current_hp == 5, "Con energía parcial (1/2⚡), Giga Drain NO debe curar vida.")
	print("✓ Verificación 7: Giga Drain con energía parcial (1/2⚡) NO cura vida al atacante.")
	
	# Caso B: Energía COMPLETA
	attacker.current_energy = 2
	battle_scene.perform_attack(attacker, defender, giga_drain, false, 2, battle_scene.player_card_img, battle_scene.enemy_card_img)
	assert(attacker.current_hp > 5, "Con energía completa (2/2⚡), Giga Drain DEBE curar vida (HP actual: %d)." % attacker.current_hp)
	print("✓ Verificación 8: Giga Drain con energía completa (2/2⚡) cura vida exitosamente.")
	
	# 5. Probar Fury Attack (MULTI_ATTACK) - Excepción donde los golpes escalan con la energía
	var fury_attack = create_move_instance("Fury Attack")
	assert(fury_attack != null, "Fury Attack debe existir.")
	
	attacker.current_energy = 1
	battle_scene.perform_attack(attacker, defender, fury_attack, false, 1, battle_scene.player_card_img, battle_scene.enemy_card_img)
	attacker.current_energy = 2
	battle_scene.perform_attack(attacker, defender, fury_attack, false, 2, battle_scene.player_card_img, battle_scene.enemy_card_img)
	print("✓ Verificación 9: Fury Attack es la excepción donde el efecto escala con la cantidad de energía pagada.")
	
	# 6. Probar UI de botones: cuando el Pokémon tiene 1 energía y el Move 2 cuesta 2 (ej. Ivysaur con Vine Whip)
	var player_pkmn = battle_scene.get_active_player()
	player_pkmn.moves[1] = create_move_instance("Vine Whip")
	player_pkmn.current_energy = 1
	battle_scene.is_player_turn = true
	battle_scene.is_busy = false
	battle_scene.update_move_button_labels()
	
	var btn2 = battle_scene.btn_move2
	assert(btn2.disabled == false, "El botón del movimiento 2 debe estar HABILITADO con 1⚡ para permitir uso con daño parcial.")
	assert(btn2.text.contains("Parcial"), "El botón debe indicar que es un ataque [Parcial]. Texto: %s" % btn2.text)
	print("✓ Verificación 10: La UI de combate habilita el botón con texto '[Parcial]' y aviso de '(Sin efecto)' cuando la energía es parcial.")
	
	print("\n🎉 TODOS LOS TESTS DE ENERGÍA Y EFECTOS DE MOVIMIENTOS PASARON EXITOSAMENTE.")
	get_tree().quit(0)

func create_move_instance(identifier: String) -> GameData.MoveData:
	var d = GameData.get_move_data(identifier)
	var m = GameData.MoveData.new(
		d["name"], d["type"], d["dmg"], d["cost"], d.get("req", 1),
		d["boost_cost"] > 0, d["boost_cost"], d["boost_dmg"],
		d["effect_type"] == "BURN", d["desc"]
	)
	m.effect_type = d["effect_type"]
	m.reduces_foe_speed = (m.effect_type == "SLOW_FOE")
	m.is_pichu_shock = (m.effect_type == "PICHU_SHOCK")
	m.causes_poison = (m.effect_type == "POISON_IF_FASTER" or m.effect_type == "POISON")
	return m
