extends Node

var battle: Node

func _ready() -> void:
	print("--- Starting Opponent-First Battle Simulation ---")
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
	
	# Wait 5.0 seconds for round initiative (2.2s start + 2.0s initiative)
	var t = get_tree().create_timer(5.0)
	t.timeout.connect(_on_round1_started)

func _on_round1_started() -> void:
	print("\n=== Step 1: Slower Player Waiting for Faster Opponent ===")
	print("Round number: ", battle.round_number)
	print("Round order: ", battle.round_order)
	print("Round step: ", battle.round_step)
	print("Can player act: ", battle.can_player_act)
	print("Is player turn: ", battle.is_player_turn)
	print("Is busy: ", battle.is_busy)
	print("Turn badge text: ", battle.turn_badge.text)
	
	assert(battle.round_order == ["ENEMY", "PLAYER"], "Enemy must be first")
	assert(not battle.can_player_act, "Player should not act yet")
	
	# Opponent takes action (first attack)
	print("\n=== Step 2: Opponent Action Arrives (First Attack) ===")
	var enemy = battle.get_active_enemy()
	var enemy_move = enemy.moves[0] if enemy.moves.size() > 0 else null
	var enemy_move_name = enemy_move.name if enemy_move else "Scratch"
	var rival_action = {
		"type": "MOVE",
		"move_name": enemy_move_name,
		"energy_spent": 1,
		"boosted": false,
		"by": "HOST",
		"seq": 1
	}
	print("Feeding opponent first attack: ", rival_action)
	battle._on_online_opponent_action(rival_action)
	
	# Wait 5.0 seconds for enemy attack animation and transition to player turn
	var t2 = get_tree().create_timer(5.0)
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
	
	# Local player now counter-attacks
	var p_move = battle.get_active_player().moves[0]
	print("Local player counter-attacking with: ", p_move.name)
	battle.execute_player_move(p_move, false, 1)
	
	# Wait 5.0 seconds for counter-attack animation, finish round, and round 2 start
	var t3 = get_tree().create_timer(5.0)
	t3.timeout.connect(_on_round2_started)

func _on_round2_started() -> void:
	print("\n=== Step 4: Round 2 Initiative ===")
	print("Round number: ", battle.round_number)
	print("Round order: ", battle.round_order)
	print("Round step: ", battle.round_step)
	print("Turn badge text: ", battle.turn_badge.text)
	
	assert(battle.round_number == 2, "Must be Round 2")
	print("🏆 OPPONENT-FIRST BATTLE SIMULATION PASSED PERFECTLY!")
	get_tree().quit(0)
