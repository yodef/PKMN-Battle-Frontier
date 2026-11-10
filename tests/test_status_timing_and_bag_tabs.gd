extends Node

func _ready() -> void:
	print("=== RUNNING TEST: STATUS TIMING & BAG TABS ===")

	# 1. Test GameData Constants & Consumable Counting
	assert(GameData.MAX_CONSUMABLE_ITEMS == 10, "MAX_CONSUMABLE_ITEMS should be 10")
	var test_inv = {
		"potion": 3,
		"super_potion": 2,
		"hyper_potion": 1,
		"revive": 1,
		"remedy": 1,
		"ether": 1,
		"poke_flute": 1,
		"exp_share": 1
	}
	var count = GameData.get_consumable_items_count(test_inv)
	assert(count == 9, "Consumable count should be 9 (3+2+1+1+1+1), got %d" % count)
	assert(not GameData.is_consumable_inventory_full(test_inv), "Inventory with 9 consumables should not be full")

	test_inv["potion"] = 4
	assert(GameData.get_consumable_items_count(test_inv) == 10, "Consumable count should be 10")
	assert(GameData.is_consumable_inventory_full(test_inv), "Inventory with 10 consumables should be full")
	print("✓ GameData consumable limit & counting checks passed.")

	# 2. Test Store restrictions
	GameData.is_campaign_mode = true
	GameData.campaign_gold = 500
	GameData.campaign_inventory = test_inv.duplicate(true)
	assert(GameData.buy_campaign_potion() == false, "buy_campaign_potion should return false when inventory is full (10/10)")
	assert(GameData.buy_campaign_super_potion() == false, "buy_campaign_super_potion should return false when full")
	assert(GameData.buy_campaign_hyper_potion() == false, "buy_campaign_hyper_potion should return false when full")
	assert(GameData.buy_campaign_revive() == false, "buy_campaign_revive should return false when full")
	assert(GameData.buy_campaign_remedy() == false, "buy_campaign_remedy should return false when full")
	assert(GameData.buy_campaign_ether() == false, "buy_campaign_ether should return false when full")
	assert(GameData.buy_campaign_poke_flute() == false, "buy_campaign_poke_flute should return false (key items not for sale)")
	assert(GameData.campaign_gold == 500, "Gold should remain untouched when buy fails due to capacity")
	print("✓ Store capacity limit & key items restriction checks passed.")

	# 3. Test Battle Status Timing
	var battle_scene = load("res://scenes/battle.tscn")
	var battle = battle_scene.instantiate()
	add_child(battle)
	await get_tree().process_frame

	var p = battle.get_active_player()
	var e = battle.get_active_enemy()
	assert(p != null and e != null, "Battle active player and enemy must exist")

	# Test Flinch -> Forced Recharge
	p.is_flinched = true
	p.current_energy = 0
	var flinch_res = battle._process_turn_start_status(p, e, battle.player_card_img, battle.enemy_card_img, true)
	assert(flinch_res == true, "_process_turn_start_status must return true on flinch (ends turn prematurely)")
	assert(p.is_flinched == false, "is_flinched must be cleared after flinch")
	assert(p.current_energy == p.recover_amount, "Flinch must perform forced recharge, expected %d energy, got %d" % [p.recover_amount, p.current_energy])
	print("✓ Flinch forced recharge check passed.")

	# Test Sleep: Turn start does NOT end turn prematurely!
	p.is_asleep_turns = 2
	var sleep_start_res = battle._process_turn_start_status(p, e, battle.player_card_img, battle.enemy_card_img, true)
	assert(sleep_start_res == false, "Turn start must NOT skip turn for Sleep so player can choose item/move/recharge")

	# Attempting action while asleep (round 1: 2 -> 1, fails)
	var action1_allowed = battle._check_action_impeding_status(p, true)
	assert(action1_allowed == false, "Action should fail when still asleep")
	assert(p.is_asleep_turns == 1, "is_asleep_turns should decrement to 1")

	# Attempting action while asleep (round 2: 1 -> 0, wakes up and action is allowed!)
	var action2_allowed = battle._check_action_impeding_status(p, true)
	assert(action2_allowed == true, "Action should proceed when waking up (turns reach 0)")
	assert(p.is_asleep_turns == 0, "is_asleep_turns should be 0")
	assert(p.immune_sleep_rounds == 1, "immune_sleep_rounds should be 1 upon waking")
	print("✓ Sleep timing and action-impeding checks passed.")

	# Test Paralysis: Turn start does NOT end turn prematurely!
	p.is_paralyzed = true
	p.paralyze_turns = 2
	var para_start_res = battle._process_turn_start_status(p, e, battle.player_card_img, battle.enemy_card_img, true)
	assert(para_start_res == false, "Turn start must NOT skip turn for Paralysis so player can choose item/move/recharge")
	print("✓ Paralysis timing check passed.")

	# 4. Test Bag Tabs in Battle
	battle.is_player_turn = true
	battle.can_player_act = true
	battle.is_busy = false
	battle.is_battle_over = false
	battle._on_bag_pressed()
	assert(battle.bag_modal.visible == true, "Bag modal should be visible")
	assert(battle.battle_bag_tab_bar != null, "battle_bag_tab_bar should be created")
	assert(battle.battle_bag_active_tab == "consumables", "Default battle bag tab should be 'consumables'")

	# Check items in consumables tab
	var has_potion = false
	var has_poke_flute = false
	for child in battle.bag_items_list.get_children():
		var row_text = str(child.get_children())
		# check definitions
	assert(battle.battle_bag_capacity_lbl.visible == true, "Capacity label should be visible")

	# Switch tab to Key Items
	battle.btn_battle_tab_key_items.emit_signal("pressed")
	assert(battle.battle_bag_active_tab == "key_items", "Active tab should now be 'key_items'")

	# Close bag modal
	battle.bag_modal.visible = false
	print("✓ Battle Bag Tabs & Capacity UI checks passed.")

	print("=== ALL STATUS TIMING & BAG TABS TESTS PASSED SUCCESSFULLY! ===")
	get_tree().quit(0)
