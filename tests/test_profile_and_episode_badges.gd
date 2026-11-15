extends Node

func _ready() -> void:
	print("=== RUNNING TEST: PROFILE & EPISODE BADGES ===")
	
	# 1. Test championships count
	GameData.stats_championships_won = 3
	assert(GameData.get_championships_won_count() >= 3, "Championship count should be at least 3")
	print("✓ Test 1 Passed: Championships count = ", GameData.get_championships_won_count())
	
	# 2. Test badge info for episodes (all 32 episodes across 4 regions)
	var ep_test_list = [
		1, 2, 3, 4, 5, 6, 7, 8, # Kanto
		101, 102, 103, 104, 105, 106, 107, 108, # Johto
		201, 202, 203, 204, 205, 206, 207, 208, # Hoenn
		301, 302, 303, 304, 305, 306, 307, 308 # Sinnoh
	]
	for ep in ep_test_list:
		var info = GameData.get_badge_info_for_episode(ep)
		assert(not info.is_empty(), "Episode %d should have badge info" % ep)
		assert(info.get("texture") != null, "Episode %d badge texture must not be null" % ep)
	print("✓ Test 2 Passed: All 32 episodes have valid badge info and loaded textures.")
	
	# 3. Test get_earned_badges_by_region()
	# Simulate completed episodes: Ep 1 (Boulder), Ep 2 (Cascade), Ep 101 (Zephyr)
	GameData.adventure_completed_episodes.clear()
	GameData.adventure_completed_episodes.append(1)
	GameData.adventure_completed_episodes.append(2)
	GameData.adventure_completed_episodes.append(101)
	
	var earned = GameData.get_earned_badges_by_region()
	assert(earned["Kanto"].size() == 2, "Kanto should have 2 earned badges")
	assert(earned["Johto"].size() == 1, "Johto should have 1 earned badge")
	assert(earned["Hoenn"].size() == 0, "Hoenn should have 0 earned badges")
	assert(earned["Sinnoh"].size() == 0, "Sinnoh should have 0 earned badges")
	print("✓ Test 3 Passed: get_earned_badges_by_region() correctly filters completed episodes.")
	
	# 4. Instantiate MainMenu and test UI integration
	var main_menu_scene = load("res://scenes/main_menu.tscn")
	assert(main_menu_scene != null, "MainMenu scene should load successfully")
	var menu_instance = main_menu_scene.instantiate()
	add_child(menu_instance)
	
	# Test profile UI update
	menu_instance._on_profile_pressed()
	var champ_lbl = menu_instance.find_child("StatChampionshipsLbl", true, false) as Label
	assert(champ_lbl != null, "StatChampionshipsLbl must exist in ProfileModal")
	print("✓ Profile StatChampionshipsLbl text: ", champ_lbl.text)
	
	var badges_card = menu_instance.find_child("ProfileBadgesCard", true, false) as PanelContainer
	assert(badges_card != null, "ProfileBadgesCard must exist in ProfileModal")
	
	# In ProfileBadgesCard, Kanto (2 badges) and Johto (1 badge) should be visible, Hoenn and Sinnoh omitted
	var kanto_row_found = false
	var johto_row_found = false
	var hoenn_row_found = false
	for lbl in badges_card.find_children("*", "Label", true, false):
		if "KANTO:" in lbl.text:
			kanto_row_found = true
		if "JOHTO:" in lbl.text:
			johto_row_found = true
		if "HOENN:" in lbl.text:
			hoenn_row_found = true
	assert(kanto_row_found, "KANTO: row should be present in BadgesCard")
	assert(johto_row_found, "JOHTO: row should be present in BadgesCard")
	assert(not hoenn_row_found, "HOENN: row should NOT be present since 0 badges earned")
	print("✓ Test 4 Passed: ProfileBadgesCard only displays regions with earned badges.")
	
	# 5. Test Adventure Mode Kanto Episode Cards
	menu_instance.update_adventure_episodes_ui()
	for i in range(1, 9):
		var card = menu_instance.find_child("CardAdventureEp%d" % i, true, false)
		assert(card != null, "CardAdventureEp%d must exist" % i)
		var badge_row = card.find_child("EpBadgeRow", true, false) as HBoxContainer
		assert(badge_row != null, "CardAdventureEp%d must have EpBadgeRow" % i)
		var badge_icon = badge_row.find_child("BadgeIcon", true, false) as TextureRect
		assert(badge_icon != null and badge_icon.texture != null, "CardAdventureEp%d must have BadgeIcon" % i)
		var badge_lbl = badge_row.find_child("BadgeLbl", true, false) as Label
		assert(badge_lbl != null, "CardAdventureEp%d must have BadgeLbl" % i)
	print("✓ Test 5 Passed: All Kanto episode cards have badge miniature art and info.")
	
	# 6. Test Spanish language localization
	GameData.settings_language = "es"
	menu_instance._on_profile_pressed()
	assert("Campeonatos ganados:" in champ_lbl.text, "Championship label in Spanish must show Campeonatos ganados")
	var badges_title_lbl = badges_card.find_child("BadgesCardTitle", true, false) as Label
	assert(badges_title_lbl != null and "MEDALLAS OBTENIDAS" in badges_title_lbl.text, "BadgesCard title in Spanish must be MEDALLAS OBTENIDAS")
	print("✓ Test 6 Passed: Spanish localization verified.")

	# 7. Test all 8 avatar face textures
	var avatar_ids = ["leaf", "red", "pikachu", "charizard", "gengar", "mewtwo", "lucario", "eevee"]
	for av_id in avatar_ids:
		var tex = GameData.get_avatar_texture(av_id)
		assert(tex != null, "Avatar %s texture must not be null" % av_id)
		assert(tex.get_width() == 160 and tex.get_height() == 160, "Avatar %s must be 160x160 face crop" % av_id)
	print("✓ Test 7 Passed: All 8 avatar face textures are valid 160x160 portraits.")

	# 8. Test Friend Profile Modal displays Friend Avatar and Badges Gallery
	var fake_save_data = {
		"profile": {
			"trainer_alias": "AshKetchum",
			"avatar": "charizard"
		},
		"stats": {
			"tournaments_won": 5,
			"championships_won": 2,
			"battles_won": 40,
			"battles_total": 50,
			"packs_opened": 12
		},
		"economy": {
			"diamonds": 100,
			"rare_candies": 10
		},
		"adventure": {
			"completed_episodes": [1, 2, 3, 201] # 3 Kanto badges, 1 Hoenn badge
		}
	}
	var fake_f_data = {
		"alias": "AshKetchum",
		"email": "ash@pallet.local",
		"avatar": "charizard"
	}
	menu_instance._render_friend_profile_data(fake_save_data, fake_f_data)
	var f_avatar_preview = menu_instance.friend_profile_modal.find_child("FriendAvatarPreview", true, false) as TextureRect
	assert(f_avatar_preview != null, "FriendAvatarPreview must exist in Friend Profile Modal")
	assert(f_avatar_preview.texture != null, "FriendAvatarPreview must display the friend's avatar texture")
	print("✓ Test 8 Passed: Friend profile avatar displays correctly.")

	var f_badges_card = menu_instance.friend_profile_modal.find_child("FriendBadgesCard", true, false) as PanelContainer
	assert(f_badges_card != null, "FriendBadgesCard must exist in Friend Profile Modal")
	var f_kanto = false
	var f_hoenn = false
	var f_johto = false
	for lbl in f_badges_card.find_children("*", "Label", true, false):
		if "KANTO:" in lbl.text:
			f_kanto = true
		if "HOENN:" in lbl.text:
			f_hoenn = true
		if "JOHTO:" in lbl.text:
			f_johto = true
	assert(f_kanto, "KANTO: row must be displayed in FriendBadgesCard")
	assert(f_hoenn, "HOENN: row must be displayed in FriendBadgesCard")
	assert(not f_johto, "JOHTO: row must NOT be displayed since friend earned 0 Johto badges")
	print("✓ Test 9 Passed: Friend badges gallery renders only earned badges.")

	print("=== ALL TESTS PASSED! ===")
	get_tree().quit(0)
