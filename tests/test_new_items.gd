extends Node

func _ready() -> void:
	print("--- STARTING TEST: NEW ITEMS (Super Potion, Hyper Potion, Poké Flute) ---")
	var failures: int = 0
	
	# 1. Test textures
	var tex_sp = GameData.get_item_texture("super_potion")
	if tex_sp == null:
		print("FAIL: get_item_texture('super_potion') returned null")
		failures += 1
	else:
		print("PASS: Super Potion texture loaded successfully")
		
	var tex_hp = GameData.get_item_texture("hyper_potion")
	if tex_hp == null:
		print("FAIL: get_item_texture('hyper_potion') returned null")
		failures += 1
	else:
		print("PASS: Hyper Potion texture loaded successfully")
		
	var tex_pf = GameData.get_item_texture("poke_flute")
	if tex_pf == null:
		print("FAIL: get_item_texture('poke_flute') returned null")
		failures += 1
	else:
		print("PASS: Poké Flute texture loaded successfully")
		
	# 2. Setup mock campaign environment
	GameData.campaign_submode = "TOURNAMENT"
	GameData.set_active_campaign_gold(100)
	var inv = GameData.get_active_campaign_inventory()
	inv["super_potion"] = 0
	inv["hyper_potion"] = 0
	inv["poke_flute"] = 0
	
	var team = GameData.get_active_campaign_team_state()
	team.clear()
	team.append({
		"id": 1,
		"name": "Bulbasaur",
		"stage": "Basic",
		"type": "Grass",
		"current_hp": 15,
		"max_hp": 50,
		"speed": 10,
		"texture_path": "",
		"current_exp": 0,
		"max_exp": 100,
		"burn_turns": 0,
		"is_poisoned": false,
		"is_flinched": false,
		"is_asleep_turns": 2
	})
	
	# 3. Test Super Potion (9 G, heals 25 HP, consumed)
	var initial_gold = GameData.get_active_campaign_gold()
	var bought_sp = GameData.buy_campaign_super_potion()
	if not bought_sp or inv.get("super_potion", 0) != 1 or GameData.get_active_campaign_gold() != (initial_gold - 9):
		print("FAIL: buy_campaign_super_potion did not work as expected. Stock: %d, Gold: %d" % [inv.get("super_potion", 0), GameData.get_active_campaign_gold()])
		failures += 1
	else:
		print("PASS: buy_campaign_super_potion cost 9 G and gave 1 stock")
		
	var used_sp = GameData.use_super_potion_on_campaign_pkmn(0)
	if not used_sp or team[0]["current_hp"] != 40 or inv.get("super_potion", 0) != 0:
		print("FAIL: use_super_potion_on_campaign_pkmn failed. HP: %d (expected 40), stock: %d" % [team[0]["current_hp"], inv.get("super_potion", 0)])
		failures += 1
	else:
		print("PASS: use_super_potion_on_campaign_pkmn restored 25 HP and consumed item (15 -> 40 HP)")
		
	# 4. Test Hyper Potion (15 G, heals to full max HP, consumed)
	team[0]["current_hp"] = 10
	var gold_before_hp = GameData.get_active_campaign_gold()
	var bought_hp = GameData.buy_campaign_hyper_potion()
	if not bought_hp or inv.get("hyper_potion", 0) != 1 or GameData.get_active_campaign_gold() != (gold_before_hp - 15):
		print("FAIL: buy_campaign_hyper_potion did not work as expected. Stock: %d, Gold: %d" % [inv.get("hyper_potion", 0), GameData.get_active_campaign_gold()])
		failures += 1
	else:
		print("PASS: buy_campaign_hyper_potion cost 15 G and gave 1 stock")
		
	var used_hp = GameData.use_hyper_potion_on_campaign_pkmn(0)
	if not used_hp or team[0]["current_hp"] != 50 or inv.get("hyper_potion", 0) != 0:
		print("FAIL: use_hyper_potion_on_campaign_pkmn failed. HP: %d (expected 50), stock: %d" % [team[0]["current_hp"], inv.get("hyper_potion", 0)])
		failures += 1
	else:
		print("PASS: use_hyper_potion_on_campaign_pkmn restored full max HP (50/50) and consumed item")
		
	# 5. Test Poké Flute (20 G, cures sleep, NOT consumed)
	team[0]["is_asleep_turns"] = 3
	var gold_before_flute = GameData.get_active_campaign_gold()
	var bought_flute = GameData.buy_campaign_poke_flute()
	if not bought_flute or inv.get("poke_flute", 0) != 1 or GameData.get_active_campaign_gold() != (gold_before_flute - 20):
		print("FAIL: buy_campaign_poke_flute did not work as expected")
		failures += 1
	else:
		print("PASS: buy_campaign_poke_flute cost 20 G and gave 1 stock")
		
	# Attempt to buy second Poké Flute should fail
	var buy_second_flute = GameData.buy_campaign_poke_flute()
	if buy_second_flute:
		print("FAIL: buy_campaign_poke_flute allowed buying a duplicate permanent flute")
		failures += 1
	else:
		print("PASS: buy_campaign_poke_flute correctly prevents purchasing duplicate flute")
		
	# Use Poké Flute on asleep Pokémon
	var used_flute = GameData.use_poke_flute_on_campaign_pkmn(0)
	if not used_flute or team[0]["is_asleep_turns"] != 0 or inv.get("poke_flute", 0) != 1:
		print("FAIL: use_poke_flute_on_campaign_pkmn failed. Asleep: %d, Stock: %d (expected 1)" % [team[0]["is_asleep_turns"], inv.get("poke_flute", 0)])
		failures += 1
	else:
		print("PASS: use_poke_flute_on_campaign_pkmn cured sleep and DID NOT consume the item (Stock remains 1)")
		
	# Attempt to use on non-asleep Pokémon should return false and not consume
	var used_flute_again = GameData.use_poke_flute_on_campaign_pkmn(0)
	if used_flute_again:
		print("FAIL: use_poke_flute_on_campaign_pkmn succeeded on Pokémon that is not asleep")
		failures += 1
	else:
		print("PASS: use_poke_flute_on_campaign_pkmn correctly failed when Pokémon is not asleep")
		
	# Test reset preservation of Poké Flute
	GameData.reset_campaign()
	var inv_after_reset = GameData.get_active_campaign_inventory()
	if inv_after_reset.get("poke_flute", 0) != 1:
		print("FAIL: Poké Flute was lost after reset_campaign! Stock: %d" % inv_after_reset.get("poke_flute", 0))
		failures += 1
	else:
		print("PASS: Poké Flute is permanently preserved in bag after reset")
		
	if failures == 0:
		print("ALL NEW ITEMS TESTS PASSED SUCCESSFULLY! ✅")
	else:
		print("TOTAL TEST FAILURES: %d ❌" % failures)
		
	get_tree().quit(0 if failures == 0 else 1)
