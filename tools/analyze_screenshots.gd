extends SceneTree

func _init() -> void:
	var user_img = Image.load_from_file("C:/Users/rafag/.gemini/antigravity/brain/dca5182f-4733-4c52-8dfc-ccfff3b26dd9/.user_uploaded/media_1793391895031_e42d8931.png")
	var dbg_img = Image.load_from_file("C:/Users/rafag/.gemini/antigravity/brain/dca5182f-4733-4c52-8dfc-ccfff3b26dd9/debug_tournament_screen.png")
	
	print("--- User Image analysis ---")
	print("User width: ", user_img.get_width(), " height: ", user_img.get_height())
	
	# Look at the user's image in the attachment:
	# At the top: Title "🏆 TOURNAMENT TEAM"
	# Subtitle: "ose 1 to 3 BASIC Pokémon (Legendaries banned).  icons show evolutions ready in your collec"
	# Slots: "1st LEADER (CAMPAIGN): [Empty]"
	# Sort: "Sort by:  ID  Dex No.  A - Z  Evo"
	# Cards: Bulbasaur (cut on left!), Charmander, Squirtle, Nidoran F (cut on right!)
	
	print("--- Dbg Image analysis ---")
	print("Dbg width: ", dbg_img.get_width(), " height: ", dbg_img.get_height())
	
	quit()
