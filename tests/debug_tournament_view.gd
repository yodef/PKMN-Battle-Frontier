extends Node

func _ready() -> void:
	var menu_packed = load("res://scenes/main_menu.tscn")
	var menu = menu_packed.instantiate()
	add_child(menu)
	
	menu._on_login_play_pressed()
	menu.open_team_select_for_campaign()
	
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.2).timeout
	
	var img = get_viewport().get_texture().get_image()
	img.save_png("C:/Users/rafag/.gemini/antigravity/brain/dca5182f-4733-4c52-8dfc-ccfff3b26dd9/debug_tournament_screen.png")
	print("Saved debug screenshot to debug_tournament_screen.png")
	
	var modal = menu.team_select_modal
	var box = modal.get_node("Box")
	print("Modal size: ", modal.size, " pos: ", modal.position)
	print("Box size: ", box.size, " pos: ", box.position)
	for child in box.get_children():
		if child.visible:
			print("Child: ", child.name, " size: ", child.size, " pos: ", child.position)
	
	var scroll = box.get_node("ScrollContainer")
	var grid = scroll.get_node("GridMargin/GridCards")
	print("ScrollContainer size: ", scroll.size, " pos: ", scroll.position)
	print("GridCards size: ", grid.size, " pos: ", grid.position)
	for c in grid.get_children():
		print("Card item size: ", c.size, " pos: ", c.position)
		break
		
	get_tree().quit(0)
