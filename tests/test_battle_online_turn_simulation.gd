extends Node

var battle: Node

func _ready() -> void:
	print("--- Starting Full Online Multi-Round Battle Simulation ---")
	GameData.is_campaign_mode = false
	GameData.is_pvp_mode = false
	GameData.is_online_pvp = true
	GameData.online_rival_name = "FastRival"
	# Bulbasaur (0) has speed 45 - SLOWER
	# Charmander (4) has speed 65 - FASTER
	GameData.player_team_ids = [0] # Bulbasaur (SPD 45) - Local Player is SLOWER
	GameData.enemy_team_ids = [4]  # Charmander (SPD 65) - Opponent is FASTER
	
	OnlineManager.is_host = false
	OnlineManager.my_role = "GUEST"
	OnlineManager.room_code = "TEST"
	OnlineManager.is_online_match = true
	
	var battle_scene = load("res://scenes/battle.tscn")
	battle = battle_scene.instantiate()
	add_child(battle)
	OnlineManager.stop_polling()
	
	# Wait 4.0 seconds for round initiative (2.2s start + 1.2s initiative)
	var t = get_tree().create_timer(4.0)
	t.timeout.connect(_on_round1_started)

func _on_round1_started() -> void:
	print("\n=== Step 1: Slower Player Waiting for Faster Opponent in Round 1 ===")
	print("Round number: ", battle.round_number)
	print("Round order: ", battle.round_order)
	print("Round step: ", battle.round_step)
	print("Can player act: ", battle.can_player_act)
	print("Is player turn: ", battle.is_player_turn)
	print("Is busy: ", battle.is_busy)
	print("Turn badge text: ", battle.turn_badge.text)
	
	assert(battle.round_order == ["ENEMY", "PLAYER"], "Enemy must be first")
	assert(not battle.can_player_act, "Player should not act yet")
	
	# Opponent takes action (Action 1)
	print("\n=== Step 2: Opponent Action 1 Arrives (First Attack) ===")
	var enemy = battle.get_active_enemy()
	var enemy_move = enemy.moves[0] if enemy.moves.size() > 0 else null
	var enemy_move_name = enemy_move.name if enemy_move else "Scratch"
	var rival_action_1 = {
		"type": "MOVE",
		"move_name": enemy_move_name,
		"energy_spent": 1,
		"boosted": false,
		"by": "HOST",
		"seq": 1
	}
	print("Feeding opponent action 1: ", rival_action_1)
	battle._on_online_opponent_action(rival_action_1)
	
	# Wait 4.2 seconds for enemy attack animation and transition to player turn
	var t2 = get_tree().create_timer(4.2)
	t2.timeout.connect(_on_player_turn_after_enemy_attack)

func _on_player_turn_after_enemy_attack() -> void:
	print("\n=== Step 3: Local Player's Turn After Opponent Attack ===")
	print("Round number: ", battle.round_number)
	print("Round order: ", battle.round_order)
	print("Round step: ", battle.round_step)
	print("Can player act: ", battle.can_player_act)
	print("Is player turn: ", battle.is_player_turn)
	print("Is busy: ", battle.is_busy)
	print("Turn badge text: ", battle.turn_badge.text)
	
	assert(battle.round_step == 1, "Round step must be 1")
	assert(battle.can_player_act, "Player controls MUST be enabled")
	assert(battle.is_player_turn, "Must be player's turn")
	
	# Local player now counter-attacks (Action 2)
	var p_move = battle.get_active_player().moves[0]
	print("Local player counter-attacking with: ", p_move.name)
	battle.execute_player_move(p_move, false, 1)
	
	# SIMULATE EARLY ACTION ARRIVAL:
	# While local player is still in attack animation / finish round transition (at t = 2.0s),
	# Opponent sends Action 3 for Round 2!
	var t_early = get_tree().create_timer(2.0)
	t_early.timeout.connect(func():
		print("\n=== Step 3.5: [RACE CONDITION TEST] Opponent Action 3 arrives DURING Round 1->2 transition ===")
		var enemy = battle.get_active_enemy()
		var enemy_move = enemy.moves[0] if enemy.moves.size() > 0 else null
		var enemy_move_name = enemy_move.name if enemy_move else "Scratch"
		var rival_action_3 = {
			"type": "MOVE",
			"move_name": enemy_move_name,
			"energy_spent": 1,
			"boosted": false,
			"by": "HOST",
			"seq": 3
		}
		print("Feeding opponent action 3 early into queue: ", rival_action_3)
		battle._on_online_opponent_action(rival_action_3)
		print("Pending queue size immediately after feeding: ", battle.pending_opponent_actions.size())
		assert(battle.pending_opponent_actions.size() == 1, "Action 3 MUST be stored safely in queue")
	)
	
	# Wait 5.0 seconds for counter-attack animation, finish round, and round 2 execution
	var t3 = get_tree().create_timer(5.0)
	t3.timeout.connect(_on_round2_in_progress)

func _on_round2_in_progress() -> void:
	print("\n=== Step 4: Round 2 - Queued Action 3 should now have been processed ===")
	print("Round number: ", battle.round_number)
	print("Round order: ", battle.round_order)
	print("Round step: ", battle.round_step)
	print("Pending opponent actions: ", battle.pending_opponent_actions.size())
	print("Turn badge text: ", battle.turn_badge.text)
	
	assert(battle.round_number == 2, "Must be Round 2")
	# Since Action 3 was dequeued and executed, pending queue should be empty
	assert(battle.pending_opponent_actions.size() == 0, "Queued action 3 should have been consumed")
	
	# Wait 4.5 seconds for Action 3 animation (2.4s) + transition (1.2s) to complete and reach player's turn in Round 2
	var t4 = get_tree().create_timer(4.5)
	t4.timeout.connect(_on_round2_player_turn)

func _on_round2_player_turn() -> void:
	print("\n=== Step 5: Round 2 - Local Player Turn Reached with Zero Freeze ===")
	print("Round number: ", battle.round_number)
	print("Round order: ", battle.round_order)
	print("Round step: ", battle.round_step)
	print("Can player act: ", battle.can_player_act)
	print("Is player turn: ", battle.is_player_turn)
	print("Is busy: ", battle.is_busy)
	print("Turn badge text: ", battle.turn_badge.text)
	
	assert(battle.round_step == 1, "Round step must be 1 (player's turn)")
	assert(battle.can_player_act, "Player controls MUST be enabled for Round 2 attack")
	assert(battle.is_player_turn, "Must be player's turn")
	
	print("\n🏆 RACE CONDITION AND MULTI-ROUND QUEUEING TEST PASSED PERFECTLY!")
	get_tree().quit(0)
