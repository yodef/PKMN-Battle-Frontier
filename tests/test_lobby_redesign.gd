extends Node

func _ready() -> void:
	print("--- TESTING SINGLE ACTIVE AVATAR & PROFILE INTEGRATION ---")
	var menu_scene = load("res://scenes/main_menu.tscn")
	var menu = menu_scene.instantiate()
	add_child(menu)
	
	menu._on_login_play_pressed()
	
	# 1. Test single active avatar button exists
	var cur_btn = menu.find_child("BtnCurrentAvatar", true, false)
	assert(cur_btn != null, "BtnCurrentAvatar must exist in lobby header")
	print("Test 1 Passed: Single active avatar button exists.")
	
	# 2. Test opening AvatarModal and selecting Charizard
	menu._open_avatar_modal()
	var modal = menu.find_child("AvatarModal", true, false)
	assert(modal != null and modal.visible == true, "AvatarModal should be open")
	
	menu._on_avatar_selected("charizard")
	assert(GameData.profile_avatar == "charizard", "Avatar should be charizard")
	assert(modal.visible == false, "AvatarModal should close on selection")
	assert(cur_btn.icon != null, "BtnCurrentAvatar icon should be updated")
	print("Test 2 Passed: Selected Charizard and updated lobby avatar button.")
	
	# 3. Test ProfileModal avatar display
	menu._on_profile_pressed()
	var prof_preview = menu.find_child("ProfileAvatarPreview", true, false)
	var prof_name = menu.find_child("ProfileAvatarName", true, false)
	assert(prof_preview != null and prof_preview.texture != null, "ProfileAvatarPreview must display texture")
	assert(prof_name != null and prof_name.text.contains("Charizard"), "ProfileAvatarName must display Charizard")
	print("Test 3 Passed: ProfileModal displays chosen avatar successfully.")
	
	# 4. Test switching to Red
	menu._on_avatar_selected("red")
	assert(GameData.profile_avatar == "red", "Avatar should be red")
	assert(prof_name.text.contains("Trainer Red"), "ProfileAvatarName must display Trainer Red")
	print("Test 4 Passed: Switched to Trainer Red.")
	
	# 5. Test MainCombatStage floating elements
	var stage = menu.find_child("MainCombatStage", true, false)
	assert(stage != null, "MainCombatStage must exist")
	var logo = menu.find_child("LogoRect", true, false)
	assert(logo != null and logo.texture != null, "Transparent LogoRect must exist")
	var qb = menu.find_child("BtnQuickBattle", true, false)
	var om = menu.find_child("BtnOnlineMultiplayer", true, false)
	var cp = menu.find_child("BtnCampaign", true, false)
	assert(qb != null and om != null and cp != null, "All 3 combat buttons must exist")
	print("Test 5 Passed: MainCombatStage with transparent logo and floating combat buttons verified.")
	
	print("=== ALL AVATAR & LOBBY REDESIGN TESTS PASSED! ===")
	get_tree().quit(0)
