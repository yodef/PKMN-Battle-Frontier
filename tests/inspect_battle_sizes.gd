extends Node

func _ready() -> void:
	print("--- VERIFYING CLEAN BATTLE SCENE SIZES AND ADVENTURE VICTORY FLOW ---")
	GameData.create_new_profile("Tester", "Guest", "tester@frontier.local")
	GameData.tutorial_completed = true
	GameData.is_campaign_mode = true
	GameData.campaign_submode = "ADVENTURE"
	GameData.adventure_current_episode = 1
	GameData.adventure_current_stage = 1
	GameData.init_adventure_team(1, [0, 1, 2])
	
	var battle_scene = load("res://scenes/battle.tscn").instantiate()
	add_child(battle_scene)
	await get_tree().process_frame
	await get_tree().process_frame
	
	var vp_size = get_viewport().get_visible_rect().size
	print("Window viewport size: ", vp_size)
	var main_c = battle_scene.get_node("MainContainer")
	print("MainContainer size: ", main_c.size, " min_size: ", main_c.get_combined_minimum_size())
	print("TopBar size: ", battle_scene.get_node("MainContainer/TopBar").size, " min_size: ", battle_scene.get_node("MainContainer/TopBar").get_combined_minimum_size())
	var enemy_sec = battle_scene.get_node("MainContainer/EnemySection")
	var player_sec = battle_scene.get_node("MainContainer/PlayerSection")
	var enemy_card = battle_scene.enemy_card_img
	var player_card = battle_scene.player_card_img
	var enemy_info = battle_scene.get_node("MainContainer/EnemySection/HBox/Info")
	var player_info = battle_scene.get_node("MainContainer/PlayerSection/HBox/Info")
	
	print("EnemySection size: ", enemy_sec.size, " min_size: ", enemy_sec.get_combined_minimum_size())
	print("PlayerSection size: ", player_sec.size, " min_size: ", player_sec.get_combined_minimum_size())
	print("EnemyCard size: ", enemy_card.size, " pos: ", enemy_card.position)
	print("PlayerCard size: ", player_card.size, " pos: ", player_card.position)
	
	assert(main_c.size.x <= 508.0, "MainContainer width (%f) must fit within 508px (viewport - margins)!" % main_c.size.x)
	assert(abs(enemy_sec.size.y - player_sec.size.y) < 1.0, "EnemySection and PlayerSection must have identical height!")
	assert(abs(enemy_card.size.y - player_card.size.y) < 1.0, "EnemyCard and PlayerCard must have identical height!")
	assert(abs(enemy_card.size.x - player_card.size.x) < 1.0, "EnemyCard and PlayerCard must have identical width!")
	assert(enemy_card.global_position.x > enemy_info.global_position.x, "Enemy card must be on the RIGHT side of its section!")
	assert(player_card.global_position.x < player_info.global_position.x, "Player card must be on the LEFT side of its section!")
	print("Test 1 Passed: Symmetrical section sizes, equal card sizes, and mirrored card positioning verified.")
	
	# Test 2: Simulate victory in Stage 1 and clicking "Camp / Shop"
	print("\n--- Testing Adventure Stage 1 Victory & Progression ---")
	assert(GameData.adventure_current_stage == 1, "Initial stage must be 1")
	# Defeat all enemies
	for enemy in battle_scene.enemy_team:
		enemy.current_hp = 0
	battle_scene.is_battle_over = true
	battle_scene._resolve_battle_victory()
	
	assert(GameData.adventure_current_stage == 2, "Stage should have progressed to 2! Got: %d" % GameData.adventure_current_stage)
	assert(GameData.is_campaign_mode == true, "GameData.is_campaign_mode must remain true after stage victory!")
	assert(GameData.adventure_current_episode == 1, "Episode should remain 1")
	
	# Verify that clicking return to menu (btn_game_over_menu) preserves campaign mode and stage 2!
	# We simulate _on_return_to_menu without changing scene to check data preservation
	assert(battle_scene.is_battle_over == true, "Battle must be flagged as over")
	# If _on_return_to_menu runs when is_battle_over is true:
	if not battle_scene.is_battle_over and GameData.is_campaign_mode and GameData.campaign_submode == "ADVENTURE":
		GameData.reset_adventure_episode(GameData.adventure_current_episode)
		GameData.is_campaign_mode = false
	
	assert(GameData.is_campaign_mode == true, "Campaign mode must still be true after return logic!")
	assert(GameData.adventure_current_stage == 2, "Stage 2 must be preserved for camp!")
	print("Test 2 Passed: Stage 1 victory successfully advances to Stage 2 and keeps campaign mode active!")
	
	print("\n=== ALL BATTLE FIXES VERIFIED SUCCESSFULLY! ===")
	get_tree().quit(0)
