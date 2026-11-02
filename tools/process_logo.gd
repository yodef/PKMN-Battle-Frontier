extends SceneTree

func _init() -> void:
	var src_path = "C:/Users/rafag/.gemini/antigravity/brain/dca5182f-4733-4c52-8dfc-ccfff3b26dd9/pokemon_battle_frontier_logo_1793414964377.jpg"
	var img = Image.load_from_file(src_path)
	if not img:
		print("Failed to load source image!")
		quit(1)
		return
		
	img.convert(Image.FORMAT_RGBA8)
	var w = img.get_width()
	var h = img.get_height()
	print("Source image loaded: %d x %d" % [w, h])
	
	# Flood fill / smooth transparency on black background
	# Because the logo has some dark parts inside the Pokéball band and outlines,
	# we can do a background flood-fill or edge-connected black removal,
	# OR check if dark parts are connected to the exterior border!
	
	# Let's do a flood-fill from the 4 corners of the image for pure exterior background!
	var visited = []
	for y in range(h):
		var row = []
		row.resize(w)
		row.fill(false)
		visited.append(row)
		
	var queue = []
	
	# Add boundary pixels to queue
	for x in range(w):
		queue.append(Vector2i(x, 0))
		queue.append(Vector2i(x, h - 1))
		visited[0][x] = true
		visited[h - 1][x] = true
	for y in range(h):
		queue.append(Vector2i(0, y))
		queue.append(Vector2i(w - 1, y))
		visited[y][0] = true
		visited[y][w - 1] = true
		
	# Flood fill to find all exterior background pixels
	var is_exterior = []
	for y in range(h):
		var row = []
		row.resize(w)
		row.fill(false)
		is_exterior.append(row)
		
	var head = 0
	while head < queue.size():
		var pt = queue[head]
		head += 1
		
		var px = pt.x
		var py = pt.y
		var col = img.get_pixel(px, py)
		var lum = max(col.r, max(col.g, col.b))
		
		# If it's dark background (lum < 0.18)
		if lum < 0.20:
			is_exterior[py][px] = true
			var neighbors = [
				Vector2i(px + 1, py),
				Vector2i(px - 1, py),
				Vector2i(px, py + 1),
				Vector2i(px, py - 1)
			]
			for n in neighbors:
				if n.x >= 0 and n.x < w and n.y >= 0 and n.y < h:
					if not visited[n.y][n.x]:
						visited[n.y][n.x] = true
						queue.append(n)
						
	# Apply alpha to exterior pixels with soft ramp
	var min_x = w
	var max_x = 0
	var min_y = h
	var max_y = 0
	
	for y in range(h):
		for x in range(w):
			var col = img.get_pixel(x, y)
			if is_exterior[y][x]:
				var lum = max(col.r, max(col.g, col.b))
				if lum < 0.05:
					img.set_pixel(x, y, Color(0, 0, 0, 0))
				else:
					# Smooth edge fade
					var alpha = clamp((lum - 0.05) / 0.15, 0.0, 1.0)
					img.set_pixel(x, y, Color(col.r, col.g, col.b, alpha))
					if alpha > 0.1:
						min_x = min(min_x, x)
						max_x = max(max_x, x)
						min_y = min(min_y, y)
						max_y = max(max_y, y)
			else:
				min_x = min(min_x, x)
				max_x = max(max_x, x)
				min_y = min(min_y, y)
				max_y = max(max_y, y)
				
	print("Content bounds: x=[%d, %d], y=[%d, %d]" % [min_x, max_x, min_y, max_y])
	
	# Crop tight with small padding
	var pad = 12
	min_x = max(0, min_x - pad)
	min_y = max(0, min_y - pad)
	max_x = min(w - 1, max_x + pad)
	max_y = min(h - 1, max_y + pad)
	
	var crop_rect = Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)
	var cropped = img.get_region(crop_rect)
	print("Cropped logo size: %d x %d" % [cropped.get_width(), cropped.get_height()])
	
	# Save to destination
	var dest_path = "D:/Games/Pokemon Battle Frontier/APP/pkmn-battle-frontier/assets/ui/logo_battle_frontier.png"
	cropped.save_png(dest_path)
	print("Saved to: ", dest_path)
	
	# Also save to artifact directory
	var art_path = "C:/Users/rafag/.gemini/antigravity/brain/dca5182f-4733-4c52-8dfc-ccfff3b26dd9/logo_battle_frontier.png"
	cropped.save_png(art_path)
	print("Saved to artifact: ", art_path)
	
	quit(0)
