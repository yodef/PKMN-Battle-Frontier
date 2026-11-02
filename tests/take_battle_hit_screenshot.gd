extends Node

func _ready() -> void:
	await get_tree().create_timer(0.2).timeout
	
	GameData.is_campaign_mode = false
	GameData.player_team_ids = [0] # Bulbasaur
	GameData.enemy_team_ids = [1] # Charmander
	
	var battle_scene = load("res://scenes/battle.tscn").instantiate()
	add_child(battle_scene)
	await get_tree().create_timer(0.3).timeout
	
	# 1. Simular ataque FUEGO (Ember) sobre Bulbasaur
	var e = battle_scene.get_active_enemy()
	var p = battle_scene.get_active_player()
	var move_ember = e.moves[1] # Ember (FIRE)
	
	battle_scene.perform_attack(e, p, move_ember, false, move_ember.cost, battle_scene.enemy_card_img, battle_scene.player_card_img)
	
	# Esperar 0.04s para capturar el pico del destello/iluminación fuego en el sprite
	await get_tree().create_timer(0.04).timeout
	var vp = get_viewport()
	var img_fire_hit = vp.get_texture().get_image()
	if img_fire_hit:
		img_fire_hit.save_png("C:/Users/rafag/.gemini/antigravity/brain/dca5182f-4733-4c52-8dfc-ccfff3b26dd9/battle_fire_hit_screenshot.png")
		
	# Esperar a que pase el ataque
	await get_tree().create_timer(0.5).timeout
	
	# 2. Simular ataque AGUA (Bubble) sobre Charmander
	battle_scene.play_damage_hit(battle_scene.enemy_card_img, "WATER")
	await get_tree().create_timer(0.04).timeout
	var img_water_hit = vp.get_texture().get_image()
	if img_water_hit:
		img_water_hit.save_png("C:/Users/rafag/.gemini/antigravity/brain/dca5182f-4733-4c52-8dfc-ccfff3b26dd9/battle_water_hit_screenshot.png")
		
	print("Capturas en combate guardadas con éxito.")
	get_tree().quit(0)
