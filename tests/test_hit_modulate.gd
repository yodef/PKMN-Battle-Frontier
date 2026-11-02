extends Node

func _ready() -> void:
	var vp = get_viewport()
	
	var bg = ColorRect.new()
	bg.color = Color("#0b0e14")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	
	var scroll = ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(scroll)
	
	var container = GridContainer.new()
	container.columns = 3
	container.add_theme_constant_override("h_separation", 16)
	container.add_theme_constant_override("v_separation", 20)
	scroll.add_child(container)
	
	var types_test = [
		{"type": "NORMAL", "color": Color(2.0, 2.0, 2.0)},
		{"type": "FIRE", "color": Color(2.4, 0.5, 0.15)},
		{"type": "WATER", "color": Color(0.2, 1.4, 2.5)},
		{"type": "GRASS", "color": Color(0.3, 2.3, 0.4)},
		{"type": "ELECTRIC", "color": Color(2.4, 2.2, 0.2)},
		{"type": "ICE", "color": Color(0.8, 2.2, 2.5)},
		{"type": "FIGHTING", "color": Color(2.3, 0.7, 0.2)},
		{"type": "POISON", "color": Color(1.9, 0.3, 2.1)},
		{"type": "GROUND", "color": Color(2.1, 1.3, 0.4)},
		{"type": "FLYING", "color": Color(0.6, 1.8, 2.5)},
		{"type": "PSYCHIC", "color": Color(2.4, 0.3, 1.5)},
		{"type": "BUG", "color": Color(1.3, 2.1, 0.4)},
		{"type": "ROCK", "color": Color(1.9, 1.4, 0.6)},
		{"type": "GHOST", "color": Color(1.3, 0.5, 2.2)},
		{"type": "DRAGON", "color": Color(1.4, 0.6, 2.4)},
		{"type": "STEEL", "color": Color(1.8, 2.0, 2.3)},
		{"type": "DARK", "color": Color(1.6, 0.4, 1.8)},
		{"type": "FAIRY", "color": Color(2.4, 1.0, 1.8)}
	]
	
	for item in types_test:
		var vbox = VBoxContainer.new()
		vbox.custom_minimum_size = Vector2(150, 140)
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		
		var lbl = Label.new()
		lbl.text = item["type"]
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 11)
		vbox.add_child(lbl)
		
		var tr = TextureRect.new()
		tr.texture = load("res://assets/cards/001.png")
		tr.custom_minimum_size = Vector2(100, 100)
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tr.modulate = item["color"]
		vbox.add_child(tr)
		
		container.add_child(vbox)
		
	await get_tree().create_timer(0.3).timeout
	var img = vp.get_texture().get_image()
	if img:
		img.save_png("C:/Users/rafag/.gemini/antigravity/brain/dca5182f-4733-4c52-8dfc-ccfff3b26dd9/all_type_hit_colors_preview.png")
	print("All type hit colors saved.")
	get_tree().quit(0)
