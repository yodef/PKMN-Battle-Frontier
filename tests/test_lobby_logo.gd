extends Node

func _ready() -> void:
	var menu_packed = load("res://scenes/main_menu.tscn")
	var menu = menu_packed.instantiate()
	add_child(menu)
	
	print("MainMenu instantiated successfully.")
	menu._on_login_play_pressed()
	
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.3).timeout
	
	var v_tex = get_viewport().get_texture()
	if v_tex:
		var img = v_tex.get_image()
		if img:
			img.save_png("C:/Users/rafag/.gemini/antigravity/brain/dca5182f-4733-4c52-8dfc-ccfff3b26dd9/lobby_redesign_screenshot.png")
			print("Saved lobby_redesign_screenshot.png successfully!")
		else:
			print("Image is null from get_image()")
	else:
		print("Viewport texture is null")
		
	get_tree().quit(0)
