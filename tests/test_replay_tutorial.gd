extends Control

func _ready() -> void:
	print("--- TEST REPLAY TUTORIAL WHEN ALREADY COMPLETED ---")
	GameData.tutorial_completed = true
	GameData.tutorial_reward_claimed = true
	GameData.tutorial_step = 6
	GameData.tutorial_starter_id = 1 # Charmander
	GameData.tutorial_stage1_id = 6 # Charmeleon
	GameData.tutorial_rival_id = 0 # Bulbasaur
	GameData.tutorial_rival_stage1_id = 4 # Ivysaur
	GameData.save_profile()
	
	var main_scene = load("res://scenes/main_menu.tscn").instantiate()
	add_child(main_scene)
	
	print("Opening Campaign Hub...")
	main_scene._on_campaign_pressed()
	print("Campaign Hub opened. Replay tutorial button text: ", main_scene.btn_hub_tutorial.text)
	
	print("Pressing Replay Tutorial...")
	main_scene._on_hub_tutorial_pressed()
	
	print("Confirming Replay Tutorial...")
	main_scene._on_confirm_start_tutorial_pressed()
	
	print("GameData.is_tutorial_mode: ", GameData.is_tutorial_mode)
	print("GameData.tutorial_combat_phase: ", GameData.tutorial_combat_phase)
	print("GameData.tutorial_starter_id: ", GameData.tutorial_starter_id)
	
	print("Now loading battle.tscn...")
	var battle_scene = load("res://scenes/battle.tscn").instantiate()
	add_child(battle_scene)
	print("Battle Scene Title: ", battle_scene.battle_title_lbl.text)
	print("Player team: ", battle_scene.player_team.size())
	for p in battle_scene.player_team:
		print("  Player: ", p.name, " (HP: ", p.current_hp, "/", p.max_hp, ")")
	print("Enemy team: ", battle_scene.enemy_team.size())
	for e in battle_scene.enemy_team:
		print("  Enemy: ", e.name, " (HP: ", e.current_hp, "/", e.max_hp, ")")
		
	print("Executing turn 1...")
	battle_scene.execute_round_turn()
	print("--- TEST END ---")
	get_tree().quit(0)
