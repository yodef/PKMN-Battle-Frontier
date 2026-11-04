extends Node

func _ready() -> void:
	print("--- Running Test: Recycle All Feature in Shop ---")
	
	GameData.player_rare_candies = 0
	GameData.player_card_stocks.clear()
	GameData.player_unlocked_ids = [0, 3, 6] # Bulbasaur, Charmander, Charizard
	
	# Set up stocks:
	# Card 0: stock = 1 (no duplicates)
	# Card 3: stock = 4 (3 duplicates)
	# Card 6: stock = 3 (2 duplicates)
	GameData.player_card_stocks[0] = 1
	GameData.player_card_stocks[3] = 4
	GameData.player_card_stocks[6] = 3
	
	var cat3 = GameData.pokemon_catalog.get(3, {})
	var r3 = str(cat3.get("rarity", "Common"))
	var candy_val3 = GameData.get_recycle_candy_value(r3)
	
	var cat6 = GameData.pokemon_catalog.get(6, {})
	var r6 = str(cat6.get("rarity", "Common"))
	var candy_val6 = GameData.get_recycle_candy_value(r6)
	
	print("Initial Candies: %d" % GameData.player_rare_candies)
	print("Card 3 Rarity: %s (value: %d), stock: %d" % [r3, candy_val3, GameData.get_card_stock(3)])
	print("Card 6 Rarity: %s (value: %d), stock: %d" % [r6, candy_val6, GameData.get_card_stock(6)])
	
	# Test 1: recycle_all_copies_of_card on card 0 (stock 1) -> 0 recycled
	var res0 = GameData.recycle_all_copies_of_card(0)
	assert(res0["recycled_count"] == 0, "Card with stock 1 should recycle 0")
	assert(res0["candies_earned"] == 0, "Candies earned should be 0")
	assert(GameData.get_card_stock(0) == 1, "Stock must remain 1")
	print("✅ Test 1 Passed: recycle_all_copies_of_card leaves stock 1 card untouched")
	
	# Test 2: recycle_all_copies_of_card on card 3 (stock 4 -> 3 duplicates)
	var expected_candies3 = 3 * candy_val3
	var res3 = GameData.recycle_all_copies_of_card(3)
	assert(res3["recycled_count"] == 3, "Expected 3 recycled copies, got: %d" % res3["recycled_count"])
	assert(res3["candies_earned"] == expected_candies3, "Expected %d candies, got: %d" % [expected_candies3, res3["candies_earned"]])
	assert(GameData.get_card_stock(3) == 1, "Card 3 stock must now be 1, got: %d" % GameData.get_card_stock(3))
	assert(GameData.player_rare_candies == expected_candies3, "Total candies must match: %d" % GameData.player_rare_candies)
	print("✅ Test 2 Passed: recycle_all_copies_of_card recycled all 3 duplicates of card 3 and preserved 1 copy")
	
	# Test 3: recycle_all_duplicates with card 6 still having 2 duplicates
	var current_candies = GameData.player_rare_candies
	var expected_candies6 = 2 * candy_val6
	var res_all = GameData.recycle_all_duplicates()
	assert(res_all["recycled_count"] == 2, "Expected 2 recycled copies from card 6, got: %d" % res_all["recycled_count"])
	assert(res_all["candies_earned"] == expected_candies6, "Expected %d candies from card 6, got: %d" % [expected_candies6, res_all["candies_earned"]])
	assert(GameData.get_card_stock(6) == 1, "Card 6 stock must now be 1")
	assert(GameData.player_rare_candies == current_candies + expected_candies6, "Total candies must now be %d" % [current_candies + expected_candies6])
	print("✅ Test 3 Passed: recycle_all_duplicates recycled all remaining duplicates")
	
	# Test 4: Instantiate main_menu scene and verify Shop Recycle view elements
	var main_scene = load("res://scenes/main_menu.tscn")
	assert(main_scene != null, "main_menu.tscn must load successfully")
	var mm = main_scene.instantiate()
	add_child(mm)
	
	# Open Shop and switch to RECYCLE tab
	mm._on_shop_pressed()
	mm._switch_shop_tab("RECYCLE")
	
	# Check bulk recycle button exists and is displayed
	assert(mm.btn_bulk_recycle != null, "btn_bulk_recycle must exist")
	print("btn_bulk_recycle text when empty: %s" % mm.btn_bulk_recycle.text)
	assert(mm.btn_bulk_recycle.text.contains("RECYCLE ALL"), "Button text should contain RECYCLE ALL")
	
	# Add duplicates again to test UI list population
	GameData.player_card_stocks[3] = 5 # 4 extras
	mm._populate_recycle_view()
	assert(not mm.btn_bulk_recycle.disabled, "btn_bulk_recycle should be enabled with duplicates")
	assert(mm.btn_bulk_recycle.text.contains("RECYCLE ALL DUPLICATES"), "Button text should show RECYCLE ALL DUPLICATES")
	print("btn_bulk_recycle text with dupes: %s" % mm.btn_bulk_recycle.text)
	
	# Check children of recycle_scroll_list:
	var rows = mm.recycle_scroll_list.get_children()
	assert(rows.size() == 1, "There should be 1 duplicate row for Card 3")
	var row = rows[0]
	var hbox = row.get_child(0)
	assert(hbox is HBoxContainer, "First child must be HBoxContainer")
	var act_vbox = hbox.get_child(2)
	assert(act_vbox is VBoxContainer, "Third child of row HBox must be act_vbox")
	var btn_row = act_vbox.get_child(1)
	assert(btn_row is HBoxContainer, "Second child of act_vbox must be btn_row")
	var btns = btn_row.get_children()
	assert(btns.size() == 2, "Row must contain 2 action buttons: Recycle 1 and Recycle All")
	assert(btns[0].text == "Recycle 1", "First button must be 'Recycle 1'")
	assert(btns[1].text.contains("Recycle All"), "Second button must be 'Recycle All'")
	print("Card row buttons verified: [%s] [%s]" % [btns[0].text, btns[1].text])
	
	print("🎉 ALL TESTS PASSED SUCCESSFULLY!")
	get_tree().quit(0)
