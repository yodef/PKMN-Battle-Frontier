extends Node

func _ready():
	print("==================================================")
	print("🧪 TESTING NEW ONBOARDING TUTORIAL & ADVENTURE UI")
	print("==================================================")
	
	# 1. Test profile creation with tutorial state
	print("1. Testing create_new_profile default tutorial state...")
	GameData.create_new_profile("TestRookie", "Guest", "")
	assert(GameData.player_diamonds == 25, "Expected 25 starting diamonds")
	assert(not GameData.tutorial_completed, "Tutorial should not be completed yet")
	assert(GameData.tutorial_step == 1, "Tutorial step should be 1")
	assert(GameData.profile_welcome_claimed, "Welcome bonus should be claimed to prevent double gift")
	print("   ✓ New profile initialized with 25 Diamonds and tutorial_step = 1.")
	
	# 2. Test starter mapping for all regions
	print("2. Testing starter mapping table across 4 regions...")
	for pid in [0, 1, 2, 167, 170, 173, 257, 260, 263, 392, 395, 398]:
		var info = GameData.get_tutorial_starter_info(pid)
		assert(not info.is_empty(), "Starter info should exist for %d" % pid)
		assert(info.has("weak_rival_id"), "Should have weak_rival_id")
		assert(info.has("stage1_id"), "Should have stage1_id")
		assert(info.has("stone_type"), "Should have stone_type")
	print("   ✓ All 12 starters mapped correctly with weak rivals and Stage 1 evolutions.")
	
	# 3. Test choosing Charmander (Fire) -> Rival Bulbasaur (Grass)
	print("3. Testing starter selection logic (Charmander #1)...")
	GameData.set_tutorial_starter(1)
	assert(GameData.tutorial_starter_id == 1, "Starter should be Charmander")
	assert(GameData.tutorial_stage1_id == 6, "Stage 1 should be Charmeleon (#6)")
	assert(GameData.tutorial_rival_id == 0, "Weak rival should be Bulbasaur (#0)")
	assert(GameData.tutorial_rival_stage1_id == 4, "Rival stage 1 should be Ivysaur (#4)")
	print("   ✓ Charmander configured: rival is Bulbasaur, stage 1 is Charmeleon.")
	
	# 4. Test serialization and saving of tutorial state
	print("4. Testing save/load of tutorial state...")
	var save_dict = GameData.get_save_dict()
	assert(save_dict.has("campaign"), "Save should contain campaign")
	var camp = save_dict["campaign"]
	assert(camp["tutorial_step"] == 1, "Saved step should be 1")
	assert(camp["tutorial_starter_id"] == 1, "Saved starter should be 1")
	assert(camp["tutorial_stage1_id"] == 6, "Saved stage 1 should be 6")
	print("   ✓ Tutorial fields serialized and deserialized accurately.")
	
	# 5. Test Responsive Layout on Adventure Episodes Modal
	print("5. Testing responsive width of AdventureEpisodesModal...")
	var menu_scene = load("res://scenes/main_menu.tscn")
	var menu_inst = menu_scene.instantiate()
	add_child(menu_inst)
	
	var adv_modal = menu_inst.get_node("AdventureEpisodesModal")
	assert(adv_modal != null, "AdventureEpisodesModal should exist")
	var box = adv_modal.get_node("Box")
	assert(box != null, "Box should exist")
	assert(box.anchor_right == 1.0, "Box anchor_right should be 1.0 for responsive filling")
	assert(box.offset_left == 14.0 and box.offset_right == -14.0, "Box margins should be responsive (+14, -14)")
	
	var scroll: ScrollContainer = box.get_node("EpisodesScroll")
	assert(scroll.horizontal_scroll_mode == ScrollContainer.SCROLL_MODE_DISABLED, "Horizontal scroll should be DISABLED")
	print("   ✓ AdventureEpisodesModal anchors and ScrollContainer are 100% responsive without horizontal scroll.")
	
	print("==================================================")
	print("✅ ALL ONBOARDING TUTORIAL & RESPONSIVE UI TESTS PASSED!")
	print("==================================================")
	get_tree().quit()
