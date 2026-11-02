extends Node

func _ready() -> void:
	print("\n=== STARTING QUICK BATTLE UNLOCKED-ONLY VERIFICATION ===")
	
	var menu_packed = load("res://scenes/main_menu.tscn")
	var menu = menu_packed.instantiate()
	add_child(menu)
	
	# Unlock exactly 5 Pokémon for testing
	GameData.player_unlocked_ids = []
	var target_names = ["Bulbasaur", "Charmander", "Squirtle", "Pikachu", "Snorlax"]
	var target_ids: Array[int] = []
	for p_id in GameData.pokemon_catalog.keys():
		var p = GameData.pokemon_catalog[p_id]
		var name = str(p.get("name", ""))
		if name in target_names:
			GameData.unlock_pokemon(p_id)
			target_ids.append(p_id)
			
	print("Unlocked Pokémon count: ", GameData.player_unlocked_ids.size(), " IDs: ", GameData.player_unlocked_ids)
	assert(GameData.player_unlocked_ids.size() == 5, "Should have 5 unlocked Pokémon")
	
	menu._on_login_play_pressed()
	
	# 1. Open Quick Battle (VS AI)
	GameData.is_pvp_mode = false
	menu._on_quick_battle_pressed()
	
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.2).timeout
	
	# Test Player tab cards count
	var player_pool = menu.current_sorted_team_pool
	print("Player tab pool size: ", player_pool.size())
	assert(player_pool.size() == 5, "Player pool must only contain the 5 unlocked cards!")
	for c in player_pool:
		assert(GameData.is_pokemon_unlocked(int(c["id"])), "Card %s must be unlocked!" % c.get("name"))
		
	# Switch to ENEMY tab (Rival AI)
	menu._on_tab_enemy_pressed()
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.1).timeout
	
	var enemy_pool = menu.current_sorted_team_pool
	print("Rival AI tab pool size: ", enemy_pool.size())
	assert(enemy_pool.size() == 5, "Rival AI pool must ONLY contain the 5 unlocked cards!")
	for c in enemy_pool:
		assert(GameData.is_pokemon_unlocked(int(c["id"])), "Enemy card %s must be unlocked!" % c.get("name"))
		
	# Test Randomize button for Rival AI
	for trial in range(10):
		menu._randomize_enemy_team()
		for picked_id in menu.selected_enemy_ids:
			assert(GameData.is_pokemon_unlocked(picked_id), "Random pick %d must be in unlocked cards!" % picked_id)
	print("✅ Random enemy team selection verified: only picks unlocked Pokémon")
	
	# Screenshot 1: Rival AI tab with only unlocked cards
	var img1 = get_viewport().get_texture().get_image()
	img1.save_png("C:/Users/rafag/.gemini/antigravity/brain/dca5182f-4733-4c52-8dfc-ccfff3b26dd9/quick_battle_unlocked_only_ai.png")
	print("Saved screenshot: quick_battle_unlocked_only_ai.png")
	
	# 2. Switch to PvP Mode (Pass & Play)
	menu._set_quick_battle_pvp(true)
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.1).timeout
	
	# Switch to Player 2 tab
	menu._on_tab_enemy_pressed()
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.1).timeout
	
	var p2_pool = menu.current_sorted_team_pool
	print("Player 2 tab pool size: ", p2_pool.size())
	assert(p2_pool.size() == 5, "Player 2 pool must ONLY contain the 5 unlocked cards!")
	for c in p2_pool:
		assert(GameData.is_pokemon_unlocked(int(c["id"])), "Player 2 card %s must be unlocked!" % c.get("name"))
		
	# Screenshot 2: Player 2 tab with only unlocked cards
	var img2 = get_viewport().get_texture().get_image()
	img2.save_png("C:/Users/rafag/.gemini/antigravity/brain/dca5182f-4733-4c52-8dfc-ccfff3b26dd9/quick_battle_unlocked_only_p2.png")
	print("Saved screenshot: quick_battle_unlocked_only_p2.png")
	
	print("\n=== ALL QUICK BATTLE UNLOCKED-ONLY TESTS PASSED! ===")
	get_tree().quit(0)
