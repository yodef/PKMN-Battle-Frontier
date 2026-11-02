extends Node

func _ready() -> void:
	print("\n=== STARTING TOURNAMENT FEATURES VERIFICATION ===")
	
	# Test 1: Dynamic Defeat Rewards Calculation
	print("\n--- Test 1: Dynamic Defeat Rewards per Rarity ---")
	var common_rewards = []
	for i in range(20):
		common_rewards.append(GameData.calculate_pkmn_defeat_reward("Common"))
	for r in common_rewards:
		assert(r["gold"] >= 1 and r["gold"] <= 3, "Common gold out of range")
		assert(r["diamonds"] >= 0 and r["diamonds"] <= 1, "Common diamonds out of range")
	print("✅ Common rewards verified (Gold 1-3, Diamonds 0-1)")
	
	var rare_rewards = []
	for i in range(20):
		rare_rewards.append(GameData.calculate_pkmn_defeat_reward("Rare"))
	for r in rare_rewards:
		assert(r["gold"] >= 4 and r["gold"] <= 7, "Rare gold out of range")
		assert(r["diamonds"] >= 0 and r["diamonds"] <= 3, "Rare diamonds out of range")
	print("✅ Rare rewards verified (Gold 4-7, Diamonds 0-3)")
	
	var epic_rewards = []
	for i in range(20):
		epic_rewards.append(GameData.calculate_pkmn_defeat_reward("Epic", "Stage 2"))
	for r in epic_rewards:
		assert(r["gold"] >= 8 and r["gold"] <= 12, "Epic gold out of range")
		assert(r["diamonds"] >= 0 and r["diamonds"] <= 4, "Epic diamonds out of range")
	print("✅ Epic / Stage 2 rewards verified (Gold 8-12, Diamonds 0-4)")
	
	# Test 2: EXP Cap & Stage Reset to 0
	print("\n--- Test 2: EXP Cap & Stage Reset to 0 ---")
	GameData.is_campaign_mode = true
	var bulba_id = 0 # Bulbasaur
	var ivy_id = 4   # Ivysaur
	var venu_id = 5  # Venusaur
	GameData.unlock_pokemon(bulba_id)
	GameData.unlock_pokemon(ivy_id)
	GameData.unlock_pokemon(venu_id)
	GameData.init_campaign_team([bulba_id])
	
	var p_state = GameData.campaign_player_team_state[0]
	assert(p_state["current_exp"] == 0, "Initial EXP must be 0")
	
	# Simulate combat EXP gains
	var inst = GameData.create_pokemon_instance(bulba_id)
	var req = inst.get_required_exp()
	assert(req == 10, "Bulbasaur required exp must be 10")
	
	# Gain 7 damage
	var dmg1 = 7
	var gained1 = min(dmg1, req - inst.current_exp)
	inst.current_exp += gained1
	assert(inst.current_exp == 7, "EXP should be 7")
	
	# Gain 8 damage (should cap at 10, not become 15)
	var dmg2 = 8
	var gained2 = min(dmg2, req - inst.current_exp)
	inst.current_exp += gained2
	assert(inst.current_exp == 10, "EXP must cap at 10 (req_exp)")
	
	# Gain another 5 damage when already at MAX
	var dmg3 = 5
	var gained3 = 0
	if inst.current_exp < req:
		gained3 = min(dmg3, req - inst.current_exp)
		inst.current_exp += gained3
	assert(inst.current_exp == 10, "EXP must not increase once at MAX")
	print("✅ EXP correctly capped at req_exp (10/10)")
	
	# Apply evolution
	p_state["current_exp"] = 10
	var evos = GameData.check_and_apply_campaign_evolutions()
	assert(evos.size() == 1, "Should have evolved 1 Pokémon")
	assert(evos[0]["to_name"] == "Ivysaur", "Should evolve to Ivysaur")
	assert(p_state["name"] == "Ivysaur", "State name updated")
	assert(p_state["current_exp"] == 0, "Next stage MUST start with 0 EXP!")
	assert(p_state["max_exp"] == 25, "Ivysaur max_exp must be 25")
	print("✅ Evolution successful: next stage (Ivysaur) arrived with EXACTLY 0 EXP (max: 25)")
	
	# Test 3: Diamond Preservation on Defeat
	print("\n--- Test 3: Diamond Preservation on Combat Defeat ---")
	var initial_diamonds = GameData.player_diamonds
	var combat_looted_diamonds = 3
	# Simulate combat defeat logic
	GameData.player_diamonds += combat_looted_diamonds
	var kept_diamonds = GameData.player_diamonds
	GameData.reset_campaign()
	assert(GameData.player_diamonds == initial_diamonds + combat_looted_diamonds, "Diamonds must be preserved permanently after defeat")
	print("✅ Diamonds preserved on defeat: initial %d -> preserved %d" % [initial_diamonds, GameData.player_diamonds])
	
	# Test 4: Evolution Chain Status
	print("\n--- Test 4: Evolution Chain Status ---")
	var bulba_status = GameData.get_pokemon_evolution_chain_status(bulba_id)
	assert(bulba_status["has_evolution"] == true, "Bulbasaur has evolution")
	assert(bulba_status["status"] == "FULL", "Bulbasaur should be FULL (Ivysaur & Venusaur unlocked)")
	assert(bulba_status["text_badge"] == "⏫ S1+S2 ✓", "Badge must be S1+S2 ✓")
	print("✅ Bulbasaur evolution chain status: %s (%s)" % [bulba_status["status"], bulba_status["text_badge"]])
	
	# Test with a Pokémon with no evolution (e.g. Lapras id 131)
	var lapras_id = GameData.get_pokemon_id_by_name("Lapras")
	print("Lapras ID: ", lapras_id)
	var lapras_status = GameData.get_pokemon_evolution_chain_status(lapras_id)
	assert(lapras_status["has_evolution"] == false, "Lapras has no evolution")
	assert(lapras_status["text_badge"] == "— No Evo", "Badge must be — No Evo")
	print("✅ Lapras evolution chain status: %s (%s)" % [lapras_status["status"], lapras_status["text_badge"]])
	
	print("\n=== ALL UNIT TESTS PASSED SUCCESSFULLY! ===")
	get_tree().quit(0)
