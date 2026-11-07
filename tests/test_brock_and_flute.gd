extends Node

func _ready():
	print("==================================================")
	print("🧪 TESTING BROCK'S TEAM & POKÉ FLUTE SHOP EXCLUSIVITY")
	print("==================================================")
	
	# 1. Test Onix resolution
	var onix_id = GameData.get_pokemon_id_by_name("Onix")
	var onyx_id = GameData.get_pokemon_id_by_name("Onyx")
	print("Onix ID: %d, Onyx ID: %d" % [onix_id, onyx_id])
	assert(onix_id == 99, "Onix must resolve to ID 99")
	assert(onyx_id == 99, "Onyx must also resolve to ID 99")
	print("✓ Onix resolves correctly via both spellings.")
	
	# 2. Test Brock's stage in Episode I
	var ep1_stage4 = GameData.get_adventure_stage_info(1, 4)
	print("Stage 4 Trainer: ", ep1_stage4.get("trainer_name"))
	var team_names = ep1_stage4.get("team_pokemon_names", [])
	print("Stage 4 Team Names: ", team_names)
	assert("Geodude" in team_names, "Geodude must be in Brock's team")
	assert("Onix" in team_names, "Onix must be in Brock's team")
	
	var rival_team = GameData.get_adventure_rival_team(1, 4)
	print("Brock's Resolved Team IDs: ", rival_team)
	assert(rival_team.size() == 2, "Brock must have exactly 2 Pokémon in his team, got %d" % rival_team.size())
	assert(rival_team[0] == 77, "First Pokémon should be Geodude (Card ID 77)")
	assert(rival_team[1] == 99, "Second Pokémon should be Onix (Card ID 99)")
	print("✓ Brock in Episode I verified with Geodude (#73) and Onix (#95)!")
	
	# 3. Test Poké Flute shop removal from main_menu scene
	var scene = load("res://scenes/main_menu.tscn")
	var menu = scene.instantiate()
	add_child(menu)
	
	var shop_vbox = menu.find_child("ShopVBox", true, false)
	assert(shop_vbox != null, "ShopVBox should exist")
	var flute_row = shop_vbox.get_node_or_null("PokeFluteRow")
	assert(flute_row == null, "PokeFluteRow must NOT exist in the shop")
	print("✓ Poké Flute is not sold in the Camp Shop.")
	
	# 4. Test Poké Flute award in Episode V
	GameData.adventure_unlocked_episodes = [1, 2, 3, 4, 5]
	GameData.adventure_completed_episodes = [1, 2, 3, 4]
	GameData.adventure_ep5_cleared_routes = []
	GameData.tutorial_completed = true
	GameData.adventure_inventory.clear()
	GameData.adventure_ep5_selected_route = "pokemon_tower"
	GameData.complete_adventure_episode(5)
	assert(GameData.adventure_inventory.get("poke_flute", 0) == 1, "Clearing Pokémon Tower must grant Poké Flute")
	print("✓ Poké Flute is correctly granted upon completing Pokémon Tower in campaign.")
	
	print("==================================================")
	print("✅ ALL BROCK & POKÉ FLUTE TESTS PASSED!")
	print("==================================================")
	get_tree().quit()
