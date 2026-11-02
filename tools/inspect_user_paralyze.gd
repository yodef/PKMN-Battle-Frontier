@tool
extends SceneTree

func _init() -> void:
	var path = "C:/Users/rafag/.gemini/antigravity/brain/dca5182f-4733-4c52-8dfc-ccfff3b26dd9/.user_uploaded/media_1793593399959_260b5ec5.png"
	var img = Image.load_from_file(path)
	var w = img.get_width()
	var h = img.get_height()
	
	# Sample colors across the image
	var green_samples = [
		img.get_pixel(0, 0),
		img.get_pixel(w - 1, 0),
		img.get_pixel(0, h - 1),
		img.get_pixel(w - 1, h - 1),
		img.get_pixel(2, 2)
	]
	print("Green samples: ", green_samples)
	
	# Find unique colors that are NOT green
	var colors_hist = {}
	var bg = img.get_pixel(0, 0)
	for y in range(h):
		for x in range(w):
			var c = img.get_pixel(x, y)
			var dist = sqrt(pow(c.r - bg.r, 2) + pow(c.g - bg.g, 2) + pow(c.b - bg.b, 2))
			if dist > 0.1:
				var hex = c.to_html(false)
				colors_hist[hex] = colors_hist.get(hex, 0) + 1
				
	print("Non-green color count: ", colors_hist.size())
	# print top 10 colors
	var keys = colors_hist.keys()
	keys.sort_custom(func(a, b): return colors_hist[a] > colors_hist[b])
	for k in keys.slice(0, min(15, keys.size())):
		print("Color #", k, " count: ", colors_hist[k])
		
	quit(0)
