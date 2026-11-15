extends Node

func _ready() -> void:
	print("--- TESTING ENEMY CARD POSITION DURING AND AFTER DAMAGE HIT ---")
	var battle_scene = load("res://scenes/battle.tscn")
	var battle = battle_scene.instantiate()
	add_child(battle)
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	var enemy_hbox = battle.find_child("HBox", true, false)
	var enemy_card = battle.find_child("EnemyCard", true, false)
	var enemy_info = battle.get_node_or_null("MainContainer/EnemySection/HBox/Info")
	
	assert(enemy_card != null, "EnemyCard must exist")
	assert(enemy_info != null, "EnemyInfo must exist")
	
	# Verify child order in HBox: Info first (left), EnemyCard second (right)
	assert(enemy_info.get_index() < enemy_card.get_index(), "EnemyCard must be situated to the right of Info in HBox")
	
	# Initial position should have x > 0 (on the right)
	var initial_x = enemy_card.position.x
	print("Initial EnemyCard position.x: ", initial_x)
	assert(initial_x > 100, "EnemyCard position.x must be on the right side (> 100px)")
	
	# Simulate Blizzard / Ice attack hit
	battle.play_damage_hit(enemy_card, "WATER", 16)
	
	# Wait for hit tween to finish (approx 0.35s)
	await get_tree().create_timer(0.45).timeout
	
	print("Post-hit EnemyCard position.x: ", enemy_card.position.x)
	assert(enemy_card.position.x > 100, "EnemyCard must NOT move or stick to x=0 after taking damage/freeze hit!")
	
	print("=== ENEMY CARD POSITION & DAMAGE HIT TEST PASSED! ===")
	get_tree().quit(0)
