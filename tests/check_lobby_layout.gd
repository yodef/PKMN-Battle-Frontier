extends Node

func _ready() -> void:
	var menu_packed = load("res://scenes/main_menu.tscn")
	var menu = menu_packed.instantiate()
	add_child(menu)
	
	menu._on_login_play_pressed()
	
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.2).timeout
	
	var img = get_viewport().get_texture().get_image()
	img.save_png("C:/Users/rafag/.gemini/antigravity/brain/dca5182f-4733-4c52-8dfc-ccfff3b26dd9/lobby_with_logo_final.png")
	print("Saved lobby screenshot to lobby_with_logo_final.png")
	
	var content = menu.get_node("ContentContainer")
	print("ContentContainer size: ", content.size, " pos: ", content.position)
	for child in content.get_children():
		print("Child [", child.name, "]: size=", child.size, " pos=", child.position, " min_size=", child.get_combined_minimum_size())
		if child.name == "HeaderContainer":
			for h_child in child.get_children():
				print("   HeaderChild [", h_child.name, "]: size=", h_child.size, " text=", h_child.text if "text" in h_child else "")
		elif child.name == "MenuButtons":
			for m_child in child.get_children():
				print("   MenuChild [", m_child.name, "]: size=", m_child.size)
				
	get_tree().quit(0)
