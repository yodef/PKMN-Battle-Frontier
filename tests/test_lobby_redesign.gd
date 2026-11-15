extends Node

func _ready() -> void:
	print("--- TESTING LOBBY REDESIGN & AVATARS ---")
	var menu_scene = load("res://scenes/main_menu.tscn")
	var menu = menu_scene.instantiate()
	add_child(menu)
	
	menu._on_login_play_pressed()
	
	# 1. Test Avatar buttons exist
	var leaf_btn = menu.find_child("BtnAvatarLeaf", true, false)
	var red_btn = menu.find_child("BtnAvatarRed", true, false)
	var more_btn = menu.find_child("BtnMoreAvatars", true, false)
	assert(leaf_btn != null, "BtnAvatarLeaf must exist")
	assert(red_btn != null, "BtnAvatarRed must exist")
	assert(more_btn != null, "BtnMoreAvatars must exist")
	print("Test 1 Passed: Avatar buttons exist in header.")
	
	# 2. Test switching avatar to red
	menu._on_avatar_selected("red")
	assert(GameData.profile_avatar == "red", "Avatar should be red")
	print("Test 2 Passed: Switching to red avatar successful.")
	
	# 3. Test opening AvatarModal and selecting Pikachu
	menu._open_avatar_modal()
	var modal = menu.find_child("AvatarModal", true, false)
	assert(modal != null and modal.visible == true, "AvatarModal should be open")
	var grid = menu.find_child("AvatarGrid", true, false)
	assert(grid != null and grid.get_child_count() == 8, "AvatarGrid should contain 8 avatars")
	print("Test 3 Passed: AvatarModal opened with 8 customizable avatars.")
	
	menu._on_avatar_selected("pikachu")
	assert(GameData.profile_avatar == "pikachu", "Avatar should be pikachu")
	assert(modal.visible == false, "AvatarModal should close on selection")
	print("Test 4 Passed: Selected Pikachu avatar.")
	
	# 4. Test MainCombatStage and floating elements
	var stage = menu.find_child("MainCombatStage", true, false)
	assert(stage != null, "MainCombatStage must exist")
	var logo = menu.find_child("LogoRect", true, false)
	assert(logo != null and logo.texture != null, "Transparent LogoRect must exist")
	var qb = menu.find_child("BtnQuickBattle", true, false)
	var om = menu.find_child("BtnOnlineMultiplayer", true, false)
	var cp = menu.find_child("BtnCampaign", true, false)
	assert(qb != null and om != null and cp != null, "All 3 combat buttons must exist")
	print("Test 5 Passed: MainCombatStage with transparent logo and floating combat buttons verified.")
	
	print("=== ALL LOBBY REDESIGN TESTS PASSED! ===")
	get_tree().quit(0)
