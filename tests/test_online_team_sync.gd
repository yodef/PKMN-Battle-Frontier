extends Node

func _ready() -> void:
	print("\n--- Starting Full Online Team Sync & Lifecycle Test ---")
	
	# Test 1: Verify _dict_to_firestore_fields and _firestore_fields_to_dict with arrayValue
	var test_team = [1, 4, 7]
	var fields = OnlineManager._dict_to_firestore_fields({
		"status": "GUEST_JOINED",
		"guest_name": "Red",
		"guest_team": test_team,
		"guest_ready": false
	})
	
	var back_to_dict = OnlineManager._firestore_fields_to_dict(fields)
	assert(back_to_dict.get("guest_team") == "[1,4,7]", "guest_team should round-trip stringValue")
	
	# Test 2: Test native arrayValue support in _firestore_fields_to_dict
	var firestore_array_field = {
		"status": { "stringValue": "GUEST_JOINED" },
		"guest_name": { "stringValue": "Blue" },
		"guest_team": {
			"arrayValue": {
				"values": [
					{ "integerValue": "25" },
					{ "integerValue": "172" },
					{ "integerValue": "133" }
				]
			}
		}
	}
	var dict_from_array_field = OnlineManager._firestore_fields_to_dict(firestore_array_field)
	assert(dict_from_array_field.has("guest_team"), "arrayValue must not be dropped!")
	assert(dict_from_array_field["guest_team"] == [25, 172, 133], "arrayValue must parse as Array of ints")
	print("✅ Test 1 & 2 passed: _firestore_fields_to_dict handles stringValue and arrayValue seamlessly.")

	# Test 3: Live end-to-end room creation, join, team update, ready, start match
	print("\n--- Testing Live Firestore Room Creation ---")
	OnlineManager.create_room("TestHostTrainer", [1, 4, 7], func(success: bool, r_code: String):
		assert(success, "Host room creation failed")
		print("✅ Host created room: ", r_code)
		_simulate_guest_join(r_code)
	)

func _simulate_guest_join(code: String) -> void:
	print("1. Simulating Guest joining room %s..." % code)
	var initial_guest_team = [25, 172, 133]
	
	var update_data = {
		"status": "GUEST_JOINED",
		"guest_name": "TestGuestTrainer",
		"guest_team": initial_guest_team,
		"guest_ready": false,
		"updated_at": Time.get_datetime_string_from_system()
	}
	var patch_url = OnlineManager._build_patch_url(code, update_data)
	var patch_payload = { "fields": OnlineManager._dict_to_firestore_fields(update_data) }
	
	var patch_http = HTTPRequest.new()
	add_child(patch_http)
	patch_http.request_completed.connect(func(_r: int, p_code: int, _h: PackedStringArray, _b: PackedByteArray):
		patch_http.queue_free()
		assert(p_code >= 200 and p_code < 300, "Patch GUEST_JOINED failed: %d" % p_code)
		print("✅ Guest successfully joined room in Firestore with team: ", initial_guest_team)
		
		# Wait for Host polling to detect Guest team
		_verify_host_received_initial_team(code, initial_guest_team)
	)
	patch_http.request(patch_url, OnlineManager._get_nocache_headers(true), HTTPClient.METHOD_PATCH, JSON.stringify(patch_payload))

func _verify_host_received_initial_team(code: String, expected_team: Array) -> void:
	print("2. Verifying Host polling detects initial Guest team...")
	var detected = false
	for i in range(8):
		var t = get_tree().create_timer(1.0)
		await t.timeout
		print("  Host state check #%d: opponent_name='%s', opponent_team_ids=%s" % [i+1, OnlineManager.opponent_name, str(OnlineManager.opponent_team_ids)])
		if OnlineManager.opponent_name == "TestGuestTrainer" and OnlineManager.opponent_team_ids == [25, 172, 133]:
			detected = true
			break
			
	assert(detected, "Host timed out waiting for initial Guest team!")
	print("✅ Host correctly detected initial Guest team: ", OnlineManager.opponent_team_ids)
	
	# Step 3: Guest modifies team in lobby (e.g. [6, 9, 3])
	_simulate_guest_team_change(code)

