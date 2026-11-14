extends Control

func _ready():
	print("--- BEGINNING REGIONAL BOOSTER PACKS INTEGRATION TEST ---")
	GameData.set_language("en")
	
	# Instantiate main menu
	var main_scene = load("res://scenes/main_menu.tscn").instantiate()
	add_child(main_scene)
	await get_tree().process_frame
	await get_tree().process_frame
	
	print("1. Opening Shop Modal...")
	main_scene._on_shop_pressed()
	assert(main_scene.shop_modal.visible, "Shop modal should be visible")
	assert(main_scene.packs_container != null, "packs_container should be created")
	assert(main_scene.packs_catalog_view != null, "packs_catalog_view should be created")
	assert(main_scene.packs_catalog_view.visible, "packs_catalog_view should be visible on initial shop open")
	
	var pack_panel = main_scene.packs_container.get_node_or_null("PackPanel")
	assert(pack_panel != null, "PackPanel should exist")
	assert(not pack_panel.visible, "PackPanel detail view should initially be hidden")
	print("✅ Catalog view verified visible and detail view hidden.")
	
	# Check vertical layout in catalog
	var scroll = main_scene.packs_catalog_view.find_child("ScrollContainer", true, false) as ScrollContainer
	assert(scroll != null, "ScrollContainer must exist")
	assert(scroll.vertical_scroll_mode == ScrollContainer.SCROLL_MODE_AUTO, "Must use vertical scroll mode")
	print("✅ Vertical scroll layout verified.")
	
	# 2. Select Johto Pack
	print("2. Selecting Johto Booster Pack...")
	main_scene._open_booster_pack_detail("johto")
	assert(not main_scene.packs_catalog_view.visible, "Catalog view should be hidden when detail is open")
	assert(pack_panel.visible, "PackPanel detail view should now be visible")
	assert(main_scene.selected_booster_pack_id == "johto", "Selected booster pack should be johto")
	assert(main_scene.btn_small_cost_pack != null, "Small cost button must exist")
	assert(main_scene.btn_small_cost_pack.text.contains("10 💎"), "Button text must contain 10 💎: " + main_scene.btn_small_cost_pack.text)
	print("Small button text: ", main_scene.btn_small_cost_pack.text)
	
	# Check detail labels
	var title_lbl = pack_panel.find_child("PackTitle", true, false) as Label
	assert(title_lbl != null and title_lbl.text.contains("Johto"), "Title must contain Johto: " + title_lbl.text)
	assert(main_scene.pack_detail_region_lbl != null and main_scene.pack_detail_region_lbl.text.contains("Johto"), "Region label must mention Johto")
	assert(not main_scene.pack_detail_region_lbl.text.contains("📍"), "Region label must NOT contain emoji: " + main_scene.pack_detail_region_lbl.text)
	assert(main_scene.pack_detail_region_lbl.text.contains("owned of"), "Region label must match 'owned of': " + main_scene.pack_detail_region_lbl.text)
	print("✅ Johto detail view verified (No emoji format: %s)." % main_scene.pack_detail_region_lbl.text)
	
	# 3. Test opening Johto pack via small cost button (Cost 10 💎, yields 6 cards with showoff)
	print("3. Testing small button press to open Johto pack...")
	GameData.player_diamonds = 50
	main_scene._on_open_selected_pack_pressed()
	await get_tree().process_frame
	
	# Verify Showoff box is visible and starts at card 1
	assert(main_scene.pack_showoff_box != null and main_scene.pack_showoff_box.visible, "Showoff UI must be shown")
	assert(main_scene.showoff_count_lbl != null and main_scene.showoff_count_lbl.text.contains("1 of 6"), "Must start at card 1 of 6: " + main_scene.showoff_count_lbl.text)
	print("Showoff active: ", main_scene.showoff_count_lbl.text, " - Banner: ", main_scene.showoff_banner_lbl.text)
	
	# Test Next button advances showoff to card 2
	main_scene._on_showoff_next_pressed()
	await get_tree().process_frame
	assert(main_scene.showoff_count_lbl.text.contains("2 of 6"), "Must advance to card 2 of 6: " + main_scene.showoff_count_lbl.text)
	print("Showoff advanced: ", main_scene.showoff_count_lbl.text, " - Banner: ", main_scene.showoff_banner_lbl.text)
	
	# Test Skip button finishes showoff and opens summary with all 6 cards
	print("Testing Skip button...")
	main_scene._on_showoff_skip_pressed()
	await get_tree().process_frame
	assert(not main_scene.pack_showoff_box.visible, "Showoff UI must be hidden after skip")
	assert(main_scene.pack_reveal_box != null and main_scene.pack_reveal_box.visible, "Summary reveal UI must be shown after skip")
	assert(main_scene.reveal_cards_row.get_child_count() == 6, "Reveal row must show all 6 cards")
	
	# Check remaining diamonds in reveal scene
	var rem_lbl = main_scene.pack_reveal_box.find_child("RemainingDiamondsLbl", true, false) as Label
	assert(rem_lbl != null, "Remaining diamonds label must exist in reveal box")
	print("Remaining diamonds text: ", rem_lbl.text)
	assert(rem_lbl.text.contains("40"), "Remaining diamonds should reflect 50 - 10 = 40: " + rem_lbl.text)
	print("✅ Johto pack showoff and skip verified successfully (6 cards summary, 40 diamonds left)!")
	
	# Close reveal UI back to shop
	print("4. Returning from reveal UI to Shop...")
	main_scene.pack_reveal_box.visible = false
	main_scene.shop_box.visible = true
	assert(pack_panel.visible, "Should return to PackPanel detail view")
	
	# 5. Test Back to Packs button
	print("5. Testing 'Back to Packs' button...")
	main_scene._back_to_packs_catalog()
	assert(main_scene.packs_catalog_view.visible, "Catalog view must be visible again")
	assert(not pack_panel.visible, "Detail view must be hidden again")
	print("✅ Back to packs catalog navigation works perfectly.")
	
	# 6. Select Kanto Pack & Overall Pack
	print("6. Selecting Kanto Booster Pack...")
	main_scene._open_booster_pack_detail("kanto")
	assert(pack_panel.visible, "Detail view should be visible for Kanto")
	assert(title_lbl.text.contains("Kanto"), "Title should be Kanto")
	assert(main_scene.pack_detail_region_lbl.text.contains("Kanto = "), "Region should be Kanto = ")
	assert(main_scene.pack_detail_region_lbl.text.contains("owned of 151 cards"), "Must say owned of 151 cards")
	assert(not main_scene.pack_detail_region_lbl.text.contains("📍"), "Must not contain emoji")
	print("✅ Kanto pack label verified: ", main_scene.pack_detail_region_lbl.text)
	
	print("6b. Testing Overall Booster Pack...")
	main_scene._back_to_packs_catalog()
	main_scene._open_booster_pack_detail("overall")
	assert(title_lbl.text.contains("Overall"), "Title should contain Overall: " + title_lbl.text)
	assert(main_scene.pack_detail_region_lbl.text.contains("Overall = "), "Region label should say Overall = ")
	assert(main_scene.pack_detail_region_lbl.text.contains("496 cards"), "Must mention 496 cards: " + main_scene.pack_detail_region_lbl.text)
	assert(not main_scene.pack_detail_region_lbl.text.contains("📍"), "Must not contain emoji")
	print("✅ Overall pack label verified: ", main_scene.pack_detail_region_lbl.text)
	
	# 7. Test Language Translation
	print("7. Testing Spanish Language Translation on Shop...")
	GameData.set_language("es")
	main_scene._back_to_packs_catalog()
	await get_tree().process_frame
	main_scene._open_booster_pack_detail("johto")
	await get_tree().process_frame
	print("Small button text in ES: ", main_scene.btn_small_cost_pack.text)
	print("Back button text in ES: ", main_scene.btn_back_from_detail.text)
	assert(main_scene.btn_small_cost_pack.text.contains("💎"), "Button text must contain diamond icon")
	
	# Test showoff and reveal scene in Spanish
	main_scene._on_open_selected_pack_pressed()
	await get_tree().process_frame
	assert(main_scene.pack_showoff_box.visible, "Showoff UI in ES must be visible")
	print("Skip button in ES: ", main_scene.btn_showoff_skip.text)
	assert(main_scene.btn_showoff_skip.text.contains("SALTAR"), "Skip button in ES must say SALTAR: " + main_scene.btn_showoff_skip.text)
	
	main_scene._on_showoff_skip_pressed()
	await get_tree().process_frame
	assert(main_scene.pack_reveal_box.visible, "Summary in ES must be visible")
	var rem_lbl_es = main_scene.pack_reveal_box.find_child("RemainingDiamondsLbl", true, false) as Label
	print("Remaining diamonds text in ES: ", rem_lbl_es.text)
	assert(rem_lbl_es.text.contains("Diamantes restantes"), "Must say 'Diamantes restantes': " + rem_lbl_es.text)
	
	print("🎉 ALL REGIONAL BOOSTER PACK TESTS PASSED SUCCESSFULLY!")
	get_tree().quit()
