extends Node

func _ready():
	print("=== RUNNING TEST: FRIEND NOTIFICATION & ADD BACK SYSTEM ===")
	
	# Load Main Menu scene
	var menu_scene = load("res://scenes/main_menu.tscn")
	var menu = menu_scene.instantiate()
	add_child(menu)
	await get_tree().process_frame
	
	print("✓ Main menu instantiated successfully")
	
	# Verify banner nodes exist
	assert(menu.friend_notice_banner != null, "friend_notice_banner must exist")
	assert(menu.friend_notice_title != null, "friend_notice_title must exist")
	assert(menu.friend_notice_desc != null, "friend_notice_desc must exist")
	assert(menu.btn_add_back_notice != null, "btn_add_back_notice must exist")
	assert(menu.btn_dismiss_notice != null, "btn_dismiss_notice must exist")
	print("✓ All FriendNoticeBanner nodes verified")
	
	# Simulate incoming friend request
	var incoming_mock = [
		{
			"alias": "TestTrainerRed",
			"email": "testred@gmail.com",
			"id": "PKMN-999888"
		}
	]
	
	# Clear existing friends
	GameData.player_friends.clear()
	assert(not GameData.is_friend("testred@gmail.com"), "Must not be friends yet")
	
	# Process incoming friend notification
	menu._process_incoming_friend_notifications(incoming_mock)
	assert(menu.friend_notice_banner.visible == true, "Banner should be visible when incoming friend request exists")
	print("✓ Banner becomes visible with incoming friend request: ", menu.friend_notice_desc.text)
	
	# Test Search Result Card with has_added_you = true
	var search_data_added_you = {
		"alias": "TestTrainerRed",
		"email": "testred@gmail.com",
		"id": "PKMN-999888",
		"last_activity_at": "2026-11-09T07:00:00",
		"is_self": false,
		"has_added_you": true
	}
	var card = menu._create_search_result_card(search_data_added_you)
	assert(card != null, "Card must be created")
	
	# Verify card contains badge
	var card_text = ""
	for c in card.find_children("*", "Label", true, false):
		card_text += c.text + " "
	print("✓ Search result card content: ", card_text)
	assert("Te agregó" in card_text or "Added You" in card_text, "Card must have 'Te agregó' or 'Added You' badge")
	
	# Test Add Back via Banner
	menu.btn_add_back_notice.emit_signal("pressed")
	await get_tree().process_frame
	
	assert(GameData.is_friend("testred@gmail.com"), "TestTrainerRed must now be in friends list")
	assert(menu.friend_notice_banner.visible == false, "Banner should hide after adding back the only pending request")
	print("✓ Successfully added back via banner! Total friends: %d" % GameData.player_friends.size())
	
	# Test Search Result Card after being mutual friends
	var card_mutual = menu._create_search_result_card(search_data_added_you)
	var mutual_text = ""
	for c in card_mutual.find_children("*", "Label", true, false):
		mutual_text += c.text + " "
	print("✓ Mutual friend card content: ", mutual_text)
	assert("Mutuo" in mutual_text or "Mutual" in mutual_text, "Card must now show Mutual badge")
	
	print("=== ALL FRIEND NOTIFICATION & ADD BACK TESTS PASSED! ===")
	get_tree().quit(0)