func _simulate_guest_team_change(code: String) -> void:
	print("3. Simulating Guest modifying team in lobby to [6, 9, 3]...")
	var new_team = [6, 9, 3]
	var update_data = {
		"guest_team": new_team,
		"updated_at": Time.get_datetime_string_from_system()
	}
	var patch_url = OnlineManager._build_patch_url(code, update_data)
	var patch_payload = { "fields": OnlineManager._dict_to_firestore_fields(update_data) }
	
	var patch_http = HTTPRequest.new()
	add_child(patch_http)
	patch_http.request_completed.connect(func(_r: int, p_code: int, _h: PackedStringArray, _b: PackedByteArray):
		patch_http.queue_free()
		assert(p_code >= 200 and p_code < 300, "Patch new team failed: %d" % p_code)
		print("✅ Guest updated team in Firestore.")
		
		# Wait for Host to receive updated team
		_verify_host_received_updated_team(code, new_team)
	)
	patch_http.request(patch_url, OnlineManager._get_nocache_headers(true), HTTPClient.METHOD_PATCH, JSON.stringify(patch_payload))

func _verify_host_received_updated_team(code: String, expected_team: Array) -> void:
	print("4. Verifying Host polling detects updated Guest team...")
	var detected = false
	for i in range(8):
		var t = get_tree().create_timer(1.0)
		await t.timeout
		print("  Host state check #%d: opponent_team_ids=%s" % [i+1, str(OnlineManager.opponent_team_ids)])
		if OnlineManager.opponent_team_ids == expected_team:
			detected = true
			break
			
	assert(detected, "Host timed out waiting for updated Guest team!")
	print("✅ Host correctly received updated Guest team: ", OnlineManager.opponent_team_ids)
	
	# Step 5: Guest sets READY
	_simulate_guest_ready(code)

func _simulate_guest_ready(code: String) -> void:
	print("5. Simulating Guest setting status to READY...")
	var update_data = {
		"status": "READY",
		"guest_ready": true,
		"updated_at": Time.get_datetime_string_from_system()
	}
	var patch_url = OnlineManager._build_patch_url(code, update_data)
	var patch_payload = { "fields": OnlineManager._dict_to_firestore_fields(update_data) }
	
	var patch_http = HTTPRequest.new()
	add_child(patch_http)
	patch_http.request_completed.connect(func(_r: int, p_code: int, _h: PackedStringArray, _b: PackedByteArray):
		patch_http.queue_free()
		assert(p_code >= 200 and p_code < 300, "Patch READY failed: %d" % p_code)
		print("✅ Guest marked READY in Firestore.")
		
		# Wait for Host to detect READY
		_verify_host_ready_and_start(code)
	)
	patch_http.request(patch_url, OnlineManager._get_nocache_headers(true), HTTPClient.METHOD_PATCH, JSON.stringify(patch_payload))

func _verify_host_ready_and_start(code: String) -> void:
	print("6. Verifying Host polling detects Guest ready status...")
	var detected = false
	for i in range(8):
		var t = get_tree().create_timer(1.0)
		await t.timeout
		print("  Host state check #%d: is_guest_ready=%s" % [i+1, str(OnlineManager.is_guest_ready)])
		if OnlineManager.is_guest_ready:
			detected = true
			break
			
	assert(detected, "Host timed out waiting for Guest ready!")
	print("✅ Host successfully detected Guest READY status!")
	
	# Step 7: Host starts online match
	print("7. Host starting match...")
	OnlineManager.start_online_match(func(success: bool):
		assert(success, "Host start match failed")
		print("✅ Host set room to IN_BATTLE successfully.")
		
		# Clean up
		OnlineManager.leave_or_delete_room()
		print("✅ Cleaned up test room.")
		print("\n🏆 ALL MULTIPLAYER TEAM SYNC & CONNECTION TESTS PASSED PERFECTLY!\n")
		get_tree().quit(0)
	)
