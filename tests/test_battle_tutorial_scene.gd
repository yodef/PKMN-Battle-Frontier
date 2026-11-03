extends Node

func _ready() -> void:
	print("--- BEGIN BATTLE TUTORIAL SCENE INTEGRATION TEST ---")
	GameData.is_tutorial_mode = true
	var battle_scene = load("res://scenes/battle.tscn").instantiate()
	add_child(battle_scene)
	await get_tree().process_frame
	await get_tree().process_frame
	
	assert(battle_scene.player_team.size() == 1, "Player team should have exactly 1 Pokemon")
	assert(battle_scene.enemy_team.size() == 1, "Enemy team should have exactly 1 Pokemon")
	assert(battle_scene.player_team[0].name == "Charmander", "Player Pokemon should be Charmander")
	assert(battle_scene.enemy_team[0].name == "Bulbasaur", "Enemy Pokemon should be Bulbasaur")
	
	# Verify tutorial modal setup
	battle_scene._setup_tutorial_callout_modal()
	assert(battle_scene.tutorial_callout_modal != null, "Tutorial callout modal should be created")
	assert(battle_scene.tutorial_callout_title_lbl != null, "Tutorial callout title label should be created")
	assert(battle_scene.tutorial_callout_text_lbl != null, "Tutorial callout text label should be created")
	assert(battle_scene.btn_tutorial_callout_next != null, "Tutorial callout next button should be created")
	
	# Verify show callout
	var tracker = {"called": false}
	battle_scene._show_tutorial_callout(
		"test_step",
		"TEST • STEP 1",
		"Test Title",
		"Test content text",
		"Got It! ➡️",
		func(): tracker["called"] = true
	)
	assert(battle_scene.tutorial_callout_modal.visible, "Modal must be visible when shown")
	assert(battle_scene.tutorial_callout_title_lbl.text == "Test Title", "Title should match")
	
	# Simulate pressing next
	battle_scene._on_tutorial_callout_next_pressed()
	assert(not battle_scene.tutorial_callout_modal.visible, "Modal should hide after next")
	assert(tracker["called"] == true, "Callback must be invoked on next")
	
	print("=== BATTLE TUTORIAL SCENE INTEGRATION TEST PASSED! ===")
	get_tree().quit(0)
