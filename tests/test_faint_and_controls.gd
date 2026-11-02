extends Node

func _ready() -> void:
	print("==================================================")
	print("STARTING TEST: FAINT ANIMATION & TURN CONTROLS LOCK")
	print("==================================================")
	
	var battle_scene = load("res://scenes/battle.tscn")
	assert(battle_scene != null, "Failed to load battle scene")
	
	var battle = battle_scene.instantiate()
	add_child(battle)
	
	# Give the scene a frame to initialize
	await get_tree().process_frame
	
	print("1. Verifying initial controls state before player turn")
	# At battle start, controls should be strictly disabled
	assert(battle.can_player_act == false, "can_player_act should be false before round turn")
	assert(battle._is_turn_action_allowed() == false, "Turn action should not be allowed during initiative calculation")
	assert(battle.btn_move1.disabled == true, "Move 1 button should be disabled")
	assert(battle.btn_move2.disabled == true, "Move 2 button should be disabled")
	assert(battle.btn_recover.disabled == true, "Recover button should be disabled")
	print("   ✓ Initial controls locked successfully!")
	
	print("2. Verifying controls unlock ONLY when player's turn starts")
	battle.start_player_turn()
	assert(battle.can_player_act == true, "can_player_act should be true on player turn")
	assert(battle.is_player_turn == true, "is_player_turn should be true")
	assert(battle._is_turn_action_allowed() == true, "Turn action should be allowed on player turn")
	print("   ✓ Controls enabled on player turn successfully!")
	
	print("3. Verifying controls immediately lock when ending player turn")
	battle.end_player_turn()
	assert(battle.can_player_act == false, "can_player_act should be false after end_player_turn")
	assert(battle.is_player_turn == false, "is_player_turn should be false after end_player_turn")
	assert(battle._is_turn_action_allowed() == false, "Turn action should not be allowed after end_player_turn")
	assert(battle.btn_move1.disabled == true, "Move 1 should be disabled after end_player_turn")
	print("   ✓ Controls locked immediately on turn end!")
	
	print("4. Verifying controls remain strictly locked during enemy turn")
	battle.start_enemy_turn()
	assert(battle.can_player_act == false, "can_player_act must be false on enemy turn")
	assert(battle.is_player_turn == false, "is_player_turn must be false on enemy turn")
	assert(battle._is_turn_action_allowed() == false, "Turn action must NOT be allowed during enemy turn")
	assert(battle.btn_move1.disabled == true, "Move 1 must remain disabled during enemy turn")
	assert(battle.btn_recover.disabled == true, "Recover must remain disabled during enemy turn")
	print("   ✓ Controls strictly locked during enemy turn!")
	
	print("5. Verifying Faint (KO) animation & replacement transition")
	# Setup enemy team with 2 Pokémon so one faints and the second enters
	var active_e = battle.get_active_enemy()
	var initial_e_name = active_e.name
	var initial_e_idx = battle.active_enemy_idx
	print("   Initial Enemy: %s (idx: %d, HP: %d)" % [initial_e_name, initial_e_idx, active_e.current_hp])
	
	# Set enemy HP to 0 to trigger faint
	active_e.current_hp = 0
	var triggered = battle.check_active_faint()
	assert(triggered == true, "check_active_faint should trigger faint animation")
	assert(battle.is_enemy_fainting == true, "is_enemy_fainting flag must be true")
	assert(battle.is_busy == true, "is_busy flag must be true during faint animation")
	assert(battle._is_turn_action_allowed() == false, "No controls allowed during faint animation")
	print("   ✓ Faint animation triggered: enemy is fading/sinking, controls locked.")
	
	# Wait for faint tween (0.52s) + entrance tween (0.38s) to complete
	print("   Waiting for faint & entrance animation tweens...")
	await get_tree().create_timer(1.1).timeout
	
	assert(battle.is_enemy_fainting == false, "is_enemy_fainting should be false after replacement enters")
	var new_e = battle.get_active_enemy()
	print("   New Active Enemy: %s (idx: %d, HP: %d/%d)" % [new_e.name, battle.active_enemy_idx, new_e.current_hp, new_e.max_hp])
	assert(battle.active_enemy_idx != initial_e_idx, "Active enemy index should have switched to replacement")
	assert(battle.enemy_card_img.modulate.a > 0.9, "New enemy card modulate alpha should be restored to visible")
	print("   ✓ Replacement Pokémon successfully entered the field with animation!")
	
	print("6. Verifying Final Faint (KO) triggering Victory flow cleanly")
	# Eliminate remaining enemy team members so this is the final KO
	for enemy in battle.enemy_team:
		enemy.current_hp = 0
	var final_triggered = battle.check_active_faint()
	assert(final_triggered == true, "Final faint should trigger")
	assert(battle.is_enemy_fainting == true, "Final enemy should be fainting")
	assert(battle.is_battle_over == true, "Battle should be marked as over")
	print("   Waiting for final faint animation and victory screen...")
	await get_tree().create_timer(0.8).timeout
	assert(battle.game_over_panel.visible == true, "Game over panel should now be visible after faint completes")
	print("   ✓ Final faint played smoothly and game over modal displayed correctly!")
	
	print("==================================================")
	print("ALL FAINT & CONTROLS TESTS COMPLETED (100% OK)")
	print("==================================================")
	
	print("==================================================")
	print("ALL FAINT & CONTROLS TESTS COMPLETED (100% OK)")
	print("==================================================")
	get_tree().quit(0)
