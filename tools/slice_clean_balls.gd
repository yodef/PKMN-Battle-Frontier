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
	
	var C_W = 26
	var C_H = 26
	
	# 1. Closed Ball: x=6..25 (w=20), y=172..191 (h=20)
	var img_closed = Image.create(C_W, C_H, false, Image.FORMAT_RGBA8)
	var b1_off_x = (C_W - 20) / 2 # 3
	var b1_off_y = (C_H - 20) / 2 # 3
	for y in range(20):
		for x in range(20):
			var c = img.get_pixel(6 + x, 172 + y)
			if is_green.call(c):
				img_closed.set_pixel(b1_off_x + x, b1_off_y + y, Color(0, 0, 0, 0))
			else:
				img_closed.set_pixel(b1_off_x + x, b1_off_y + y, c)
				
	img_closed.save_png("D:/Games/Pokemon Battle Frontier/APP/pkmn-battle-frontier/assets/ui/menu_pokeball.png")
	img_closed.save_png("C:/Users/rafag/.gemini/antigravity/brain/dca5182f-4733-4c52-8dfc-ccfff3b26dd9/menu_pokeball_clean.png")
	
	# 2. Open Ball: x=31..52 (w=22), y=170..193 (h=24)
	var img_open = Image.create(C_W, C_H, false, Image.FORMAT_RGBA8)
	var b2_off_x = (C_W - 22) / 2 # 2
	var b2_off_y = (C_H - 24) / 2 # 1
	for y in range(24):
		for x in range(22):
			var c = img.get_pixel(31 + x, 170 + y)
			if is_green.call(c):
				img_open.set_pixel(b2_off_x + x, b2_off_y + y, Color(0, 0, 0, 0))
			else:
				img_open.set_pixel(b2_off_x + x, b2_off_y + y, c)
				
	img_open.save_png("D:/Games/Pokemon Battle Frontier/APP/pkmn-battle-frontier/assets/ui/menu_pokeball_active.png")
	img_open.save_png("C:/Users/rafag/.gemini/antigravity/brain/dca5182f-4733-4c52-8dfc-ccfff3b26dd9/menu_pokeball_active_clean.png")
	
	print("Perfect Pokeballs extracted and saved!")
	quit(0)
