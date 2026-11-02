extends SceneTree

func _init() -> void:
	var card_path = "D:/Games/Pokemon Battle Frontier/APP/pkmn-battle-frontier/assets/cards/125.png"
	var card_src = Image.load_from_file(card_path)
	if not card_src:
		print("Failed to load card image: ", card_path)
		quit(1)
		return
	
	# The card in battle is sized 130 x 180
	var card_img = Image.create(130, 180, false, Image.FORMAT_RGBA8)
	card_img.copy_from(card_src)
	card_img.resize(130, 180, Image.INTERPOLATE_BILINEAR)
	
	# We will create a side-by-side composite comparison:
	# [Idle (No Anim)] | [Frame 0] | [Frame 1] | [Frame 2] | [Frame 3]
	# Total width: 5 * 140 + 20 = 720, height: 210
	var total_w = 5 * 140 + 20
	var total_h = 220
	var canvas = Image.create(total_w, total_h, false, Image.FORMAT_RGBA8)
	canvas.fill(Color(0.09, 0.11, 0.15, 1.0))
	
	var frame_paths = [
		"", # Idle: no overlay
		"D:/Games/Pokemon Battle Frontier/APP/pkmn-battle-frontier/assets/fx/status/paralyze_0.png",
		"D:/Games/Pokemon Battle Frontier/APP/pkmn-battle-frontier/assets/fx/status/paralyze_1.png",
		"D:/Games/Pokemon Battle Frontier/APP/pkmn-battle-frontier/assets/fx/status/paralyze_2.png",
		"D:/Games/Pokemon Battle Frontier/APP/pkmn-battle-frontier/assets/fx/status/paralyze_3.png"
	]
	
	for col in range(5):
		var start_x = 10 + col * 140
		var start_y = 20
		
		# Paste base card
		for cy in range(180):
			for cx in range(130):
				var pixel = card_img.get_pixel(cx, cy)
				canvas.set_pixel(start_x + cx, start_y + cy, pixel)
		
		# If it's one of the active frames, overlay the 72x52 scaled paralyze sprite at (29, 56)
		var f_path = frame_paths[col]
		if f_path != "":
			var fx_src = Image.load_from_file(f_path)
			if fx_src:
				var fx_scaled = Image.create(72, 52, false, Image.FORMAT_RGBA8)
				fx_scaled.copy_from(fx_src)
				fx_scaled.resize(72, 52, Image.INTERPOLATE_NEAREST)
				
				# Position at (29, 56)
				var ox = 29
				var oy = 56
				for fy in range(52):
					for fx in range(72):
						var p_fx = fx_scaled.get_pixel(fx, fy)
						if p_fx.a > 0.05:
							var bg_p = canvas.get_pixel(start_x + ox + fx, start_y + oy + fy)
							var blended = bg_p.blend(p_fx)
							canvas.set_pixel(start_x + ox + fx, start_y + oy + fy, blended)
	
	var out_path = "C:/Users/rafag/.gemini/antigravity/brain/dca5182f-4733-4c52-8dfc-ccfff3b26dd9/paralyze_visual_comparison.png"
	canvas.save_png(out_path)
	print("Saved composite visualization to: ", out_path)
	quit(0)
