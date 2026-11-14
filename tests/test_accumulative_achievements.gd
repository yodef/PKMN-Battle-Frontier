extends Node

func _ready() -> void:
	print("==================================================")
	print("🧪 RUNNING TEST SUITE: TIERED ACCUMULATIVE ACHIEVEMENTS")
	print("==================================================")
	
	var all_passed: bool = true
	
	# -------------------------------------------------------------
	# TEST 1: Check Total Achievements count (1 distinct + 7*4 tiered = 29)
	# -------------------------------------------------------------
	print("\n--- Test 1: Achievement Catalog Structure ---")
	var ach_list = GameData.get_achievements_list()
	print("Total registered achievements: %d (expected 29)" % ach_list.size())
	if ach_list.size() == 29:
		print("✅ TEST 1 PASSED: 29 achievements registered correctly.")
	else:
		print("❌ TEST 1 FAILED: Unexpected achievement count.")
		all_passed = false

	# -------------------------------------------------------------
	# TEST 2: Progress Tracking & Unlock - Campaign Battles (1, 3, 5, 10, 30, 50, 100)
	# -------------------------------------------------------------
	print("\n--- Test 2: Accumulative Progression - Campaign Battles ---")
	# Reset all accumulative stats for clean isolated testing
	GameData.stats_campaign_battles = 0
	GameData.stats_campaign_faints = 0
	GameData.stats_campaign_items_used = 0
	GameData.stats_stadium_tournaments_completed = 0
	GameData.unlocked_achievements.clear()
	GameData.pending_achievement_notifications.clear()
	var initial_gold = GameData.get_active_campaign_gold()
	var initial_diamonds = GameData.player_diamonds
	
	# Battle 1
	GameData.record_campaign_battle_participation()
	var prog1 = GameData.get_achievement_progress("camp_battles_1")
	print("After 1 battle: stats=%d, is_completed=%s, unlocked=%s" % [
		GameData.stats_campaign_battles, prog1.is_completed, GameData.is_achievement_unlocked("camp_battles_1")
	])
	var g_after1 = GameData.get_active_campaign_gold()
	print("Gold reward gained: %d G (expected +20 G)" % [g_after1 - initial_gold])
	
	if GameData.is_achievement_unlocked("camp_battles_1") and (g_after1 - initial_gold == 20):
		print("✅ Battle 1 Tier unlocked and granted 20 G.")
	else:
		print("❌ Battle 1 Tier failed.")
		all_passed = false
		
	# Battle 2 & 3
	GameData.record_campaign_battle_participation()
	GameData.record_campaign_battle_participation()
	var d_after3 = GameData.player_diamonds
	print("After 3 battles: stats=%d, is_completed_b3=%s, diamonds gained=%d" % [
		GameData.stats_campaign_battles,
		GameData.is_achievement_unlocked("camp_battles_3"),
		d_after3 - initial_diamonds
	])
	if GameData.is_achievement_unlocked("camp_battles_3") and (d_after3 - initial_diamonds == 2):
		print("✅ Battle 3 Tier unlocked and granted 2 Diamonds.")
	else:
		print("❌ Battle 3 Tier failed.")
		all_passed = false

	# -------------------------------------------------------------
	# TEST 3: Campaign Faints Progression (Defeating PKMN)
	# -------------------------------------------------------------
	print("\n--- Test 3: Campaign Faints Progression ---")
	GameData.stats_campaign_faints = 0
	var d_before_faint = GameData.player_diamonds
	GameData.record_campaign_pkmn_defeated()
	print("After 1 defeat: unlocked=%s, diamonds gained=%d (expected +2)" % [
		GameData.is_achievement_unlocked("camp_faints_1"),
		GameData.player_diamonds - d_before_faint
	])
	if GameData.is_achievement_unlocked("camp_faints_1") and (GameData.player_diamonds - d_before_faint == 2):
		print("✅ TEST 3 PASSED: PKMN faint achievement awarded moderate diamonds.")
	else:
		print("❌ TEST 3 FAILED: Faint achievement failed.")
		all_passed = false

	# -------------------------------------------------------------
	# TEST 4: Campaign Items Used Progression (Reduced 20% Gold)
	# -------------------------------------------------------------
	print("\n--- Test 4: Items Used Progression ---")
	GameData.stats_campaign_items_used = 0
	var g_before_item = GameData.get_active_campaign_gold()
	GameData.record_campaign_item_used()
	print("After 1 item: unlocked=%s, gold gained=%d (expected +30 G)" % [
		GameData.is_achievement_unlocked("camp_items_1"),
		GameData.get_active_campaign_gold() - g_before_item
	])
	if GameData.is_achievement_unlocked("camp_items_1") and (GameData.get_active_campaign_gold() - g_before_item == 30):
		print("✅ TEST 4 PASSED: Item achievement awarded 30 G (20% reduced gold).")
	else:
		print("❌ TEST 4 FAILED: Item achievement failed.")
		all_passed = false

	# -------------------------------------------------------------
	# TEST 5: Stadium Tournament Completed Progression (Generous Diamonds)
	# -------------------------------------------------------------
	print("\n--- Test 5: Stadium Tournament Completion ---")
	GameData.stats_stadium_tournaments_completed = 0
	var d_before_tourn = GameData.player_diamonds
	GameData.record_stadium_tournament_completed()
	print("After 1 tournament: unlocked=%s, diamonds gained=%d (expected +15)" % [
		GameData.is_achievement_unlocked("stadium_tournaments_1"),
		GameData.player_diamonds - d_before_tourn
	])
	if GameData.is_achievement_unlocked("stadium_tournaments_1") and (GameData.player_diamonds - d_before_tourn == 15):
		print("✅ TEST 5 PASSED: Stadium tournament achievement awarded 15 Diamonds.")
	else:
		print("❌ TEST 5 FAILED: Tournament achievement failed.")
		all_passed = false

	# -------------------------------------------------------------
	# TEST 6: Tutorial Mode Exclusion (Must NOT count toward achievements)
	# -------------------------------------------------------------
	print("\n--- Test 6: Tutorial Mode Exclusion ---")
	GameData.is_tutorial_mode = true
	var b_before_tut = GameData.stats_campaign_battles
	var f_before_tut = GameData.stats_campaign_faints
	var i_before_tut = GameData.stats_campaign_items_used
	var t_before_tut = GameData.stats_stadium_tournaments_completed
	
	GameData.record_campaign_battle_participation()
	GameData.record_campaign_pkmn_defeated()
	GameData.record_campaign_item_used()
	GameData.record_stadium_tournament_completed()
	
	print("Tutorial active: battles %d -> %d | faints %d -> %d | items %d -> %d | tourn %d -> %d" % [
		b_before_tut, GameData.stats_campaign_battles,
		f_before_tut, GameData.stats_campaign_faints,
		i_before_tut, GameData.stats_campaign_items_used,
		t_before_tut, GameData.stats_stadium_tournaments_completed
	])
	
	var tut_excluded = (GameData.stats_campaign_battles == b_before_tut and
		GameData.stats_campaign_faints == f_before_tut and
		GameData.stats_campaign_items_used == i_before_tut and
		GameData.stats_stadium_tournaments_completed == t_before_tut)
		
	GameData.is_tutorial_mode = false
	if tut_excluded:
		print("✅ TEST 6 PASSED: Tutorial battles, faints, items, and tournaments are strictly excluded from achievements.")
	else:
		print("❌ TEST 6 FAILED: Tutorial actions were counted in achievements.")
		all_passed = false

	print("\n==================================================")
	if all_passed:
		print("🎉 ALL TESTS PASSED SUCCESSFULLY! (EXIT CODE 0)")
		print("==================================================")
		get_tree().quit(0)
	else:
		print("💥 SOME TESTS FAILED! (EXIT CODE 1)")
		print("==================================================")
		get_tree().quit(1)
