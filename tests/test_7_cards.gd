extends Node

func _ready() -> void:
	var menu_packed = load("res://scenes/main_menu.tscn")
	var menu = menu_packed.instantiate()
	add_child(menu)
	
	for p_id in GameData.pokemon_catalog.keys():
		var p = GameData.pokemon_catalog[p_id]
		var name = str(p.get("name", ""))
		if name in ["Bulbasaur", "Charmander", "Squirtle", "Nidoran♀", "Nidoran F", "Mankey", "Drowzee", "Pichu"]:
			GameData.unlock_pokemon(p_id)
			
	menu._on_login_play_pressed()
	menu.open_team_select_for_campaign()
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	var grid = menu.team_grid_cards
	print("Grid child count: ", grid.get_child_count())
	for c in grid.get_children():
		print("Card: min=", c.get_combined_minimum_size(), " size=", c.size, " pos=", c.position)
		for sub in c.get_children():
			print("   sub [", sub.name, "]: min=", sub.get_combined_minimum_size(), " size=", sub.size)
			
	var scroll = menu.team_select_modal.get_node("Box/ScrollContainer")
	print("ScrollContainer: min=", scroll.get_combined_minimum_size(), " size=", scroll.size)
	print("GridContainer: min=", grid.get_combined_minimum_size(), " size=", grid.size)
	print("Box rect: ", menu.team_select_modal.get_node("Box").get_rect())
	
	var img = get_viewport().get_texture().get_image()
	img.save_png("C:/Users/rafag/.gemini/antigravity/brain/dca5182f-4733-4c52-8dfc-ccfff3b26dd9/test_7_cards_screen.png")
	
	get_tree().quit(0)
