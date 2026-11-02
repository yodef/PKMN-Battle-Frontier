extends Node

func _ready() -> void:
	await get_tree().create_timer(0.3).timeout
	var main_scene = load("res://scenes/main_menu.tscn").instantiate()
	add_child(main_scene)
	await get_tree().create_timer(0.2).timeout
	
	# 1. Abrir Tienda con botón DEV
	main_scene._on_shop_pressed()
	await get_tree().create_timer(0.3).timeout
	var img_shop = get_viewport().get_texture().get_image()
	if img_shop:
		img_shop.save_png("C:/Users/rafag/.gemini/antigravity/brain/dca5182f-4733-4c52-8dfc-ccfff3b26dd9/shop_dev_button_screenshot.png")
	
	# Desbloquear todos
	main_scene._on_unlock_all_dev_pressed()
	await get_tree().create_timer(0.2).timeout
	var img_shop_unlocked = get_viewport().get_texture().get_image()
	if img_shop_unlocked:
		img_shop_unlocked.save_png("C:/Users/rafag/.gemini/antigravity/brain/dca5182f-4733-4c52-8dfc-ccfff3b26dd9/shop_all_unlocked_screenshot.png")
	
	# 2. Selector de equipo en Campaña
	main_scene.shop_modal.visible = false
	main_scene.open_team_select_for_campaign()
	await get_tree().create_timer(0.3).timeout
	var img_team = get_viewport().get_texture().get_image()
	if img_team:
		img_team.save_png("C:/Users/rafag/.gemini/antigravity/brain/dca5182f-4733-4c52-8dfc-ccfff3b26dd9/campaign_team_select_screenshot.png")
		
	# 3. Menú de Campaña con equipo confirmado
	main_scene.selected_player_ids.clear()
	main_scene.selected_player_ids.append(7)
	main_scene.selected_player_ids.append(9)
	main_scene.selected_player_ids.append(5)
	main_scene._on_start_battle_pressed()
	await get_tree().create_timer(0.3).timeout
	var img_camp = get_viewport().get_texture().get_image()
	if img_camp:
		img_camp.save_png("C:/Users/rafag/.gemini/antigravity/brain/dca5182f-4733-4c52-8dfc-ccfff3b26dd9/campaign_custom_team_screenshot.png")
		
	print("Capturas tomadas con éxito.")
	get_tree().quit(0)
