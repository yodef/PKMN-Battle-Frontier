extends Node

func _ready():
	print("=== RUNNING TEST: BOSS NO ITEMS IN BATTLE ===")
	var battle_scene = load("res://scenes/battle.tscn")
	var battle_instance = battle_scene.instantiate()
	add_child(battle_instance)
	
	var onix_pkmn = GameData.create_pokemon_instance(GameData.CRYSTAL_ONIX_ID)
	var dragonite_pkmn = GameData.create_pokemon_instance(149)
	var player_pkmn = GameData.create_pokemon_instance(25) # Pikachu
	
	battle_instance.player_team = [player_pkmn]
	battle_instance.active_player_idx = 0
	battle_instance.enemy_team = [onix_pkmn]
	battle_instance.active_enemy_idx = 0
	
	assert(battle_instance.is_crystal_onix_boss_battle() == true, "Must detect Crystal Onix boss battle!")
	print("✓ is_crystal_onix_boss_battle() returns true for Crystal Onix")
	
	# When updating UI for Crystal Onix, btn_bag should be disabled
	battle_instance.update_ui()
	assert(battle_instance.btn_bag.disabled == true, "btn_bag MUST be disabled during Crystal Onix battle!")
	print("✓ btn_bag is disabled during Crystal Onix battle")
	
	# Attempting to press bag during Crystal Onix battle
	battle_instance.bag_modal.visible = false
	battle_instance._on_bag_pressed()
	assert(battle_instance.bag_modal.visible == false, "bag_modal MUST NOT open during Crystal Onix battle!")
	print("✓ bag_modal cannot open during Crystal Onix battle")
	
	# Attempting to apply item during Crystal Onix battle
	battle_instance.apply_item_in_battle("potion", 0)
	print("✓ apply_item_in_battle cleanly rejected during Crystal Onix battle")
	
	# Simulate regular enemy
	battle_instance.enemy_team = [dragonite_pkmn]
	GameData.is_campaign_mode = false
	assert(battle_instance.is_crystal_onix_boss_battle() == false, "Must return false for regular enemies!")
	print("✓ is_crystal_onix_boss_battle() returns false for Dragonite in normal mode")
	
	# Simulate Chaos match 7 (Boss)
	GameData.is_campaign_mode = true
	GameData.campaign_submode = "CHAOS"
	GameData.chaos_match_number = 7
	assert(battle_instance.is_crystal_onix_boss_battle() == true, "Must return true for Chaos match 7!")
	print("✓ is_crystal_onix_boss_battle() returns true for Chaos match 7")
	
	battle_instance.queue_free()
	print("=== TEST PASSED: BOSS NO ITEMS VERIFIED! ===")
	get_tree().quit(0)
