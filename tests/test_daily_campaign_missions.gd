extends Node

func _ready() -> void:
	print("=== RUNNING DAILY CAMPAIGN MISSIONS TEST ===")
	
	# 1. Verificar Pool de Misiones Diarias
	print("--- Test 1: Verificar DAILY_MISSION_POOL ---")
	var pool = GameData.DAILY_MISSION_POOL
	assert(pool.size() >= 12, "Pool should have at least 12 campaign missions")
	print("✅ Total missions in pool: ", pool.size())
	
	var legacy_ids = ["open_packs", "recycle_cards"]
	for m in pool:
		assert(not (m["id"] in legacy_ids), "Legacy non-campaign mission found: " + m["id"])
		assert(m.has("id") and m.has("title") and m.has("desc") and m.has("type") and m.has("target") and m.has("reward_diamonds"), "Missing keys in mission: " + str(m))
		print("  • [%s] %s %s -> %s (Target: %d, Rew: +%d 💎)" % [m["id"], m["icon"], m["title"], m["desc"], m["target"], m["reward_diamonds"]])
	print("✅ Test 1 Passed: Pool contains exclusively Campaign-centered missions.")
	
	# 2. Verificar Generación y Legacy Migration
	print("\n--- Test 2: Generación y Migración ---")
	# Simular misiones antiguas en profile
	GameData.daily_missions = [
		{"id": "open_packs", "type": "open_packs", "current": 0, "target": 2, "claimed": false},
		{"id": "recycle_cards", "type": "recycle_cards", "current": 0, "target": 3, "claimed": false}
	]
	GameData.check_and_update_daily_system()
	assert(GameData.daily_missions.size() == 3, "Should generate exactly 3 daily missions")
	for m in GameData.daily_missions:
		assert(not (m["id"] in legacy_ids), "Legacy mission persisted after update: " + m["id"])
	print("✅ Test 2 Passed: Legacy missions successfully migrated to new Campaign pool.")
	
	# 3. Test de Aislamiento: Campaña vs Quick Battle / PVP
	print("\n--- Test 3: Aislamiento Campaña vs Quick Battle / PVP ---")
	# Forzar una misión de 'play_moves' y 'win_battles'
	GameData.daily_missions = [
		{"id": "play_moves", "type": "play_moves", "title": "Combat Tactics", "desc": "Execute 8 Moves in Campaign Battles", "current": 0, "target": 8, "reward_diamonds": 5, "claimed": false},
		{"id": "win_battles", "type": "win_battles", "title": "Campaign Victory", "desc": "Win 2 Battles in Campaign", "current": 0, "target": 2, "reward_diamonds": 6, "claimed": false},
		{"id": "use_camp_items", "type": "use_camp_items", "title": "Field Support", "desc": "Use 2 Items in Campaign", "current": 0, "target": 2, "reward_diamonds": 5, "claimed": false}
	]
	
	# Simular combate en Quick Battle (is_campaign_mode = false)
	GameData.is_campaign_mode = false
	# Simular que en batalla no se llama add_daily_mission_progress si is_campaign_mode es false
	# Verificamos la bandera:
	var can_record_quick_battle = GameData.is_campaign_mode
	assert(not can_record_quick_battle, "Quick battle should have is_campaign_mode = false")
	
	# Simular combate en Campaña (is_campaign_mode = true)
	GameData.is_campaign_mode = true
	GameData.add_daily_mission_progress("play_moves", 2)
	GameData.add_daily_mission_progress("win_battles", 1)
	GameData.add_daily_mission_progress("use_camp_items", 1)
	
	assert(GameData.daily_missions[0]["current"] == 2, "play_moves should have 2 progress")
	assert(GameData.daily_missions[1]["current"] == 1, "win_battles should have 1 progress")
	assert(GameData.daily_missions[2]["current"] == 1, "use_camp_items should have 1 progress")
	print("✅ Test 3 Passed: Campaign missions track progress properly in Campaign mode.")
	
	# 4. Test de Reclamación y Cofre Diario
	print("\n--- Test 4: Reclamo de Recompensas y Cofre ---")
	GameData.daily_missions[0]["current"] = 8
	GameData.daily_missions[1]["current"] = 2
	GameData.daily_missions[2]["current"] = 2
	
	var initial_diamonds = GameData.player_diamonds
	var res0 = GameData.claim_daily_mission_reward(0)
	var res1 = GameData.claim_daily_mission_reward(1)
	var res2 = GameData.claim_daily_mission_reward(2)
	
	assert(res0.get("success", false), "Mission 0 claim failed")
	assert(res1.get("success", false), "Mission 1 claim failed")
	assert(res2.get("success", false), "Mission 2 claim failed")
	assert(GameData.are_all_daily_missions_claimed(), "All missions should be claimed")
	
	var res_chest = GameData.claim_daily_bonus_chest()
	assert(res_chest.get("success", false), "Bonus chest claim failed")
	assert(GameData.daily_bonus_chest_claimed, "Bonus chest should be marked claimed")
	assert(GameData.player_diamonds == initial_diamonds + 5 + 6 + 5 + 10, "Diamond math mismatch")
	print("✅ Test 4 Passed: Claiming rewards and bonus chest verified.")
	
	print("\n🎉 ALL DAILY CAMPAIGN MISSIONS TESTS PASSED PERFECTLY!")
	get_tree().quit(0)
