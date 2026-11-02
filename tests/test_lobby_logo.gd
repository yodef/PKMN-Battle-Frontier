extends Node

func _ready() -> void:
	var menu_packed = load("res://scenes/main_menu.tscn")
	var menu = menu_packed.instantiate()
	add_child(menu)
	
	menu._on_login_play_pressed()
	
	var header = menu.get_node("ContentContainer/HeaderContainer")
	var title_prefix = header.get_node_or_null("TitlePrefix")
	var title_main = header.get_node_or_null("TitleMain")
	if title_prefix:
		title_prefix.visible = false
	if title_main:
		title_main.visible = false
		
	var tex = load("res://assets/ui/logo_battle_frontier.png")
	print("Loaded texture: ", tex, " size: ", tex.get_size() if tex else "null")
	
	var logo_rect = TextureRect.new()
	logo_rect.name = "GameLogo"
	logo_rect.texture = tex
	logo_rect.custom_minimum_size = Vector2(0, 230)
	logo_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(logo_rect)
	header.move_child(logo_rect, 0)
	
	var content = menu.get_node("ContentContainer")
	content.add_theme_constant_override("separation", 10)
	
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.3).timeout
	
	var v_tex = get_viewport().get_texture()
	if v_tex:
		var img = v_tex.get_image()
		if img:
			img.save_png("C:/Users/rafag/.gemini/antigravity/brain/dca5182f-4733-4c52-8dfc-ccfff3b26dd9/test_lobby_with_logo.png")
			print("Saved test_lobby_with_logo.png successfully!")
		else:
			print("Image is null from get_image()")
	else:
		print("Viewport texture is null")
		
	get_tree().quit(0)
