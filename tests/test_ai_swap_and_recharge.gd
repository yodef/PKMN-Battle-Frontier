extends Node

func _ready() -> void:
	print("=== STARTING AI SWAP & RECHARGE RESTRICTION TEST SUITE ===")
	
	test_crystal_onix_weakness_none()
	test_elemental_disadvantage_detection()
	test_ai_swap_when_at_disadvantage()
	test_ai_no_swap_when_safe_or_trapped()
	test_ai_recharge_restriction_above_30_percent()
	test_ai_recharge_allowed_at_or_below_30_percent()
	
	print("\n=== ALL AI SWAP & RECHARGE TESTS PASSED SUCCESSFULLY! ===")
	get_tree().quit(0)

func test_crystal_onix_weakness_none() -> void:
	print("\n--- Testing Crystal Onix Weakness NONE ---")
	var onix_data = GameData.pokemon_catalog.get(GameData.CRYSTAL_ONIX_ID, {})
	assert(not onix_data.is_empty(), "Crystal Onix must exist in catalog!")
	assert(str(onix_data.get("weakness")) == "NONE", "Crystal Onix weakness must be NONE! Got: %s" % str(onix_data.get("weakness")))
	print("✓ Crystal Onix weakness verified as NONE in catalog!")

func test_elemental_disadvantage_detection() -> void:
	print("\n--- Testing Elemental Disadvantage Function ---")
	var battle_scene = preload("res://scenes/battle.tscn").instantiate()
	add_child(battle_scene)
	
	# Bulbasaur (GRASS, weakness FIRE) vs Charmander (FIRE)
	var bulbasaur = GameData.create_pokemon_instance(0)
	var charmander = GameData.create_pokemon_instance(1)
	var squirtle = GameData.create_pokemon_instance(2)
	var pikachu = GameData.create_pokemon_instance(25)
	
	assert(battle_scene.is_pokemon_at_elemental_disadvantage(bulbasaur, charmander) == true, "Bulbasaur must be at disadvantage vs Charmander!")
	assert(battle_scene.is_pokemon_at_elemental_disadvantage(charmander, squirtle) == true, "Charmander must be at disadvantage vs Squirtle!")
	assert(battle_scene.is_pokemon_at_elemental_disadvantage(squirtle, pikachu) == true, "Squirtle must be at disadvantage vs Pikachu (Electric)!")
	assert(battle_scene.is_pokemon_at_elemental_disadvantage(squirtle, charmander) == false, "Squirtle is NOT at disadvantage vs Charmander!")
	
	# Crystal Onix (ROCK, weakness NONE)
	var crystal_onix = GameData.create_pokemon_instance(GameData.CRYSTAL_ONIX_ID)
	assert(battle_scene.is_pokemon_at_elemental_disadvantage(crystal_onix, charmander) == false, "Crystal Onix (weakness NONE) is not at disadvantage vs Charmander!")
	assert(battle_scene.is_pokemon_at_elemental_disadvantage(crystal_onix, squirtle) == false, "Crystal Onix (weakness NONE) is not at disadvantage vs Squirtle!")
	
	battle_scene.queue_free()
	print("✓ Elemental disadvantage correctly detects weaknesses and ignores NONE!")

func test_ai_swap_when_at_disadvantage() -> void:
	print("\n--- Testing AI Swaps Out when at Disadvantage with Safe Bench ---")
	var battle_scene = preload("res://scenes/battle.tscn").instantiate()
	add_child(battle_scene)
	
	GameData.is_pvp_mode = false
	GameData.is_online_pvp = false
	GameData.is_tutorial_mode = false
	
	# Player is Charmander (FIRE)
	# Enemy is Bulbasaur (GRASS, weak to FIRE) with Squirtle (WATER, not weak to FIRE) on bench!
	var p_charmander = GameData.create_pokemon_instance(1)
	var e_bulbasaur = GameData.create_pokemon_instance(0)
	var e_squirtle = GameData.create_pokemon_instance(2)
	
	battle_scene.player_team = [p_charmander]
	battle_scene.enemy_team = [e_bulbasaur, e_squirtle]
	battle_scene.active_player_idx = 0
	battle_scene.active_enemy_idx = 0 # Bulbasaur is active
	battle_scene.round_number = 1
	battle_scene.last_enemy_switch_round = -1
	
	assert(battle_scene.get_active_enemy() == e_bulbasaur, "Active enemy starts as Bulbasaur")
	
	# Execute AI turn: Bulbasaur is weak to Charmander, Squirtle is on bench and not weak to Fire
	battle_scene.execute_enemy_ai()
	
	# Verify that active enemy swapped to Squirtle!
	assert(battle_scene.active_enemy_idx == 1, "AI must have switched to Squirtle (idx 1)! Got: %d" % battle_scene.active_enemy_idx)
	assert(battle_scene.get_active_enemy() == e_squirtle, "Active enemy must now be Squirtle!")
	
	battle_scene.queue_free()
	print("✓ AI successfully executed tactical switch when at elemental disadvantage!")

