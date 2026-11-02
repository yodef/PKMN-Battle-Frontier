extends Node

func _ready() -> void:
	var battle_packed = load("res://scenes/battle.tscn")
	var battle = battle_packed.instantiate()
	add_child(battle)
	
	GameData.is_campaign_mode = false
	GameData.player_team_ids = [4] # Ivysaur (recover = 3)
	GameData.enemy_team_ids = [0]  # Bulbasaur
	battle.start_new_game()
	
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.1).timeout
	
	# Screenshot 1: Botón de recarga dinámico de Ivysaur (+3⚡)
	var img = get_viewport().get_texture().get_image()
	img.save_png("C:/Users/rafag/.gemini/antigravity/brain/dca5182f-4733-4c52-8dfc-ccfff3b26dd9/dynamic_recharge_button_screenshot.png")
	
	# Preparar modal de energía:
	# Ivysaur: Move 1 = Poison Powder, Move 2 = Vine Whip (Cost 2, Base 8 DMG)
	var p = battle.get_active_player()
	var e = battle.get_active_enemy()
	p.current_energy = 3
	e.current_hp = 3
	battle.update_ui()
	
	# Abrir modal de energía
	battle._on_move2_pressed()
	
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.1).timeout
	
	# Screenshot 2: Modal de selección opcional de energía con indicador de remate
	img = get_viewport().get_texture().get_image()
	img.save_png("C:/Users/rafag/.gemini/antigravity/brain/dca5182f-4733-4c52-8dfc-ccfff3b26dd9/energy_select_modal_screenshot.png")
	
	print("Screenshots captured successfully!")
	get_tree().quit(0)
