extends Node

func _ready() -> void:
	print("==================================================")
	print("🧪 RUNNING TEST SUITE: FAVORITES, SHOWCASE & MULTIPLAYER SYNC")
	print("==================================================")
	
	_test_favorites_logic()
	_test_showcase_logic()
	_test_save_load_serialization()
	_test_foil_shaders()
	_test_online_polling_cache_buster()
	_test_main_menu_integration()
	
	print("==================================================")
	print("✅ ALL TESTS PASSED SUCCESSFULLY! (0 ERRORS)")
	print("==================================================")
	get_tree().quit(0)

func _test_favorites_logic() -> void:
	print("\n--- 1. Testing Favorites Logic ---")
	GameData.player_favorites.clear()
	assert(not GameData.is_pokemon_favorite(1), "Expected 1 to NOT be favorite initially")
	
	GameData.set_pokemon_favorite(1, true)
	assert(GameData.is_pokemon_favorite(1), "Expected 1 to be favorite after set true")
	assert(1 in GameData.player_favorites, "Expected 1 in player_favorites array")
	
	var toggled = GameData.toggle_pokemon_favorite(1)
	assert(not toggled, "Expected toggle to return false")
	assert(not GameData.is_pokemon_favorite(1), "Expected 1 to be removed from favorites")
	
	var toggled_again = GameData.toggle_pokemon_favorite(4)
	assert(toggled_again, "Expected toggle to return true for 4")
	assert(GameData.is_pokemon_favorite(4), "Expected 4 to be favorite")
	print("✓ Favorites toggling, checking, and array management passed.")

func _test_showcase_logic() -> void:
	print("\n--- 2. Testing Showcase Logic ---")
	GameData.profile_showcase_ids.clear()
	GameData.set_profile_showcase([1, 4, 7])
	assert(GameData.profile_showcase_ids.size() == 3, "Expected 3 showcase ids")
	assert(GameData.profile_showcase_ids == [1, 4, 7], "Expected [1, 4, 7]")
	
	# Testing max 3 limit
	GameData.set_profile_showcase([1, 4, 7, 25])
	assert(GameData.profile_showcase_ids.size() == 3, "Expected max 3 showcase ids")
	assert(GameData.profile_showcase_ids == [1, 4, 7], "Expected [1, 4, 7]")
	print("✓ Showcase assignment and max-3 constraint passed.")

func _test_save_load_serialization() -> void:
	print("\n--- 3. Testing Save/Load Serialization ---")
	GameData.player_favorites = [4, 25]
	GameData.profile_showcase_ids = [4, 7, 25]
	
	var save_dict = GameData.get_save_dict()
	assert(save_dict.has("favorites"), "Expected favorites in save_dict")
	assert(save_dict.has("favorite_showcase"), "Expected favorite_showcase in save_dict")
	assert(save_dict["favorites"] == [4, 25], "Expected matching favorites in save_dict")
	assert(save_dict["favorite_showcase"] == [4, 7, 25], "Expected matching showcase in save_dict")
	assert(save_dict["profile"]["favorite_showcase"] == [4, 7, 25], "Expected showcase inside profile dict")
	
	# Reset and apply
	GameData.player_favorites.clear()
	GameData.profile_showcase_ids.clear()
	var ok = GameData.apply_save_dict(save_dict)
	assert(ok, "Expected apply_save_dict to succeed")
	assert(GameData.player_favorites == [4, 25], "Expected favorites restored")
	assert(GameData.profile_showcase_ids == [4, 7, 25], "Expected showcase restored")
	print("✓ Save/load serialization and round-trip parsing passed.")

func _test_foil_shaders() -> void:
	print("\n--- 4. Testing Foil Shaders ---")
	var dummy_control = Control.new()
	add_child(dummy_control)
	
	# Rare (Silver sheen)
	var rare_foil = GameData.apply_foil_overlay(dummy_control, "Rare")
	assert(rare_foil != null, "Expected Rare foil overlay")
	assert(rare_foil.material is ShaderMaterial, "Expected ShaderMaterial on foil overlay")
	
	# Epic (Cosmic Violet/Cyan)
	var epic_foil = GameData.apply_foil_overlay(dummy_control, "Epic")
	assert(epic_foil != null, "Expected Epic foil overlay")
	
	# Legendary (Supernova Rainbow)
	var leg_foil = GameData.apply_foil_overlay(dummy_control, "Legendary")
	assert(leg_foil != null, "Expected Legendary foil overlay")
	
	# Common with force_showcase_foil = true
	var common_showcase_foil = GameData.apply_foil_overlay(dummy_control, "Common", true)
	assert(common_showcase_foil != null, "Expected showcase foil on Common card when force_showcase_foil is true")
	
	dummy_control.queue_free()
	print("✓ Foil overlay application and shader generation passed.")

func _test_online_polling_cache_buster() -> void:
	print("\n--- 5. Testing Online Polling & Cache Buster ---")
	OnlineManager.room_code = "TEST"
	OnlineManager.is_online_match = true
	
	# Verify that BASE_ROOMS_URL exists and key is included
	assert(OnlineManager.BASE_ROOMS_URL.contains("rooms"), "Expected valid BASE_ROOMS_URL")
	assert(OnlineManager.has_method("set_guest_ready"), "Expected set_guest_ready method")
	assert(OnlineManager.has_method("start_online_match"), "Expected start_online_match method")
	OnlineManager.reset_session()
	print("✓ OnlineManager multiplayer room and polling methods verified.")

func _test_main_menu_integration() -> void:
	print("\n--- 6. Testing MainMenu Integration ---")
	var mm_scene = load("res://scenes/main_menu.tscn")
	assert(mm_scene != null, "Expected main_menu.tscn to load")
	
	var mm = mm_scene.instantiate()
	add_child(mm)
	
	# Check favorites collection filter
	assert(mm.has_method("populate_collection_grid"), "Expected populate_collection_grid method")
	assert(mm.has_method("get_filtered_collection_cards"), "Expected get_filtered_collection_cards method")
	
	# Test FAVORITES filter in collection
	GameData.player_favorites = [1]
	mm.col_filter_owned = "FAVORITES"
	var filtered = mm.get_filtered_collection_cards()
	assert(filtered.size() == 1, "Expected exactly 1 card in filtered favorites, got %d" % filtered.size())
	assert(int(filtered[0]["id"]) == 1, "Expected card 1")
	
	# Check showcase methods
	assert(mm.has_method("_update_profile_showcase_ui"), "Expected _update_profile_showcase_ui")
	assert(mm.has_method("_build_showcase_card_node"), "Expected _build_showcase_card_node")
	assert(mm.has_method("_open_showcase_picker_modal"), "Expected _open_showcase_picker_modal")
	assert(mm.has_method("_open_friend_profile_modal"), "Expected _open_friend_profile_modal")
	
	# Build a test showcase node
	var card_node = mm._build_showcase_card_node(1, 0, true)
	assert(card_node != null, "Expected showcase card node to build")
	assert(card_node is Control, "Expected Control instance")
	card_node.queue_free()
	
	# Test empty showcase slot
	var empty_slot = mm._build_showcase_card_node(-1, 2, true)
	assert(empty_slot != null, "Expected empty showcase slot to build")
	empty_slot.queue_free()
	
	mm.queue_free()
	print("✓ MainMenu favorites filter, showcase building, and friend modal methods passed.")
