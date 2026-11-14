extends Node

func _ready() -> void:
	print("\n=== STARTING TEST: Day 7 Special Booster Pack ===")
	GameData.set_language("en")
	
	# --------------------------------------------------------------------------
	# 1. VERIFY CALENDAR CONFIGURATION FOR DAY 7
	# --------------------------------------------------------------------------
	print("--- SECTION 1: Calendar Data Verification ---")
	assert(GameData.DAILY_LOGIN_CALENDAR.size() == 7, "Daily calendar must have 7 days!")
	var day7_entry = GameData.DAILY_LOGIN_CALENDAR[6]
	print("Day 7 entry: ", day7_entry)
	assert(day7_entry.get("day") == 7, "Entry index 6 must be Day 7")
	assert(day7_entry.get("pack") == "special", "Day 7 must award 'special' pack")
	assert(day7_entry.get("diamonds", 0) == 0, "Day 7 diamonds should be 0")
	assert(day7_entry.get("candies", 0) == 0, "Day 7 candies should be 0")
	print("✅ Section 1 PASSED: Calendar config correctly designates Day 7 Special Pack.")
	
	# --------------------------------------------------------------------------
	# 2. VERIFY SPECIAL BOOSTER PACK METADATA & TEXTURE
	# --------------------------------------------------------------------------
	print("\n--- SECTION 2: Special Pack Metadata & Texture ---")
	assert(GameData.BOOSTER_PACKS.has("special"), "BOOSTER_PACKS must contain 'special'")
	var s_info = GameData.BOOSTER_PACKS["special"]
	assert(s_info.get("name") == "Special Booster Pack", "Special pack name mismatch")
	assert(s_info.get("region") == "Special", "Special pack region mismatch")
	var tex = GameData.get_booster_pack_texture("special")
	assert(tex != null, "Booster pack texture for 'special' must load!")
	print("Special pack texture loaded: ", tex.resource_path)
	print("✅ Section 2 PASSED: Special Pack definition and texture valid.")
	
	# --------------------------------------------------------------------------
	# 3. VERIFY PULL MECHANICS (5 CARDS TOTAL & 5th GUARANTEED EPIC / LEGENDARY)
	# --------------------------------------------------------------------------
	print("\n--- SECTION 3: Special Pack Opening Mechanics (20 pulls) ---")
	var high_rarities = ["epic", "epica", "epico", "sr", "super rare", "legendary", "legendaria", "legendario", "ur", "ultra rare"]
	
	for trial in range(20):
		var cards = GameData.open_special_booster_pack()
		assert(cards.size() == 5, "Special booster pack must yield exactly 5 cards (trial %d had %d)" % [trial, cards.size()])
		
		# Check unique IDs in single pack
		var ids_in_pack = []
		for c in cards:
			assert(not (c["id"] in ids_in_pack), "No duplicate card IDs allowed in a single pack!")
			ids_in_pack.append(c["id"])
			
		# Check 5th card (last card) guaranteed Epic or Legendary
		var last_card = cards[4]
		var last_rarity = str(last_card.get("rarity", "")).strip_edges().to_lower()
		var is_epic_or_leg = (last_rarity in high_rarities)
		assert(is_epic_or_leg, "Trial %d: 5th card must be Epic or Legendary! Got: %s (%s)" % [trial, last_card.get("name"), last_rarity])
		
	print("✅ Section 3 PASSED: All 20 test pulls yielded 5 cards with 5th guaranteed Epic/Legendary.")
	
	# --------------------------------------------------------------------------
	# 4. VERIFY CLAIM DAILY LOGIN REWARD FOR DAY 7
	# --------------------------------------------------------------------------
	print("\n--- SECTION 4: Claiming Day 7 Login Reward ---")
	GameData.daily_login_streak = 7
	GameData.daily_login_claimed_today = false
	var initial_packs_opened = GameData.stats_packs_opened
	
	var claim_res = GameData.claim_daily_login_reward()
	assert(claim_res.get("success") == true, "Claiming Day 7 should succeed")
	assert(claim_res.get("pack") == "special", "Claim result should specify pack 'special'")
	var opened = claim_res.get("opened_cards", [])
	assert(opened.size() == 5, "Claim result must contain 5 opened cards")
	assert(GameData.daily_login_claimed_today == true, "Claimed status should be true")
	assert(GameData.stats_packs_opened == initial_packs_opened + 1, "Packs opened stat should increment by 1")
	
	var day7_last_card = opened[4]
	var day7_last_rarity = str(day7_last_card.get("rarity", "")).strip_edges().to_lower()
	assert(day7_last_rarity in high_rarities, "Day 7 5th card must be Epic or Legendary! Got: %s" % day7_last_rarity)
	print("Day 7 claim result: streak=%d, 5th card=%s (%s)" % [claim_res.get("streak"), day7_last_card.get("name"), day7_last_rarity])
	print("✅ Section 4 PASSED: Day 7 claim correctly awards and opens Special Pack.")
	
	# --------------------------------------------------------------------------
	# 5. VERIFY UI INTERACTION IN MAIN_MENU SCENE
	# --------------------------------------------------------------------------
	print("\n--- SECTION 5: UI Integration with Main Menu ---")
	var menu_scene = load("res://scenes/main_menu.tscn").instantiate()
	add_child(menu_scene)
	await get_tree().process_frame
	
	# Reset state for Day 7 claim in UI
	GameData.daily_login_streak = 7
	GameData.daily_login_claimed_today = false
	menu_scene._update_daily_ui()
	
	var btn_claim = menu_scene.find_child("BtnClaimLoginReward", true, false) as Button
	assert(btn_claim != null, "BtnClaimLoginReward must exist")
	print("Claim button text (EN): ", btn_claim.text)
	assert(btn_claim.disabled == false, "Claim button should be enabled on Day 7 when unclaimed")
	assert("Special Pack" in btn_claim.text or "Special" in btn_claim.text, "Claim button must mention Special Pack")
	
	# Test Spanish translation
	GameData.set_language("es")
	menu_scene._update_daily_ui()
	print("Claim button text (ES): ", btn_claim.text)
	assert("Sobre Especial" in btn_claim.text or "Especial" in btn_claim.text, "Claim button in Spanish must mention Sobre Especial")
	
	# Press claim button
	menu_scene._on_claim_login_reward_pressed()
	await get_tree().process_frame
	
	# Check that pack showoff box was created and is visible
	var showoff_box = menu_scene.find_child("PackShowoffBox", true, false)
	assert(showoff_box != null, "PackShowoffBox must exist after claiming Day 7")
	assert(showoff_box.visible == true, "PackShowoffBox must be visible")
	assert(menu_scene.current_showoff_cards.size() == 5, "Showoff cards must contain 5 cards")
	
	# Check 5th card display and guaranteed banner
	menu_scene._display_showoff_card(4)
	assert(menu_scene.showoff_count_lbl.text.contains("5"), "Showoff count must say Card 5 of 5")
	print("5th Card Banner text: ", menu_scene.showoff_banner_lbl.text)
	assert("GARANTIZADO" in menu_scene.showoff_banner_lbl.text or "GUARANTEED" in menu_scene.showoff_banner_lbl.text or "ÉPICO" in menu_scene.showoff_banner_lbl.text or "LEGENDARIO" in menu_scene.showoff_banner_lbl.text, "5th card banner should indicate high rarity")
	
	# Finish showoff to inspect summary
	menu_scene._finish_pack_showoff()
	await get_tree().process_frame
	var reveal_another = menu_scene.btn_reveal_another
	if reveal_another:
		assert(reveal_another.visible == false, "BtnRevealAnother must be hidden for Special Pack")
	var btn_back = menu_scene.pack_reveal_box.find_child("BtnBackShop", true, false) as Button
	if btn_back:
		print("Back/Close button text: ", btn_back.text)
		assert("Cerrar" in btn_back.text or "Close" in btn_back.text or "Back" in btn_back.text, "Back button should offer clean exit")
		btn_back.emit_signal("pressed")
		await get_tree().process_frame
		assert(menu_scene.shop_modal.visible == false, "Closing special pack summary should close shop modal")
		
	print("✅ Section 5 PASSED: UI flow for Day 7 Special Pack verified successfully.")
	
	menu_scene.queue_free()
	print("\n=== ALL TESTS PASSED: Day 7 Special Booster Pack Verified Successfully! ===")
	get_tree().quit(0)
