extends Node

func _make_move(move_name: String) -> GameData.MoveData:
	var d = GameData.get_move_data(move_name)
	var m = GameData.MoveData.new(
		d["name"], d["type"], d["dmg"], d["cost"], d["req"],
		d["boost_cost"] > 0, d["boost_cost"], d["boost_dmg"],
		d["effect_type"] == "BURN", d["desc"]
	)
	m.effect_type = d["effect_type"]
	m.reduces_foe_speed = (m.effect_type == "SLOW_FOE")
	m.is_pichu_shock = (m.effect_type == "PICHU_SHOCK")
	m.causes_poison = (m.effect_type == "POISON_IF_FASTER" or m.effect_type == "POISON")
	return m

func _ready() -> void:
	print("=== RUNNING TEST: MOVES AUDIT & COMPACT MOVE UI ===")
	await get_tree().process_frame
	
	# 1. Verify CSV rectifications loaded in GameData
	var bug_bite = _make_move("Bug Bite")
	assert(bug_bite != null, "Bug Bite should exist")
	assert(bug_bite.can_boost == true and bug_bite.boost_cost == 1 and bug_bite.boost_damage == 0, "Bug Bite boost stats")
	var bb_summary = GameData.format_move_boost_summary(1, 0, bug_bite.effect_type, bug_bite.description)
	print("Bug Bite Boost Summary: ", bb_summary)
	assert("Flinch" in bb_summary and not "+0 Extra DMG" in bb_summary, "Bug Bite boost summary should describe Flinch, not +0 Extra DMG")
	
	var inferno = _make_move("Inferno")
	assert(inferno.boost_cost == 2, "Inferno boost_cost should be 2")
	
	var fissure = _make_move("Fissure")
	assert(fissure.effect_type == "WEAKEN", "Fissure effect_type should be WEAKEN")
	
	var quick_atk = _make_move("Quick Attack")
	assert(quick_atk.can_boost == false and quick_atk.boost_cost == 0, "Quick Attack should not have stray boost_cost")
	
	var aerial_ace = _make_move("Aerial Ace")
	assert(aerial_ace.can_boost == false and aerial_ace.boost_cost == 0, "Aerial Ace should not have stray boost_cost")

	var acid = _make_move("Acid")
	assert("POISON" in acid.description and "+3 DMG" in acid.description, "Acid description should include both POISON and +3 DMG boost")

	# 2. Instantiate Battle Scene to test combat mechanics and compact UI
	var battle_scene = load("res://scenes/battle.tscn").instantiate()
	add_child(battle_scene)
	await get_tree().process_frame
	await get_tree().process_frame
	
	var p = battle_scene.get_active_player()
	var e = battle_scene.get_active_enemy()
	assert(p != null and e != null, "Active player and enemy must exist")
	
	# Set neutral types to test exact raw/predicted damage without weakness/resistance interference
	p.type = "NORMAL"
	p.weakness = "FIGHTING"
	p.resistant = "NONE"
	p.has_passive = false
	p.damage_buff = 0
	p.damage_buff_turns = 0
	
	e.type = "ELECTRIC"
	e.weakness = "GROUND"
	e.resistant = "NONE"
	e.has_passive = false
	e.max_hp = 100
	e.current_hp = 100
	
	# Test 2A: Razor Leaf BOOST_DMG (no double +4 bug)
	var razor_leaf = _make_move("Razor Leaf")
	var rl_unboosted = battle_scene.calculate_predicted_damage(p, e, razor_leaf, 2, false)
	var rl_boosted = battle_scene.calculate_predicted_damage(p, e, razor_leaf, 3, true)
	print("Razor Leaf predicted DMG -> unboosted: %d, boosted: %d" % [rl_unboosted, rl_boosted])
	assert(rl_unboosted == 4, "Razor Leaf unboosted should deal 4 DMG")
	assert(rl_boosted == 6, "Razor Leaf boosted should deal 4 + 2 = 6 DMG (not 10)")
	
	# Test 2B: Ember requires boost to inflict BURN
	var ember = _make_move("Ember")
	p.current_energy = 5
	e.burn_turns = 0
	battle_scene.perform_attack(p, e, ember, false, 1, battle_scene.player_card_img, battle_scene.enemy_card_img)
	assert(e.burn_turns == 0, "Ember unboosted should NOT inflict Burn")
	battle_scene.perform_attack(p, e, ember, true, 2, battle_scene.player_card_img, battle_scene.enemy_card_img)
	assert(e.burn_turns == 2 and e.burn_dmg == 1, "Ember boosted SHOULD inflict Burn (1 DMG x 2 rounds)")
	e.burn_turns = 0
	
	# Test 2C: Quick Attack costs -1 energy when faster
	var qa_move = _make_move("Quick Attack")
	p.speed = 6
	e.speed = 2
	var qa_eff_cost = battle_scene.get_effective_move_cost(qa_move, p, e)
	var qa_dmg_1e = battle_scene.calculate_predicted_damage(p, e, qa_move, 1, false)
	print("Quick Attack faster -> eff_cost: %d, dmg at 1e: %d" % [qa_eff_cost, qa_dmg_1e])
	assert(qa_eff_cost == 1, "Quick Attack should cost 1 energy when faster")
	assert(qa_dmg_1e == 6, "Quick Attack should deal full 6 DMG for 1 energy when faster")
	
	# Test 2D: Drill Peck (+5 vs GRASS) & Moonblast (+4 vs non-NORMAL)
	var drill_peck = _make_move("Drill Peck")
	e.type = "GRASS"
	e.weakness = "FIRE" # avoid weakness bonus so we isolate BOOST_DMG_TYPE
	var dp_dmg = battle_scene.calculate_predicted_damage(p, e, drill_peck, drill_peck.cost, false)
	print("Drill Peck (base %d) vs GRASS -> %d DMG" % [drill_peck.base_damage, dp_dmg])
	assert(dp_dmg == drill_peck.base_damage + 5, "Drill Peck should deal base + 5 DMG vs GRASS")
	
	var moonblast = _make_move("Moonblast")
	var mb_non_normal = battle_scene.calculate_predicted_damage(p, e, moonblast, moonblast.cost, false)
	e.type = "NORMAL"
	var mb_normal = battle_scene.calculate_predicted_damage(p, e, moonblast, moonblast.cost, false)
	print("Moonblast (base %d) vs GRASS: %d, vs NORMAL: %d" % [moonblast.base_damage, mb_non_normal, mb_normal])
	assert(mb_non_normal == moonblast.base_damage + 4, "Moonblast should deal base + 4 DMG vs non-NORMAL")
	assert(mb_normal == moonblast.base_damage, "Moonblast should deal base DMG vs NORMAL")
	
	# Test 2E: Calm Mind (next 2 Moves) & Growth (next Move) buffs persist and are consumed on attacks
	var calm_mind = _make_move("Calm Mind")
	p.current_energy = 5
	battle_scene.perform_attack(p, e, calm_mind, false, 1, battle_scene.player_card_img, battle_scene.enemy_card_img)
	assert(p.damage_buff == 5 and p.damage_buff_turns == 2, "Calm Mind should grant +5 DMG for next 2 Moves")
	e.current_hp = 50
	p.current_energy = 5
	battle_scene.perform_attack(p, e, ember, false, 1, battle_scene.player_card_img, battle_scene.enemy_card_img)
	assert(p.damage_buff_turns == 1, "After 1st damaging move, Calm Mind buff turns should decrement to 1")
	battle_scene.perform_attack(p, e, ember, false, 1, battle_scene.player_card_img, battle_scene.enemy_card_img)
	assert(p.damage_buff_turns == 0 and p.damage_buff == 0, "After 2nd damaging move, Calm Mind buff should expire")
	
	# Test 2F: Stomping Tantrum boosted x2 DMG
	var tantrum = _make_move("Stomping Tantrum")
	e.type = "FIRE"
	e.weakness = "WATER"
	var st_normal = battle_scene.calculate_predicted_damage(p, e, tantrum, tantrum.cost, false)
	var st_boost = battle_scene.calculate_predicted_damage(p, e, tantrum, tantrum.cost + tantrum.boost_cost, true)
	print("Stomping Tantrum (base %d) -> normal: %d, boosted: %d" % [tantrum.base_damage, st_normal, st_boost])
	assert(st_normal == tantrum.base_damage and st_boost == tantrum.base_damage * 2, "Stomping Tantrum should deal x2 when boosted")
	
	# Test 2G: Compact Move Button UI (KO instead of Knockout, clean 2-line format)
	e.type = "ELECTRIC"
	e.weakness = "GROUND"
	p.moves = [razor_leaf, ember]
	p.current_energy = 4
	e.current_hp = 4 # Lethal range for Razor Leaf (4 DMG) and Ember (4 DMG)
	battle_scene.selected_energy_move1 = 1 # Normal Razor Leaf (cost 1)
	battle_scene.selected_energy_move2 = 2 # Boosted Ember (cost 1 + boost 1)
	battle_scene.update_move_button_labels()
	var m1_text = battle_scene.btn_move1.text
	var m2_text = battle_scene.btn_move2.text
	print("btn_move1 text:\n---\n%s\n---" % m1_text)
	print("btn_move2 text:\n---\n%s\n---" % m2_text)
	assert("Razor Leaf" in m1_text and "4 DMG" in m1_text and "KO" in m1_text, "btn_move1 should show Name, DMG, and KO")
	assert(not "Knockout" in m1_text and not "[Uses:" in m1_text and not "[Cost:" in m1_text, "btn_move1 should be compact without Knockout/[Uses:]/[Cost:]")
	assert("Ember 🔥" in m2_text and "4 DMG" in m2_text and "KO" in m2_text, "btn_move2 should show boosted Name 🔥, DMG, and KO")

	# 3. Verify required_exp column in poke_stats.csv & evolution rules
	var bulba_id = GameData.get_pokemon_id_by_name("Bulbasaur")
	var ivysaur_id = GameData.get_pokemon_id_by_name("Ivysaur")
	var venusaur_id = GameData.get_pokemon_id_by_name("Venusaur")
	var rattata_id = GameData.get_pokemon_id_by_name("Rattata")
	var raticate_id = GameData.get_pokemon_id_by_name("Raticate")
	var magikarp_id = GameData.get_pokemon_id_by_name("Magikarp")
	var chansey_id = GameData.get_pokemon_id_by_name("Chansey")
	
	assert(GameData.get_pokemon_required_exp(bulba_id) == 10, "Bulbasaur (Basic -> S1 -> S2) should require 10 EXP")
	assert(GameData.get_pokemon_required_exp(ivysaur_id) == 25, "Ivysaur (S1 -> S2) should require 25 EXP")
	assert(GameData.get_pokemon_required_exp(venusaur_id) == 0, "Venusaur (S2 final) should require 0 EXP")
	assert(GameData.get_pokemon_required_exp(rattata_id) == 20, "Rattata (Basic -> S1 only) should require 20 EXP")
	assert(GameData.get_pokemon_required_exp(raticate_id) == 0, "Raticate (S1 final) should require 0 EXP")
	assert(GameData.get_pokemon_required_exp(magikarp_id) == 20, "Magikarp (Basic -> S1 only) should require 20 EXP")
	assert(GameData.get_pokemon_required_exp(chansey_id) == 0, "Chansey (currently no evo) should require 0 EXP")
	
	var rattata_inst = GameData.create_pokemon_instance(rattata_id)
	assert(rattata_inst.get_required_exp() == 20 and rattata_inst.max_exp == 20, "Rattata instance get_required_exp() must be 20")
	
	# Test custom required_exp override (e.g. future Chansey evolution)
	GameData.pokemon_catalog[chansey_id]["evolves_to"] = "Blissey"
	GameData.pokemon_catalog[chansey_id]["required_exp"] = 35
	var chansey_inst = GameData.create_pokemon_instance(chansey_id)
	assert(chansey_inst.get_required_exp() == 35, "Custom required_exp (35) for Chansey should be respected")
	GameData.pokemon_catalog[chansey_id]["evolves_to"] = ""
	GameData.pokemon_catalog[chansey_id]["required_exp"] = 0
	
	# Test Campaign Evolution check with Rattata (10 EXP = not ready, 20 EXP = ready)
	GameData.unlock_pokemon(rattata_id)
	GameData.unlock_pokemon(raticate_id)
	GameData.campaign_submode = "TOURNAMENT"
	GameData.campaign_player_team_state = [{
		"id": rattata_id,
		"name": "Rattata",
		"stage": "Basic",
		"type": "NORMAL",
		"current_hp": 10,
		"max_hp": 10,
		"speed": 2,
		"texture_path": rattata_inst.texture_path,
		"current_exp": 10,
		"max_exp": 20,
		"burn_turns": 0,
		"is_poisoned": false,
		"is_flinched": false
	}]
	var pending_at_10 = GameData.get_pending_campaign_evolutions()
	assert(pending_at_10.is_empty(), "Rattata should NOT evolve at 10 EXP")
	GameData.campaign_player_team_state[0]["current_exp"] = 20
	var pending_at_20 = GameData.get_pending_campaign_evolutions()
	assert(pending_at_20.size() == 1 and pending_at_20[0]["to_name"] == "Raticate", "Rattata SHOULD evolve into Raticate at 20 EXP")

	print("=== ALL MOVES, COMPACT UI, AND REQUIRED_EXP TESTS PASSED SUCCESSFULLY! ===")
	get_tree().quit(0)
