extends Node

func _ready() -> void:
	print("\n--- INICIANDO TEST DE ILUMINACIÓN ELEMENTAL SEGÚN TIPO DE ATAQUE ---")
	
	# 1. Comprobar que GameData tiene registrados colores para todos los tipos principales
	var check_types = ["FIRE", "WATER", "GRASS", "ELECTRIC", "THUNDER", "NORMAL", "DARK", "POISON", "PSYCHIC", "FIGHTING", "GROUND", "ROCK", "ICE", "BUG", "GHOST", "DRAGON", "STEEL", "FAIRY", "FLYING"]
	for t in check_types:
		var c = GameData.get_type_hit_color(t)
		assert(c != null, "Color para tipo %s no debe ser nulo" % t)
		assert(c.a > 0, "Color alfa debe ser mayor a 0 para %s" % t)
	print("✓ Verificación 1: Todos los tipos elementales cuentan con color de iluminación configurado.")

	# 2. Instanciar la escena de combate
	var battle_packed = load("res://scenes/battle.tscn")
	var battle = battle_packed.instantiate()
	add_child(battle)
	
	# Configurar equipos: Jugador = Bulbasaur (id 0), Rival = Charmander (id 1)
	GameData.is_campaign_mode = false
	GameData.player_team_ids = [0] # Bulbasaur
	GameData.enemy_team_ids = [1] # Charmander
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Verificar referencias a los sprites
	assert(battle.player_card_img != null, "player_card_img debe existir")
	assert(battle.enemy_card_img != null, "enemy_card_img debe existir")
	assert(battle.player_card_img.modulate == Color.WHITE, "Sprite del jugador debe iniciar en blanco (sin iluminar)")
	assert(battle.enemy_card_img.modulate == Color.WHITE, "Sprite del rival debe iniciar en blanco (sin iluminar)")
	print("✓ Verificación 2: Escena de combate cargada y sprites inicializados en modulate blanco.")
	
	# 3. Test de activación de iluminación en daño directo
	# Simular impacto de ataque FUEGO (Ember) sobre Bulbasaur
	var fire_color = GameData.get_type_hit_color("FIRE")
	battle.play_damage_hit(battle.player_card_img, "FIRE")
	
	# Esperar 1 frame para que inicie el tween de color
	await get_tree().process_frame
	await get_tree().create_timer(0.04).timeout
	
	var mod_fire = battle.player_card_img.modulate
	assert(mod_fire.r > 1.2, "El canal rojo debe estar intensificado por el fuego: %f" % mod_fire.r)
	print("✓ Verificación 3: Sprite del defensor se ilumina con el color del tipo FUEGO al recibir daño (%s)." % str(mod_fire))
	
	# Esperar a que concluya la animación y vuelva a blanco
	await get_tree().create_timer(0.25).timeout
	assert(battle.player_card_img.modulate.is_equal_approx(Color.WHITE), "Sprite debe regresar suavemente a modulate Color.WHITE tras el impacto.")
	print("✓ Verificación 4: Sprite restaura su modulación normal (Color.WHITE) tras finalizar la animación.")

	# 4. Test con tipo AGUA (Bubble) sobre Charmander
	var water_color = GameData.get_type_hit_color("WATER")
	battle.play_damage_hit(battle.enemy_card_img, "WATER")
	await get_tree().process_frame
	await get_tree().create_timer(0.04).timeout
	
	var mod_water = battle.enemy_card_img.modulate
	assert(mod_water.b > 1.2, "El canal azul debe estar intensificado por el agua: %f" % mod_water.b)
	print("✓ Verificación 5: Sprite del rival se ilumina con el color del tipo AGUA al recibir daño (%s)." % str(mod_water))
	
	await get_tree().create_timer(0.25).timeout
	assert(battle.enemy_card_img.modulate.is_equal_approx(Color.WHITE), "Sprite rival restaura modulate Color.WHITE.")

	# 5. Test en perform_attack real
	var p = battle.get_active_player() # Bulbasaur
	var e = battle.get_active_enemy() # Charmander
	var move_grass = p.moves[1] # Razor Leaf (GRASS)
	
	var enemy_hp_before = e.current_hp
	battle.perform_attack(p, e, move_grass, false, move_grass.cost, battle.player_card_img, battle.enemy_card_img)
	
	# Comprobar daño aplicado
	assert(e.current_hp < enemy_hp_before, "Charmander debió recibir daño de Razor Leaf.")
	
	# Comprobar que enemy_card_img se iluminó en VERDE (GRASS)
	await get_tree().process_frame
	await get_tree().create_timer(0.04).timeout
	var mod_grass = battle.enemy_card_img.modulate
	assert(mod_grass.g > 1.2, "Canal verde debe estar intensificado por Razor Leaf (GRASS): %f" % mod_grass.g)
	print("✓ Verificación 6: En combate real perform_attack() ilumina al objetivo con el tipo del ataque ejecutado (GRASS).")

	await get_tree().create_timer(0.3).timeout
	print("\n🎉 TODOS LOS TESTS DE ILUMINACIÓN ELEMENTAL PASARON CON ÉXITO.")
	get_tree().quit(0)
