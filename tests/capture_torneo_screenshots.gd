extends Node

func _ready() -> void:
	# 1. Menú Principal - Modal de Campaña y Tienda con Revive y Poción
	var menu_packed = load("res://scenes/main_menu.tscn")
	var menu = menu_packed.instantiate()
	add_child(menu)
	
	GameData.is_campaign_mode = true
	GameData.campaign_match_number = 2
	GameData.campaign_gold = 12
	GameData.campaign_inventory = {"potion": 2, "revive": 1}
	
	# Equipo de prueba en campaña: Bulbasaur (KO 0/10), Charmander (Herido 4/10), Squirtle (Lleno 10/10)
	GameData.campaign_player_team_state = [
		{
			"id": 0, "name": "Bulbasaur", "stage": "Basic", "type": "GRASS",
			"current_hp": 0, "max_hp": 10, "texture_path": "res://assets/cards/001.png"
		},
		{
			"id": 1, "name": "Charmander", "stage": "Basic", "type": "FIRE",
			"current_hp": 4, "max_hp": 10, "texture_path": "res://assets/cards/004.png"
		},
		{
			"id": 2, "name": "Squirtle", "stage": "Basic", "type": "WATER",
			"current_hp": 10, "max_hp": 10, "texture_path": "res://assets/cards/007.png"
		}
	]
	
	menu.update_campaign_ui()
	menu.campaign_modal.visible = true
	
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.1).timeout
	
	# Screenshot 1: Campaña / Tienda con Revive y Poción y botones contextuales
	var img1 = get_viewport().get_texture().get_image()
	img1.save_png("C:/Users/rafag/.gemini/antigravity/brain/dca5182f-4733-4c52-8dfc-ccfff3b26dd9/campaign_shop_revive_screenshot.png")
	
	# 2. Selección de Equipo para el Torneo (Solo Basic)
	menu.campaign_modal.visible = false
	menu.open_team_select_for_campaign()
	
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.1).timeout
	
	# Screenshot 2: Selección de equipo del torneo filtrado a sólo fase Basic
	var img2 = get_viewport().get_texture().get_image()
	img2.save_png("C:/Users/rafag/.gemini/antigravity/brain/dca5182f-4733-4c52-8dfc-ccfff3b26dd9/torneo_only_basic_select_screenshot.png")
	
	# 3. Combate - Historial de combate pausado
	menu.queue_free()
	
	var battle_packed = load("res://scenes/battle.tscn")
	var battle = battle_packed.instantiate()
	add_child(battle)
	
	GameData.is_campaign_mode = false
	GameData.player_team_ids = [0]
	GameData.enemy_team_ids = [1]
	battle.start_new_game()
	
	battle.combat_history.clear()
	battle.log_action("¡Bulbasaur usó [color=green]Razor Leaf[/color]! Causó 4 DMG. [color=yellow]¡Es súper eficaz! (+2 DMG)[/color]")
	battle.log_action("🔥 [color=orange]¡Charmander sufre 1 DMG por Quemadura residual![/color]")
	
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.1).timeout
	
	# Screenshot 3: Combate con historial narrativo multilínea
	var img3 = get_viewport().get_texture().get_image()
	img3.save_png("C:/Users/rafag/.gemini/antigravity/brain/dca5182f-4733-4c52-8dfc-ccfff3b26dd9/battle_multiline_log_screenshot.png")
	
	print("All screenshots generated successfully!")
	get_tree().quit(0)
