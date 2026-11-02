extends Node

func _ready() -> void:
	print("\n=== STARTING VERIFICATION: TOURNAMENT CENTERING & NO UNCOMMON ===")
	
	# 1. Verify GameData Rarity logic
	print("\n--- 1. GameData Candies and Rarity Checks ---")
	assert(GameData.get_recycle_candy_value("Common") == 1, "Common must give 1 candy")
	assert(GameData.get_recycle_candy_value("Rare") == 5, "Rare must give 5 candies")
	assert(GameData.get_recycle_candy_value("Epic") == 15, "Epic must give 15 candies")
	assert(GameData.get_recycle_candy_value("Legendary") == 40, "Legendary must give 40 candies")
	print("✅ Recycle candy values verified: Common=1, Rare=5, Epic=15, Legendary=40")
	
	assert(GameData.get_hidden_shop_candy_cost("Common") == 10, "Common costs 10")
	assert(GameData.get_hidden_shop_candy_cost("Rare") == 50, "Rare costs 50")
	assert(GameData.get_hidden_shop_candy_cost("Epic") == 150, "Epic costs 150")
	assert(GameData.get_hidden_shop_candy_cost("Legendary") == 400, "Legendary costs 400")
	print("✅ Hidden shop candy costs verified (10x recycle value)")
	
	# 2. Instantiate Main Menu
	var menu_packed = load("res://scenes/main_menu.tscn")
	var menu = menu_packed.instantiate()
	add_child(menu)
	
	# Unlock the exact 7 Pokémon from user's screenshot
	GameData.player_unlocked_ids = []
	for p_id in GameData.pokemon_catalog.keys():
		var p = GameData.pokemon_catalog[p_id]
		var name = str(p.get("name", ""))
		if name in ["Bulbasaur", "Charmander", "Squirtle", "Nidoran♀", "Nidoran F", "Mankey", "Drowzee", "Pichu"]:
			GameData.unlock_pokemon(p_id)
			
	menu._on_login_play_pressed()
	
	# Open Tournament Team Selection
	menu.open_team_select_for_campaign()
	
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.2).timeout
	
	# Check rows and alignment
	var grid = menu.team_grid_cards
	print("Total rows in grid: ", grid.get_child_count())
	for row_idx in range(grid.get_child_count()):
		var row = grid.get_child(row_idx) as HBoxContainer
		print("Row %d: items=%d, alignment=%d (1=CENTER), size=%s" % [row_idx, row.get_child_count(), row.alignment, str(row.size)])
		assert(row.alignment == BoxContainer.ALIGNMENT_CENTER, "Row must be ALIGNMENT_CENTER")
		
	# Verify row 1 has 4 cards, row 2 has 3 cards
	assert(grid.get_child_count() == 2, "Must have 2 rows for 7 cards")
	assert(grid.get_child(0).get_child_count() == 4, "Row 1 must have 4 cards")
	assert(grid.get_child(1).get_child_count() == 3, "Row 2 must have 3 cards")
	print("✅ Centered row chunking verified: Row 1 = 4 cards, Row 2 = 3 cards (Centered)")
	
	# Screenshot 1: Centered Tournament Selection with 7 cards
	var img_torneo = get_viewport().get_texture().get_image()
	img_torneo.save_png("C:/Users/rafag/.gemini/antigravity/brain/dca5182f-4733-4c52-8dfc-ccfff3b26dd9/tournament_team_centered_verified.png")
	print("✅ Screenshot saved: tournament_team_centered_verified.png")
	
	# Close team select and open Shop -> Hidden Shop & Recycle
	menu._on_close_team_select_pressed()
	menu._on_shop_pressed()
	menu._switch_shop_tab("HIDDEN")
	
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.2).timeout
	
	# Check hidden shop filter buttons
	assert(menu.hidden_filter_buttons.has("ALL"), "Has ALL")
	assert(menu.hidden_filter_buttons.has("COMMON"), "Has COMMON")
	assert(not menu.hidden_filter_buttons.has("UNCOMMON"), "Must NOT have UNCOMMON")
	assert(menu.hidden_filter_buttons.has("RARE"), "Has RARE")
	assert(menu.hidden_filter_buttons.has("EPIC"), "Has EPIC")
	assert(menu.hidden_filter_buttons.has("LEGENDARY"), "Has LEGENDARY")
	print("✅ Hidden shop filters verified: no UNCOMMON button exists")
	
	# Screenshot 2: Hidden Shop with no Uncommon
	var img_hidden = get_viewport().get_texture().get_image()
	img_hidden.save_png("C:/Users/rafag/.gemini/antigravity/brain/dca5182f-4733-4c52-8dfc-ccfff3b26dd9/hidden_shop_no_uncommon_verified.png")
	print("✅ Screenshot saved: hidden_shop_no_uncommon_verified.png")
	
	print("\n=== ALL VERIFICATIONS PASSED SUCCESSFULLY! ===")
	get_tree().quit(0)
