@tool
extends SceneTree

func _init() -> void:
	print("--- CLEAN CROP WEB, SLEEP, AND PARALYZE ---")
	var out_dir = "D:/Games/Pokemon Battle Frontier/APP/pkmn-battle-frontier/assets/fx/status/"

	var path2 = "D:/Games/Pokemon Battle Frontier/ART/animationtextures2.png"
	var img2 = Image.load_from_file(path2)
	
	# 1. TRAPPED (Spider Web)
	# Web is white strands centered at (407, 14, 55, 55)
	var web_rect = Rect2i(407, 14, 55, 55)
	var web_out = Image.create(55, 55, false, Image.FORMAT_RGBA8)
	for y in range(55):
		for x in range(55):
			var c = img2.get_pixel(407 + x, 14 + y)
			# Web lines are whitish/light-gray (r > 0.78, g > 0.78, b > 0.78)
			if c.r > 0.76 and c.g > 0.76 and c.b > 0.76:
				web_out.set_pixel(x, y, Color(1, 1, 1, 0.9))
			else:
				web_out.set_pixel(x, y, Color(0, 0, 0, 0))
	web_out.save_png(out_dir + "trapped.png")
	print("Saved clean trapped.png")

	# 2. SLEEP (Zzz from sheet 1)
	var path1 = "D:/Games/Pokemon Battle Frontier/ART/animationtextures.png"
	var img1 = Image.load_from_file(path1)

	# Small z: (361, 57, 8, 10)
	var z_small = Image.create(8, 10, false, Image.FORMAT_RGBA8)
	for y in range(10):
		for x in range(8):
			var c = img1.get_pixel(361 + x, 57 + y)
			# Orange/yellow letter pixels
			if c.r > 0.75 and c.g > 0.2 and c.b < 0.3:
				z_small.set_pixel(x, y, c)
			else:
				z_small.set_pixel(x, y, Color(0, 0, 0, 0))
	z_small.save_png(out_dir + "sleep_0.png")
	print("Saved clean sleep_0.png")

	# Big Z: (358, 72, 13, 12)
	var z_big = Image.create(13, 12, false, Image.FORMAT_RGBA8)
	for y in range(12):
		for x in range(13):
			var c = img1.get_pixel(358 + x, 72 + y)
			if c.r > 0.75 and c.g > 0.2 and c.b < 0.3:
				z_big.set_pixel(x, y, c)
			else:
				z_big.set_pixel(x, y, Color(0, 0, 0, 0))
	z_big.save_png(out_dir + "sleep_1.png")
	print("Saved clean sleep_1.png")

	# Both ZZ together: (358, 57, 13, 27)
	var z_both = Image.create(13, 27, false, Image.FORMAT_RGBA8)
	for y in range(27):
		for x in range(13):
			var c = img1.get_pixel(358 + x, 57 + y)
			if c.r > 0.75 and c.g > 0.2 and c.b < 0.3:
				z_both.set_pixel(x, y, c)
			else:
				z_both.set_pixel(x, y, Color(0, 0, 0, 0))
	z_both.save_png(out_dir + "sleep_2.png")
	print("Saved clean sleep_2.png")

	# 3. PARALYZE (Electric Sparks in sheet 1 at x=18..44)
	var spark_slices = [
		Rect2i(18, 122, 26, 18),
		Rect2i(18, 142, 26, 20),
		Rect2i(18, 163, 26, 18),
		Rect2i(18, 183, 26, 18)
	]
	for i in range(spark_slices.size()):
		var rect = spark_slices[i]
		var sp = Image.create(rect.size.x, rect.size.y, false, Image.FORMAT_RGBA8)
		for y in range(rect.size.y):
			for x in range(rect.size.x):
				var c = img1.get_pixel(rect.position.x + x, rect.position.y + y)
				# Spark is yellow/orange/red (c.r > 0.6 and (c.g > 0.2 or c.b < 0.4))
				if c.r > 0.55 and c.b < 0.45:
					sp.set_pixel(x, y, c)
				else:
					sp.set_pixel(x, y, Color(0, 0, 0, 0))
		sp.save_png(out_dir + "paralyze_%d.png" % i)
		print("Saved clean paralyze_%d.png" % i)

	quit(0)
