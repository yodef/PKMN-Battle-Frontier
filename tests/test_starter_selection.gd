extends Control

func _ready() -> void:
	print("--- TEST COMPREHENSIVE STARTER SELECTION ---")
	var main_scene = load("res://scenes/main_menu.tscn").instantiate()
	add_child(main_scene)
	
	main_scene._open_starter_selection_modal()
	
	var row = main_scene.starter_cards_row
	assert(row != null, "starter_cards_row should not be null")
	
	# Test Kanto
	print("Testing Kanto starters...")
	assert(row.get_child_count() == 3, "Kanto should have 3 starter cards")
	
	# Test Johto
	print("Testing Johto starters...")
	main_scene.starter_region_active = "Johto"
	main_scene._update_starter_region_tabs()
	main_scene._refresh_starter_cards_display()
	assert(row.get_child_count() == 3, "Johto should have 3 starter cards")
	
	# Test Hoenn
	print("Testing Hoenn starters...")
	main_scene.starter_region_active = "Hoenn"
	main_scene._update_starter_region_tabs()
	main_scene._refresh_starter_cards_display()
	assert(row.get_child_count() == 3, "Hoenn should have 3 starter cards")
	
	# Test Sinnoh
	print("Testing Sinnoh starters...")
	main_scene.starter_region_active = "Sinnoh"
	main_scene._update_starter_region_tabs()
	main_scene._refresh_starter_cards_display()
	assert(row.get_child_count() == 3, "Sinnoh should have 3 starter cards")
	
	# Test Selecting Chimchar (395)
	print("Testing selection of Chimchar (395)...")
	GameData.set_tutorial_starter(395)
	assert(GameData.tutorial_starter_id == 395, "Starter should be 395")
	assert(GameData.tutorial_stage1_id == 396, "Stage 1 should be 396 (Monferno)")
	assert(GameData.tutorial_rival_id == 392, "Weak rival should be 392 (Turtwig)")
	assert(GameData.tutorial_rival_stage1_id == 393, "Rival stage 1 should be 393 (Grotle)")
	assert(GameData.is_pokemon_unlocked(395), "Chimchar should be unlocked in collection")
	
	print("ALL STARTER SELECTION TESTS PASSED SUCCESSFULLY!")
	get_tree().quit(0)
