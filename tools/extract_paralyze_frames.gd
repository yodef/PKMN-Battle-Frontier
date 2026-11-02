@tool
extends SceneTree

func _init() -> void:
	var src_path = "C:/Users/rafag/.gemini/antigravity/brain/dca5182f-4733-4c52-8dfc-ccfff3b26dd9/.user_uploaded/media_1793593399959_260b5ec5.png"
	var src = Image.load_from_file(src_path)
	if not src:
		print("Error loading source image!")
		quit(1)
		return
		
	var out_dir = "D:/Games/Pokemon Battle Frontier/APP/pkmn-battle-frontier/assets/fx/status/"
	var art_dir = "C:/Users/rafag/.gemini/antigravity/brain/dca5182f-4733-4c52-8dfc-ccfff3b26dd9/"
	
	# Chroma green is Color8(34, 177, 76, 255)
	# Frame vertical blocks:
	# Frame 0: y=6..19,  x=10..26 (center: x=18, y=12.5)
	# Frame 1: y=26..44, x=5..30  (center: x=17.5, y=35)
	# Frame 2: y=56..69, x=6..32  (center: x=19, y=62.5)
	# Frame 3: y=84..96, x=10..28 (center: x=19, y=90)
	
	var frame_defs = [
		{"rect": Rect2i(10, 6, 17, 14), "cx": 18.0, "cy": 12.5},
		{"rect": Rect2i(5, 26, 26, 19), "cx": 17.5, "cy": 35.0},
		{"rect": Rect2i(6, 56, 27, 14), "cx": 19.0, "cy": 62.5},
		{"rect": Rect2i(10, 84, 19, 13), "cx": 19.0, "cy": 90.0}
	]
	
	var target_w = 36
	var target_h = 26
	
	# Also build a side-by-side preview strip
	var strip = Image.create(target_w * 4, target_h, false, Image.FORMAT_RGBA8)
	
	for i in range(frame_defs.size()):
		var fdef = frame_defs[i]
		var f_rect: Rect2i = fdef["rect"]
		var frame_img = Image.create(target_w, target_h, false, Image.FORMAT_RGBA8)
		
		# Offset to center the bounding box in target_w, target_h
		var off_x = int(floor((target_w - f_rect.size.x) / 2.0))
		var off_y = int(floor((target_h - f_rect.size.y) / 2.0))
		
		for y in range(f_rect.size.y):
			for x in range(f_rect.size.x):
				var src_c = src.get_pixel(f_rect.position.x + x, f_rect.position.y + y)
				# Check if green chroma
				# Chroma green is r: ~0.133, g: ~0.694, b: ~0.298
				var is_green = (src_c.g > 0.55 and src_c.r < 0.25 and src_c.b < 0.40)
				if not is_green:
					frame_img.set_pixel(off_x + x, off_y + y, src_c)
					strip.set_pixel(i * target_w + off_x + x, off_y + y, src_c)
				else:
					frame_img.set_pixel(off_x + x, off_y + y, Color(0, 0, 0, 0))
					strip.set_pixel(i * target_w + off_x + x, off_y + y, Color(0, 0, 0, 0))
					
		var frame_path = out_dir + "paralyze_%d.png" % i
		frame_img.save_png(frame_path)
		print("Saved: ", frame_path, " size: ", frame_img.get_size())
		
	strip.save_png(art_dir + "new_paralyze_strip_preview.png")
	print("Saved preview strip to: ", art_dir + "new_paralyze_strip_preview.png")
	quit(0)
