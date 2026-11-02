extends SceneTree

func _init() -> void:
	var user_img = Image.load_from_file("C:/Users/rafag/.gemini/antigravity/brain/dca5182f-4733-4c52-8dfc-ccfff3b26dd9/.user_uploaded/media_1793391895031_e42d8931.png")
	
	# Let's inspect the row where the cards are (e.g. Y = 300)
	# Find where the card borders are:
	print("User image width = ", user_img.get_width(), " height = ", user_img.get_height())
	
	# Let's find non-dark pixels in row Y = 300 across X
	var dark = Color(0.06, 0.08, 0.12, 1.0)
	var first_x = -1
	var last_x = -1
	for x in range(user_img.get_width()):
		var c = user_img.get_pixel(x, 300)
		if c.v > 0.15: # Not background
			if first_x == -1:
				first_x = x
			last_x = x
	print("Row 300 content bounds: first_x = ", first_x, " last_x = ", last_x)
	
	# Let's check the title row Y = 40
	first_x = -1
	last_x = -1
	for x in range(user_img.get_width()):
		var c = user_img.get_pixel(x, 40)
		if c.v > 0.2:
			if first_x == -1:
				first_x = x
			last_x = x
	print("Title row 40 content bounds: first_x = ", first_x, " last_x = ", last_x)
	
	# Let's check subtitle row Y = 80
	first_x = -1
	last_x = -1
	for x in range(user_img.get_width()):
		var c = user_img.get_pixel(x, 78)
		if c.v > 0.2:
			if first_x == -1:
				first_x = x
			last_x = x
	print("Subtitle row 78 content bounds: first_x = ", first_x, " last_x = ", last_x)

	quit()
