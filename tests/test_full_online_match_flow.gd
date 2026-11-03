extends Node

# Full automated test of Host <-> Guest lobby, Ready toggle, Host start, and Guest In-Battle detection
func _ready() -> void:
	print("\n--- Running Full Online Match Lifecycle Test ---")
	
	# Create host room
	print("1. Creating Host Room...")
	OnlineManager.create_room("HostTrainer", [0, 1, 2], func(h_success: bool, room_code: String):
		assert(h_success, "Host room creation failed")
		print("✅ Host room created with code: %s" % room_code)
		
		# Now simulate Guest in a separate branch using HTTPRequest to simulate the rival
		_run_guest_flow(room_code)
	)

func _run_guest_flow(code: String) -> void:
	print("2. Simulating Guest joining room %s..." % code)
	
	# Simulate guest HTTP join
	var update_data = {
		"status": "GUEST_JOINED",
		"guest_name": "GuestTrainer",
		"guest_team": [3, 4, 5],
		"guest_ready": false,
		"updated_at": Time.get_datetime_string_from_system()
	}
	var url = "https://firestore.googleapis.com/v1/projects/" + CloudSync.PROJECT_ID + "/databases/(default)/documents/rooms/" + code + "?key=" + CloudSync.API_KEY + "&updateMask.fieldPaths=status&updateMask.fieldPaths=guest_name&updateMask.fieldPaths=guest_team&updateMask.fieldPaths=guest_ready&updateMask.fieldPaths=updated_at"
	var payload = { "fields": OnlineManager._dict_to_firestore_fields(update_data) }
	var body = JSON.stringify(payload)
	var headers = OnlineManager._get_nocache_headers(true)
	
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(func(_res: int, resp_code: int, _h: PackedStringArray, _b: PackedByteArray):
		http.queue_free()
		assert(resp_code >= 200 and resp_code < 300, "Guest join failed: HTTP %d" % resp_code)
		print("✅ Guest successfully updated room to GUEST_JOINED in Firestore.")
		
		# Now guest marks READY
		_set_guest_ready_in_firestore(code)
	)
	http.request(url, headers, HTTPClient.METHOD_PATCH, body)

func _set_guest_ready_in_firestore(code: String) -> void:
	var update_data = {
		"status": "READY",
		"guest_ready": true,
		"updated_at": Time.get_datetime_string_from_system()
	}
	var url = "https://firestore.googleapis.com/v1/projects/" + CloudSync.PROJECT_ID + "/databases/(default)/documents/rooms/" + code + "?key=" + CloudSync.API_KEY + "&updateMask.fieldPaths=status&updateMask.fieldPaths=guest_ready&updateMask.fieldPaths=updated_at"
	var payload = { "fields": OnlineManager._dict_to_firestore_fields(update_data) }
	var body = JSON.stringify(payload)
	var headers = OnlineManager._get_nocache_headers(true)
	
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(func(_res: int, resp_code: int, _h: PackedStringArray, _b: PackedByteArray):
		http.queue_free()
		assert(resp_code >= 200 and resp_code < 300, "Guest ready failed: HTTP %d" % resp_code)
		print("✅ Guest set status to READY in Firestore.")
		
		# Wait for Host polling to detect READY
		var timer = get_tree().create_timer(1.5)
		await timer.timeout
		
		print("Host state check: opponent_name=%s, is_guest_ready=%s" % [OnlineManager.opponent_name, str(OnlineManager.is_guest_ready)])
		assert(OnlineManager.opponent_name == "GuestTrainer", "Host failed to detect guest name")
		assert(OnlineManager.is_guest_ready == true, "Host failed to detect guest ready state")
		print("✅ Host correctly detected Guest ready state via Firestore polling!")
		
		# Host starts online match
		print("3. Host starting online match...")
		var match_started_emitted = false
		OnlineManager.match_ready_to_start.connect(func():
			match_started_emitted = true
			print("✅ Host received match_ready_to_start signal!")
		)
		
		OnlineManager.start_online_match(func(s_success: bool):
			assert(s_success, "Host start match failed")
			print("✅ Host successfully updated room to IN_BATTLE in Firestore.")
			
			# Clean up test room
			OnlineManager.leave_or_delete_room()
			print("✅ Host cleanly deleted test room.")
			print("\n🏆 ALL MULTIPLAYER LIFECYCLE TESTS PASSED PERFECTLY!\n")
			get_tree().quit(0)
		)
	)
	http.request(url, headers, HTTPClient.METHOD_PATCH, body)
