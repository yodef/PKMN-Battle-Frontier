extends SceneTree

func _init() -> void:
	var user_img = Image.load_from_file("C:/Users/rafag/.gemini/antigravity/brain/dca5182f-4733-4c52-8dfc-ccfff3b26dd9/.user_uploaded/media_1793391895031_e42d8931.png")
	var debug_img = Image.load_from_file("C:/Users/rafag/.gemini/antigravity/brain/dca5182f-4733-4c52-8dfc-ccfff3b26dd9/debug_tournament_screen.png")
	
	print("User image size: ", user_img.get_size())
	print("Debug image size: ", debug_img.get_size())
	
	quit()
