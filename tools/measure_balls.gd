@tool
extends SceneTree

func _init() -> void:
	var path = "D:/Games/Pokemon Battle Frontier/Art/texturesmenu.png"
	var img = Image.load_from_file(path)
	if not img:
		quit(1)
		return
	
	var is_green = func(c: Color) -> bool:
		return is_equal_approx(c.r, 0.0) and abs(c.g - 0.502) < 0.05 and is_equal_approx(c.b, 0.0)
	
	# Ball 1 (Closed):
	var b1_min_x = 999; var b1_max_x = 0; var b1_min_y = 999; var b1_max_y = 0
	for y in range(168, 195):
		for x in range(4, 28):
			var c = img.get_pixel(x, y)
			if not is_green.call(c):
				b1_min_x = min(b1_min_x, x)
				b1_max_x = max(b1_max_x, x)
				b1_min_y = min(b1_min_y, y)
				b1_max_y = max(b1_max_y, y)
				
	print("Ball 1 (Closed): Rect=(%d, %d) to (%d, %d), size=%dx%d" % [
		b1_min_x, b1_min_y, b1_max_x, b1_max_y,
		b1_max_x - b1_min_x + 1, b1_max_y - b1_min_y + 1
	])
	
	# Ball 2 (Open):
	var b2_min_x = 999; var b2_max_x = 0; var b2_min_y = 999; var b2_max_y = 0
	for y in range(165, 198):
		for x in range(30, 58):
			var c = img.get_pixel(x, y)
			if not is_green.call(c):
				b2_min_x = min(b2_min_x, x)
				b2_max_x = max(b2_max_x, x)
				b2_min_y = min(b2_min_y, y)
				b2_max_y = max(b2_max_y, y)
				
	print("Ball 2 (Open): Rect=(%d, %d) to (%d, %d), size=%dx%d" % [
		b2_min_x, b2_min_y, b2_max_x, b2_max_y,
		b2_max_x - b2_min_x + 1, b2_max_y - b2_min_y + 1
	])
	
	quit(0)
