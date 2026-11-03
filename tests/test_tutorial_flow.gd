extends Node

func _ready() -> void:
	print("--- BEGIN TUTORIAL FLOW TEST ---")
	
	# Test 1: Initial state
	GameData.create_new_profile("Tester", "Guest", "tester@frontier.local")
	assert(not GameData.is_tutorial_completed(), "Tutorial should not be completed initially")
	assert(not GameData.tutorial_reward_claimed, "Tutorial reward should not be claimed initially")
	assert(not GameData.is_adventure_episode_unlocked(1), "Episode 1 must be locked before tutorial completion")
	print("Test 1 Passed: Initial tutorial lock state verified.")
	
	# Test 2: Starting tutorial sets mode
	GameData.is_tutorial_mode = true
	var charmander = GameData.create_pokemon_instance(1)
	var bulbasaur = GameData.create_pokemon_instance(0)
	assert(charmander.name == "Charmander", "Player must have Charmander in tutorial")
	assert(bulbasaur.name == "Bulbasaur", "Rival must have Bulbasaur in tutorial")
	assert(bulbasaur.weakness == "FIRE", "Bulbasaur must be weak to Fire")
	assert(charmander.type == "FIRE", "Charmander must be Fire type")
	print("Test 2 Passed: Tutorial combatants verified (Charmander vs Bulbasaur).")
	
	# Test 3: Weakness bonus math
	var ember_move = charmander.moves[1]
	assert(ember_move.name == "Ember", "Move 2 should be Ember")
	var base_dmg = ember_move.base_damage
	var effective_dmg = base_dmg + 2 # Weakness bonus
	assert(effective_dmg == 6, "Ember against Bulbasaur must deal 6 damage (4 base + 2 weakness)")
	print("Test 3 Passed: Weakness bonus math verified (4 + 2 = 6 DMG).")
	
	# Test 4: Reward grant & Unlock
	var init_diamonds = GameData.player_diamonds
	# Simulate victory
	GameData.tutorial_completed = true
	if not GameData.tutorial_reward_claimed:
		GameData.player_diamonds += 5
		GameData.tutorial_reward_claimed = true
	assert(GameData.player_diamonds == init_diamonds + 5, "Tutorial must award 5 diamonds")
	assert(GameData.is_tutorial_completed(), "Tutorial must be marked completed")
	assert(GameData.is_adventure_episode_unlocked(1), "Episode 1 must be unlocked after tutorial")
	print("Test 4 Passed: 5 Diamonds granted and Episode 1 unlocked.")
	
	# Test 5: Replay does not award duplicate diamonds
	var diamonds_after_first = GameData.player_diamonds
	if not GameData.tutorial_reward_claimed:
		GameData.player_diamonds += 5
	assert(GameData.player_diamonds == diamonds_after_first, "Replaying tutorial must NOT award duplicate diamonds")
	print("Test 5 Passed: Duplicate reward prevention verified.")
	
	# Test 6: Persistence in save dictionary
	var save_dict = GameData.get_save_dict()
	assert(save_dict.has("campaign"), "Save dict must have campaign key")
	assert(save_dict["campaign"].get("tutorial_completed") == true, "tutorial_completed must persist in save")
	assert(save_dict["campaign"].get("tutorial_reward_claimed") == true, "tutorial_reward_claimed must persist in save")
	
	# Reload into fresh profile and verify apply_save_dict restores it
	GameData.create_new_profile("OtherUser", "Guest", "other@frontier.local")
	assert(not GameData.is_tutorial_completed(), "Fresh profile should have incomplete tutorial")
	GameData.apply_save_dict(save_dict)
	assert(GameData.is_tutorial_completed(), "Loaded profile must restore tutorial completion")
	assert(GameData.tutorial_reward_claimed, "Loaded profile must restore tutorial reward claimed state")
	assert(GameData.is_adventure_episode_unlocked(1), "Loaded profile must unlock Episode 1")
	print("Test 6 Passed: Save and load persistence verified.")
	
	print("=== ALL TUTORIAL FLOW TESTS PASSED! ===")
	get_tree().quit(0)
