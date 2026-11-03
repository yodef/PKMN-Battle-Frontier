extends Node

var http: HTTPRequest
var room_code: String = ""

func _ready() -> void:
	print("--- Testing Consecutive Firestore Battle Actions ---")
	http = HTTPRequest.new()
	add_child(http)
	
	OnlineManager.create_room("TestHost", [0, 1, 2], func(success: bool, msg: String):
		if not success:
			print("Failed to create room: ", msg)
			get_tree().quit(1)
			return
		room_code = OnlineManager.room_code
		print("Room created: ", room_code)
		_send_action(1)
	)

func _send_action(seq: int) -> void:
	print("\n--- Sending Action Seq %d ---" % seq)
	var action_payload = {
		"type": "MOVE",
		"move_name": "Tackle",
		"energy_spent": 0,
		"boosted": false,
		"seq": seq,
		"by": "GUEST" if (seq % 2 == 0) else "HOST",
		"timestamp": Time.get_unix_time_from_system()
	}
	var update_data = {
		"action_seq": seq,
		"current_turn": "HOST" if (seq % 2 == 0) else "GUEST",
		"last_action_json": JSON.stringify(action_payload),
		"updated_at": Time.get_datetime_string_from_system()
	}
	var url = OnlineManager._build_patch_url(room_code, update_data)
	var payload = { "fields": OnlineManager._dict_to_firestore_fields(update_data) }
	var body = JSON.stringify(payload)
	var headers = OnlineManager._get_nocache_headers(true)
	
	print("PATCH URL: ", url)
	print("PATCH Body: ", body)
	
	var patch_http = HTTPRequest.new()
	add_child(patch_http)
	patch_http.request_completed.connect(func(_res: int, code: int, _h: PackedStringArray, b: PackedByteArray):
		patch_http.queue_free()
		print("PATCH Response Code: ", code)
		if code < 200 or code >= 300:
			print("❌ Error from Firestore: ", b.get_string_from_utf8())
			get_tree().quit(1)
			return
		print("✅ Action Seq %d saved successfully in Firestore!" % seq)
		_poll_and_verify(seq)
	)
	patch_http.request(url, headers, HTTPClient.METHOD_PATCH, body)

func _poll_and_verify(seq: int) -> void:
	var url = "%s/%s?key=%s" % [OnlineManager.BASE_ROOMS_URL, room_code, CloudSync.API_KEY]
	var headers = OnlineManager._get_nocache_headers(false)
	var get_http = HTTPRequest.new()
	add_child(get_http)
	get_http.request_completed.connect(func(_res: int, code: int, _h: PackedStringArray, b: PackedByteArray):
		get_http.queue_free()
		print("GET Poll Response Code: ", code)
		var resp_text = b.get_string_from_utf8()
		var parsed = JSON.parse_string(resp_text)
		var fields = parsed.get("fields", {})
		var dict = OnlineManager._firestore_fields_to_dict(fields)
		var polled_seq = int(dict.get("action_seq", 0))
		var polled_action = dict.get("last_action_json", "")
		print("Polled action_seq: ", polled_seq)
		print("Polled last_action_json: ", polled_action)
		if polled_seq == seq:
			print("✅ Poll successfully saw action_seq %d" % seq)
			if seq < 4:
				_send_action(seq + 1)
			else:
				print("\n🏆 ALL 4 CONSECUTIVE ACTIONS VERIFIED IN FIRESTORE!")
				OnlineManager.leave_or_delete_room()
				get_tree().quit(0)
		else:
			print("❌ Polled seq mismatch: expected %d, got %d" % [seq, polled_seq])
			get_tree().quit(1)
	)
	get_http.request(url, headers, HTTPClient.METHOD_GET)
