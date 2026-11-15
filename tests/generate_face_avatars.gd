extends Node

func _ready() -> void:
	print("--- GENERATING HIGH-QUALITY FACE AVATARS ---")
	
	var avatar_configs = {
		"leaf": {
			"source_path": "C:/Users/rafag/.gemini/antigravity/brain/dca5182f-4733-4c52-8dfc-ccfff3b26dd9/leaf_transparent.png",
			"crop_rect": Rect2i(8, 0, 48, 48),
			"bg_color": Color(0.12, 0.28, 0.22, 0.95),
			"border_color": Color(0.35, 0.85, 0.55)
		},
		"red": {
			"source_path": "C:/Users/rafag/.gemini/antigravity/brain/dca5182f-4733-4c52-8dfc-ccfff3b26dd9/red_transparent.png",
			"crop_rect": Rect2i(7, 0, 48, 48),
			"bg_color": Color(0.30, 0.12, 0.12, 0.95),
			"border_color": Color(0.95, 0.40, 0.35)
		},
		"pikachu": {
			"source_path": "res://assets/cards/025.png",
			"crop_rect": Rect2i(105, 35, 260, 260),
			"bg_color": Color(0.28, 0.24, 0.08, 0.95),
			"border_color": Color(1.0, 0.85, 0.25)
		},
		"charizard": {
			"source_path": "res://assets/cards/006.png",
			"crop_rect": Rect2i(110, 68, 220, 220),
			"bg_color": Color(0.32, 0.16, 0.08, 0.95),
			"border_color": Color(1.0, 0.55, 0.20)
		},
		"gengar": {
			"source_path": "res://assets/cards/094.png",
			"crop_rect": Rect2i(110, 50, 260, 260),
			"bg_color": Color(0.22, 0.10, 0.28, 0.95),
			"border_color": Color(0.75, 0.45, 0.95)
		},
		"mewtwo": {
			"source_path": "res://assets/cards/150.png",
			"crop_rect": Rect2i(135, 22, 220, 220),
			"bg_color": Color(0.18, 0.10, 0.30, 0.95),
			"border_color": Color(0.85, 0.55, 1.0)
		},
		"lucario": {
			"source_path": "res://assets/cards/448.png",
			"crop_rect": Rect2i(135, 22, 220, 220),
			"bg_color": Color(0.10, 0.22, 0.32, 0.95),
			"border_color": Color(0.35, 0.75, 1.0)
		},
		"eevee": {
			"source_path": "res://assets/cards/133.png",
			"crop_rect": Rect2i(115, 22, 240, 240),
			"bg_color": Color(0.26, 0.20, 0.12, 0.95),
			"border_color": Color(0.90, 0.75, 0.45)
		}
	}
	
	var out_size = 160
	for aid in avatar_configs:
		var cfg = avatar_configs[aid]
		var s_path = cfg["source_path"]
		var abs_path = ProjectSettings.globalize_path(s_path) if s_path.begins_with("res://") else s_path
		var src_img = Image.load_from_file(abs_path)
		if not src_img:
			print("FAILED TO LOAD: ", abs_path)
			continue
		src_img.convert(Image.FORMAT_RGBA8)
			
		var rect: Rect2i = cfg["crop_rect"]
		# Make sure crop is within bounds
		rect.position.x = clampi(rect.position.x, 0, src_img.get_width() - 1)
		rect.position.y = clampi(rect.position.y, 0, src_img.get_height() - 1)
		rect.size.x = clampi(rect.size.x, 1, src_img.get_width() - rect.position.x)
		rect.size.y = clampi(rect.size.y, 1, src_img.get_height() - rect.position.y)
		
		var cropped = Image.create(rect.size.x, rect.size.y, false, Image.FORMAT_RGBA8)
		cropped.blit_rect(src_img, rect, Vector2i(0, 0))
		
		# Now scale smoothly to 144x144 (leaving an 8px border margin in the 160x160 canvas)
		var inner_size = 144
		if aid in ["leaf", "red"]:
			# Pixel art trainers look crisp with nearest neighbor
			cropped.resize(inner_size, inner_size, Image.INTERPOLATE_NEAREST)
		else:
			# High-res Pokemon artwork scales smoothly with lanczos/bilinear
			cropped.resize(inner_size, inner_size, Image.INTERPOLATE_LANCZOS)
			
		# Create final 160x160 framed avatar image
		var final_img = Image.create(out_size, out_size, false, Image.FORMAT_RGBA8)
		
		# Draw rounded / circular styled backdrop
		var bg_col: Color = cfg["bg_color"]
		var border_col: Color = cfg["border_color"]
		var center_f = Vector2(out_size / 2.0, out_size / 2.0)
		var radius = (out_size / 2.0) - 2.0
		var radius_sq = radius * radius
		var inner_radius_sq = (radius - 4.0) * (radius - 4.0)
		
		for y in range(out_size):
			for x in range(out_size):
				var d_sq = (Vector2(x + 0.5, y + 0.5) - center_f).length_squared()
				if d_sq <= radius_sq:
					if d_sq > inner_radius_sq:
						# Anti-aliased border ring
						var t = clampf((sqrt(d_sq) - (radius - 4.0)) / 4.0, 0.0, 1.0)
						var c = border_col.lerp(border_col, t)
						final_img.set_pixel(x, y, c)
					else:
						# Gradient center
						var dist_ratio = sqrt(d_sq) / radius
						var grad_col = bg_col.lightened(0.25 * (1.0 - dist_ratio))
						final_img.set_pixel(x, y, grad_col)
						
		# Blit the face sprite centered inside
		var offset_x = (out_size - inner_size) / 2
		var offset_y = (out_size - inner_size) / 2
		for y in range(inner_size):
			for x in range(inner_size):
				var sp_col = cropped.get_pixel(x, y)
				if sp_col.a > 0.01:
					var dest_x = offset_x + x
					var dest_y = offset_y + y
					var d_sq = (Vector2(dest_x + 0.5, dest_y + 0.5) - center_f).length_squared()
					if d_sq <= inner_radius_sq:
						var bg_px = final_img.get_pixel(dest_x, dest_y)
						var blended = bg_px.lerp(sp_col, sp_col.a)
						blended.a = 1.0
						final_img.set_pixel(dest_x, dest_y, blended)
						
		var out_path = "res://assets/ui/avatars/avatar_%s.png" % aid
		var dest_file = ProjectSettings.globalize_path(out_path)
		var err = final_img.save_png(dest_file)
		print("Saved avatar: ", aid, " -> ", dest_file, " (result: ", err, ")")
		
	print("=== ALL AVATARS GENERATED SUCCESSFULLY ===")
	get_tree().quit(0)
