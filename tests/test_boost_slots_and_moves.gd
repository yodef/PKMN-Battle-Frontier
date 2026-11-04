extends Node

func _ready() -> void:
	print("--- Running Test: Boost Slots Direct Display & Thematic Moves Boost ---")
	
	GameData.is_campaign_mode = false
	GameData.is_tutorial_mode = false
	GameData.is_online_pvp = false
	
	# Verify newly boosted moves in catalog:
	var wg = GameData.get_move_data("Water Gun")
	assert(wg.get("boost_cost", 0) == 1, "Water Gun must have boost_cost 1, got %d" % wg.get("boost_cost", 0))
	assert(wg.get("boost_dmg", 0) == 3, "Water Gun must have boost_dmg 3, got %d" % wg.get("boost_dmg", 0))
	print("✅ Water Gun verified in catalog: cost=%d, boost_cost=%d, boost_dmg=%d" % [wg.cost, wg.boost_cost, wg.boost_dmg])
	
	var psy = GameData.get_move_data("Psychic")
	assert(psy.get("boost_cost", 0) == 1, "Psychic must have boost_cost 1, got %d" % psy.get("boost_cost", 0))
	assert(psy.get("boost_dmg", 0) == 4, "Psychic must have boost_dmg 4, got %d" % psy.get("boost_dmg", 0))
	print("✅ Psychic verified in catalog: cost=%d, boost_cost=%d, boost_dmg=%d" % [psy.cost, psy.boost_cost, psy.boost_dmg])

	var tb = GameData.get_move_data("Thunderbolt")
	assert(tb.get("boost_cost", 0) == 1, "Thunderbolt must have boost_cost 1, got %d" % tb.get("boost_cost", 0))
	assert(tb.get("boost_dmg", 0) == 4, "Thunderbolt must have boost_dmg 4, got %d" % tb.get("boost_dmg", 0))
	print("✅ Thunderbolt verified in catalog: cost=%d, boost_cost=%d, boost_dmg=%d" % [tb.cost, tb.boost_cost, tb.boost_dmg])
	
	var eq = GameData.get_move_data("Earthquake")
	assert(eq.get("boost_cost", 0) == 1, "Earthquake must have boost_cost 1, got %d" % eq.get("boost_cost", 0))
	assert(eq.get("boost_dmg", 0) == 4, "Earthquake must have boost_dmg 4, got %d" % eq.get("boost_dmg", 0))
	print("✅ Earthquake verified in catalog: cost=%d, boost_cost=%d, boost_dmg=%d" % [eq.cost, eq.boost_cost, eq.boost_dmg])
	
	# Instantiate Battle scene:
	var battle_scene = load("res://scenes/battle.tscn")
	assert(battle_scene != null, "scenes/battle.tscn must load")
	var battle = battle_scene.instantiate()
	add_child(battle)
	
	# Verify ChkBoost is hidden
	assert(not battle.chk_boost.visible, "chk_boost must be hidden (visible == false)")
	print("✅ chk_boost is completely hidden from UI")
	
	var player = battle.get_active_player()
	var enemy = battle.get_active_enemy()
	
	# Give player a Pokemon with Water Gun: Psyduck (ID 57 in catalog)
	# Water Gun: cost 1, min 1, boost_cost 1 -> boost slot is 2 (🔥2)
	var psyduck = GameData.create_pokemon_instance(57)
	battle.player_team = [psyduck]
	battle.active_player_idx = 0
	player = psyduck
	
	player.current_energy = 5
	battle.reset_selected_energy()
	battle.update_move_button_labels()
	
	# Verify Move 1 (Water Gun) has 2 slot buttons: [1⚡] and [🔥2]
	var slots = battle.move1_slots.get_children()
	for s in slots:
		if s is Button:
			print("Found slot button: '%s'" % s.text)
	# First child is "Req: 1⚡" Label
	assert(slots.size() >= 3, "Slots container must have Label + at least 2 slot buttons for Water Gun, got %d" % slots.size())
	var slot1 = slots[1]
	var slot2 = slots[2]
	assert(slot1.text == "1⚡", "First slot must be 1⚡, got: %s" % slot1.text)
	assert(slot2.text.contains("🔥2"), "Second slot must be boost slot 🔥2, got: %s" % slot2.text)
	print("✅ Boost slot 🔥2 directly appeared without needing any checkbox! (Slots: [%s] [%s])" % [slot1.text, slot2.text])
	
	# Verify default selection is 1⚡ (not boosted by default)
	assert(battle.selected_energy_move1 == 1, "Default selection must be base cost 1⚡, got: %d" % battle.selected_energy_move1)
	assert(not battle.btn_move1.text.contains("BOOSTED"), "Move button must not say BOOSTED by default")
	
	# Click the 🔥2 slot button:
	slot2.pressed.emit()
	assert(battle.selected_energy_move1 == 2, "After clicking 🔥2, selected_energy_move1 must be 2, got: %d" % battle.selected_energy_move1)
	assert(battle.btn_move1.text.contains("BOOSTED 🔥"), "Move button must now show [BOOSTED 🔥]")
	print("✅ Selecting 🔥2 slot activates [BOOSTED 🔥] on attack button: %s" % battle.btn_move1.text.split("\n")[0])
	
	# Verify clicking 1⚡ switches it back:
	slot1.pressed.emit()
	assert(battle.selected_energy_move1 == 1, "After clicking 1⚡, selected_energy_move1 must be 1")
	assert(not battle.btn_move1.text.contains("BOOSTED"), "Move button must revert to normal")
	print("✅ Clicking 1⚡ reverts move back to unboosted")
	
	# Verify when player energy is 1 (cannot afford boost):
	player.current_energy = 1
	battle.update_move_button_labels()
	var slots_low = battle.move1_slots.get_children()
	var slot2_low = slots_low[2]
	assert(slot2_low.disabled, "Boost slot 🔥2 must be disabled when player only has 1 energy")
	print("✅ Boost slot is visible but disabled when player cannot afford the boost cost")
	
	print("🎉 ALL BOOST SLOTS AND MOVE TESTS PASSED SUCCESSFULLY!")
	get_tree().quit(0)
