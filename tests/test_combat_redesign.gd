extends Node

func _ready() -> void:
	print("--- TESTING COMBAT SCREEN REDESIGN & COMPACT SPACING ---")
	var battle_scene = load("res://scenes/battle.tscn")
	var battle = battle_scene.instantiate()
	add_child(battle)
	
	# 1. TopBar should be eliminated from MainContainer
	var top_bar = battle.get_node_or_null("MainContainer/TopBar")
	assert(top_bar == null, "TopBar must be eliminated from MainContainer to save vertical space")
	print("Test 1 Passed: Old TopBar eliminated.")
	
	# 2. BattleTitle should be in EnemyNameRow
	var enemy_row = battle.find_child("EnemyNameRow", true, false)
	assert(enemy_row != null, "EnemyNameRow must exist")
	var battle_title = enemy_row.find_child("BattleTitle", true, false)
	assert(battle_title != null, "BattleTitle must be located in EnemyNameRow")
	print("Test 2 Passed: BattleTitle integrated into EnemyNameRow.")
	
	# 3. NeutralLogPanel contains BtnTypeChart and BtnSpeed
	var neutral_panel = battle.find_child("NeutralLogPanel", true, false)
	assert(neutral_panel != null, "NeutralLogPanel must exist")
	var btn_type_chart = neutral_panel.find_child("BtnTypeChart", true, false)
	var btn_speed = neutral_panel.find_child("BtnSpeed", true, false)
	assert(btn_type_chart != null, "BtnTypeChart must be inside NeutralLogPanel")
	assert(btn_speed != null, "BtnSpeed must be inside NeutralLogPanel")
	print("Test 3 Passed: Types and Speed buttons integrated into NeutralLogPanel.")
	
	# 4. PlayerNameRow contains BtnBackMenu (LEAVE) and BtnSettings
	var player_name_row = battle.find_child("PlayerNameRow", true, false)
	assert(player_name_row != null, "PlayerNameRow must exist")
	var btn_leave = player_name_row.find_child("BtnBackMenu", true, false)
	var btn_settings = player_name_row.find_child("BtnSettings", true, false)
	assert(btn_leave != null, "BtnBackMenu (LEAVE) must be in PlayerNameRow")
	assert(btn_settings != null, "BtnSettings must be in PlayerNameRow")
	print("Test 4 Passed: Leave and Settings buttons integrated into PlayerNameRow.")
	
	# 5. PlayerEnergyRow contains PlayerEnergyLbl, BtnRecover, and BtnBag
	var energy_row = battle.find_child("PlayerEnergyRow", true, false)
	assert(energy_row != null, "PlayerEnergyRow must exist")
	var energy_lbl = energy_row.find_child("PlayerEnergyLbl", true, false)
	var btn_recover = energy_row.find_child("BtnRecover", true, false)
	var btn_bag = energy_row.find_child("BtnBag", true, false)
	assert(energy_lbl != null and btn_recover != null and btn_bag != null, "Energy row must contain label, recharge and bag buttons")
	print("Test 5 Passed: Recharge and Bag buttons integrated into PlayerEnergyRow.")
	
	# 6. Moves have compact horizontal energy slots (HBoxContainer) beneath move buttons
	var move1_slots = battle.find_child("Move1Slots", true, false)
	var move2_slots = battle.find_child("Move2Slots", true, false)
	assert(move1_slots is HBoxContainer, "Move1Slots must be an HBoxContainer horizontally below move button")
	assert(move2_slots is HBoxContainer, "Move2Slots must be an HBoxContainer horizontally below move button")
	print("Test 6 Passed: Compact horizontal energy slots below move buttons verified.")
	
	# 7. Combat logs expanded vertical space
	var enemy_log_lbl = battle.find_child("EnemyLogLabel", true, false)
	var player_log_lbl = battle.find_child("PlayerLogLabel", true, false)
	assert(enemy_log_lbl.custom_minimum_size.y >= 50, "EnemyLogLabel must have expanded height for multi-line logs")
	assert(player_log_lbl.custom_minimum_size.y >= 50, "PlayerLogLabel must have expanded height for multi-line logs")
	print("Test 7 Passed: Expanded combat logs verified.")
	
	print("=== ALL COMBAT REDESIGN TESTS PASSED! ===")
	get_tree().quit(0)