func test_ai_no_swap_when_safe_or_trapped() -> void:
	print("\n--- Testing AI Does NOT Swap when Bench is Also Weak or Trapped ---")
	var battle_scene = preload("res://scenes/battle.tscn").instantiate()
	add_child(battle_scene)
	
	GameData.is_pvp_mode = false
	GameData.is_online_pvp = false
	
	# Case A: Bench is ALSO weak to fire (e.g. Bulbasaur with Bellsprout on bench)
	var p_fire = GameData.create_pokemon_instance(1) # Charmander
	var e_grass1 = GameData.create_pokemon_instance(0) # Bulbasaur
	var e_grass2 = GameData.create_pokemon_instance(72) # Bellsprout (Grass, weak to Fire)
	
	battle_scene.player_team = [p_fire]
	battle_scene.enemy_team = [e_grass1, e_grass2]
	battle_scene.active_player_idx = 0
	battle_scene.active_enemy_idx = 0
	battle_scene.round_number = 1
	battle_scene.last_enemy_switch_round = -1
	
	battle_scene.execute_enemy_ai()
	assert(battle_scene.active_enemy_idx == 0, "AI must NOT switch if bench Pokémon is also weak to player!")
	
	# Case B: Trapped by Constrict
	e_grass1.is_constricted_dmg = 2
	var e_water = GameData.create_pokemon_instance(2) # Squirtle
	battle_scene.enemy_team = [e_grass1, e_water]
	battle_scene.active_enemy_idx = 0
	battle_scene.last_enemy_switch_round = -1
	
	battle_scene.execute_enemy_ai()
	assert(battle_scene.active_enemy_idx == 0, "AI must NOT switch while trapped by constriction!")
	
	battle_scene.queue_free()
	print("✓ AI avoids swapping when no safe bench candidate exists or when constricted!")

func test_ai_recharge_restriction_above_30_percent() -> void:
	print("\n--- Testing AI Never Recharges when Energy > 30% ---")
	var battle_scene = preload("res://scenes/battle.tscn").instantiate()
	add_child(battle_scene)
	
	GameData.is_pvp_mode = false
	GameData.is_online_pvp = false
	
	var p = GameData.create_pokemon_instance(0)
	var e = GameData.create_pokemon_instance(1) # Charmander, max_energy = 3, recover = 2
	# Let's give e 2 energy out of 3 (66% energy > 30%)
	e.current_energy = 2
	
	battle_scene.player_team = [p]
	battle_scene.enemy_team = [e]
	battle_scene.active_player_idx = 0
	battle_scene.active_enemy_idx = 0
	
	var initial_energy = e.current_energy
	var initial_player_hp = p.current_hp
	
	# If enemy_do_recover is invoked when energy > 30%, it should intercept and attack instead of recharging
	battle_scene.enemy_do_recover()
	
	# Energy should NOT have increased by recover (+2)
	assert(e.current_energy <= initial_energy, "AI must NOT recharge energy when above 30 percent! Current: %d, Initial: %d" % [e.current_energy, initial_energy])
	assert(p.current_hp < initial_player_hp, "AI must have attacked instead of recharging! Player HP: %d (was %d)" % [p.current_hp, initial_player_hp])
	
	battle_scene.queue_free()
	print("✓ AI above 30% energy correctly diverted from Recharge into attacking!")

func test_ai_recharge_allowed_at_or_below_30_percent() -> void:
	print("\n--- Testing AI Recharges Normally when Energy <= 30% ---")
	var battle_scene = preload("res://scenes/battle.tscn").instantiate()
	add_child(battle_scene)
	
	var p = GameData.create_pokemon_instance(0)
	var e = GameData.create_pokemon_instance(1) # Charmander, max_energy = 3, recover = 2
	# 0 energy out of 3 = 0% <= 30%
	e.current_energy = 0
	
	battle_scene.player_team = [p]
	battle_scene.enemy_team = [e]
	battle_scene.active_player_idx = 0
	battle_scene.active_enemy_idx = 0
	
	battle_scene.enemy_do_recover()
	assert(e.current_energy == 2, "AI must recharge +2 energy when at zero energy! Got: %d" % e.current_energy)
	
	battle_scene.queue_free()
	print("✓ AI at or below 30% energy recharges normally!")
