extends Node

# Gestor de salas y sincronización multijugador en línea usando Google Cloud Firestore
# Pokemon Battle Frontier

signal room_created(room_code: String)
signal room_joined(success: bool, message: String)
signal guest_connected(guest_name: String, guest_team: Array)
signal guest_ready_changed(is_ready: bool)
signal opponent_team_updated(new_team: Array)
signal match_ready_to_start()
signal opponent_action_received(action: Dictionary)
signal opponent_left_or_surrendered()
signal sync_error(message: String)

const BASE_ROOMS_URL: String = "https://firestore.googleapis.com/v1/projects/" + CloudSync.PROJECT_ID + "/databases/(default)/documents/rooms"

var is_online_match: bool = false
var is_host: bool = false
var room_code: String = ""
var my_role: String = "" # "HOST" o "GUEST"
var opponent_name: String = ""
var opponent_team_ids: Array = []

var is_guest_ready: bool = false
var is_starting_match: bool = false

var _session_gen: int = 0
var last_processed_seq: int = 0
var current_turn_role: String = "HOST"
var is_polling: bool = false
var poll_timer: Timer = null
var current_http_req: HTTPRequest = null

func _ready() -> void:
	poll_timer = Timer.new()
	poll_timer.one_shot = false
	poll_timer.wait_time = 1.0
	poll_timer.timeout.connect(_on_poll_tick)
	add_child(poll_timer)

# Genera un código de sala aleatorio y legible de 4 letras/dígitos (sin caracteres ambiguos como O, 0, I, 1)
func generate_room_code() -> String:
	var chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
	var code = ""
	for i in range(4):
		code += chars[randi() % chars.length()]
	return code

# Convierte un diccionario simple a formato de campos de Firestore
func _dict_to_firestore_fields(data: Dictionary) -> Dictionary:
	var fields = {}
	for k in data.keys():
		var val = data[k]
		if typeof(val) == TYPE_STRING:
			fields[k] = { "stringValue": val }
		elif typeof(val) == TYPE_INT:
			fields[k] = { "integerValue": val }
		elif typeof(val) == TYPE_FLOAT:
			fields[k] = { "doubleValue": val }
		elif typeof(val) == TYPE_BOOL:
			fields[k] = { "booleanValue": val }
		elif typeof(val) == TYPE_ARRAY or typeof(val) == TYPE_DICTIONARY:
			fields[k] = { "stringValue": JSON.stringify(val) }
		else:
			fields[k] = { "stringValue": str(val) }
	return fields

# Convierte los campos de un documento de Firestore a un diccionario simple de GDScript
func _firestore_fields_to_dict(fields: Dictionary) -> Dictionary:
	var result = {}
	for k in fields.keys():
		var field_obj = fields[k]
		if not field_obj is Dictionary:
			continue
		if field_obj.has("stringValue"):
			result[k] = field_obj["stringValue"]
		elif field_obj.has("integerValue"):
			result[k] = int(field_obj["integerValue"])
		elif field_obj.has("booleanValue"):
			result[k] = bool(field_obj["booleanValue"])
		elif field_obj.has("doubleValue"):
			result[k] = float(field_obj["doubleValue"])
	return result

func _get_nocache_headers(content_type_json: bool = false) -> PackedStringArray:
	var hdrs = [
		"Cache-Control: no-cache, no-store, must-revalidate",
		"Pragma: no-cache"
	]
	if content_type_json:
		hdrs.append("Content-Type: application/json")
	return PackedStringArray(hdrs)

# Construye la URL de PATCH con updateMask para que Firestore NO borre los otros campos del documento
func _build_patch_url(target_code: String, fields_dict: Dictionary) -> String:
	var mask_parts = PackedStringArray()
	for k in fields_dict.keys():
		mask_parts.append("updateMask.fieldPaths=%s" % str(k))
	var query_mask = "&".join(mask_parts)
	if query_mask.is_empty():
		return "%s/%s?key=%s" % [BASE_ROOMS_URL, target_code, CloudSync.API_KEY]
	return "%s/%s?key=%s&%s" % [BASE_ROOMS_URL, target_code, CloudSync.API_KEY, query_mask]

# --- CREAR SALA (HOST) ---
func create_room(host_name: String, host_team: Array, callback: Callable = Callable(), target_friend: Dictionary = {}) -> void:
	reset_session()
	var my_gen = _session_gen
	var target_code = generate_room_code()
	room_code = target_code
	is_online_match = true
	is_host = true
	my_role = "HOST"
	last_processed_seq = 0
	current_turn_role = "HOST"
	is_guest_ready = false
	is_starting_match = false
	
	var url = "%s/%s?key=%s" % [BASE_ROOMS_URL, target_code, CloudSync.API_KEY]
	var h_email = GameData.profile_email if GameData else ""
	var t_email = str(target_friend.get("email", ""))
	var t_alias = str(target_friend.get("alias", ""))
	
	var room_data = {
		"room_code": target_code,
		"status": "WAITING",
		"host_name": host_name,
		"host_email": h_email,
		"host_team": host_team,
		"target_friend_email": t_email,
		"target_friend_alias": t_alias,
		"guest_name": "",
		"guest_team": [],
		"guest_ready": false,
		"current_turn": "HOST",
		"action_seq": 0,
		"last_action_json": "{}",
		"updated_at": Time.get_datetime_string_from_system()
	}
	
	var payload = { "fields": _dict_to_firestore_fields(room_data) }
	var body = JSON.stringify(payload)
	var headers = _get_nocache_headers(true)
	
	var http = HTTPRequest.new()
	http.timeout = 8.0
	add_child(http)
	http.request_completed.connect(func(_res: int, code: int, _h: PackedStringArray, _b: PackedByteArray):
		http.queue_free()
		if my_gen != _session_gen or not is_host or room_code != target_code:
			print("[OnlineManager] ⚠️ create_room callback ignorado: sesión reiniciada o cancelada.")
			return
		if code >= 200 and code < 300:
			print("[OnlineManager] 🏠 Sala creada con código: ", target_code)
			start_polling()
			room_created.emit(target_code)
			if callback.is_valid():
				callback.call(true, target_code)
		else:
			print("[OnlineManager] ❌ Error creando sala en Firestore: ", code)
			is_online_match = false
			sync_error.emit("No se pudo crear la sala en Google Cloud.")
			if callback.is_valid():
				callback.call(false, "Error %d" % code)
	)
	var err = http.request(url, headers, HTTPClient.METHOD_PATCH, body)
	if err != OK:
		http.queue_free()
		is_online_match = false
		if callback.is_valid():
			callback.call(false, "Error de red %d" % err)

# --- UNIRSE A SALA (GUEST) ---
func join_room(target_code: String, guest_name: String, guest_team: Array, callback: Callable = Callable()) -> void:
	reset_session()
	var my_gen = _session_gen
	
	var clean_code = target_code.strip_edges().to_upper()
	var regex = RegEx.new()
	if regex.compile("[^A-Z0-9]") == OK:
		clean_code = regex.sub(clean_code, "", true)
		
	if clean_code.length() != 4:
		var err_msg = "Invalid room code (must be exactly 4 letters or digits)."
		room_joined.emit(false, err_msg)
		if callback.is_valid():
			callback.call(false, err_msg)
		return
		
	var url = "%s/%s?key=%s" % [BASE_ROOMS_URL, clean_code, CloudSync.API_KEY]
	
	var http = HTTPRequest.new()
	http.timeout = 8.0
	add_child(http)
	http.request_completed.connect(func(_res: int, code: int, _h: PackedStringArray, b: PackedByteArray):
		http.queue_free()
		if my_gen != _session_gen:
			print("[OnlineManager] ⚠️ join_room response ignored (session changed).")
			return
			
		if code == 200:
			var resp_text = b.get_string_from_utf8()
			var parsed = JSON.parse_string(resp_text)
			if typeof(parsed) == TYPE_DICTIONARY and parsed.has("fields"):
				var dict = _firestore_fields_to_dict(parsed["fields"])
				var status = str(dict.get("status", ""))
				if status == "CLOSED":
					var msg = "Room '%s' was closed or is no longer available." % clean_code
					room_joined.emit(false, msg)
					if callback.is_valid():
						callback.call(false, msg)
					return
				elif status == "IN_BATTLE":
					var msg = "Room '%s' is already in an active battle." % clean_code
					room_joined.emit(false, msg)
					if callback.is_valid():
						callback.call(false, msg)
					return
					
				# Read Host data
				room_code = clean_code
				is_online_match = true
				is_host = false
				my_role = "GUEST"
				is_guest_ready = false
				is_starting_match = false
				opponent_name = str(dict.get("host_name", "Host"))
				var raw_h_team = str(dict.get("host_team", "[]"))
				var parsed_h_team = JSON.parse_string(raw_h_team)
				if typeof(parsed_h_team) == TYPE_ARRAY:
					opponent_team_ids = parsed_h_team
				else:
					opponent_team_ids = []
					
				# Update room with Guest data and set GUEST_JOINED
				_confirm_guest_join(clean_code, guest_name, guest_team, callback, my_gen)
				return
				
			var msg = "Room '%s' does not contain valid data." % clean_code
			room_joined.emit(false, msg)
			if callback.is_valid():
				callback.call(false, msg)
		elif code == 404:
			var msg = "Room '%s' not found. Make sure the host has created the room." % clean_code
			room_joined.emit(false, msg)
			if callback.is_valid():
				callback.call(false, msg)
		else:
			var msg = "Error connecting to room (%d)." % code
			room_joined.emit(false, msg)
			if callback.is_valid():
				callback.call(false, msg)
	)
	var err = http.request(url, _get_nocache_headers(), HTTPClient.METHOD_GET)
	if err != OK:
		http.queue_free()
		var msg = "Error initiating HTTP connection (%d)." % err
		room_joined.emit(false, msg)
		if callback.is_valid():
			callback.call(false, msg)

func _confirm_guest_join(code: String, guest_name: String, guest_team: Array, callback: Callable, expected_gen: int = -1) -> void:
	var update_data = {
		"status": "GUEST_JOINED",
		"guest_name": guest_name,
		"guest_team": guest_team,
		"guest_ready": false,
		"updated_at": Time.get_datetime_string_from_system()
	}
	var url = _build_patch_url(code, update_data)
	var payload = { "fields": _dict_to_firestore_fields(update_data) }
	var body = JSON.stringify(payload)
	var headers = _get_nocache_headers(true)
	
	var http = HTTPRequest.new()
	http.timeout = 8.0
	add_child(http)
	http.request_completed.connect(func(_res: int, resp_code: int, _h: PackedStringArray, _b: PackedByteArray):
		http.queue_free()
		if expected_gen != -1 and expected_gen != _session_gen:
			print("[OnlineManager] ⚠️ _confirm_guest_join ignored: obsolete session.")
			return
		if resp_code >= 200 and resp_code < 300:
			print("[OnlineManager] 🎮 Successfully joined room: ", code)
			start_polling()
			room_joined.emit(true, "Connected successfully")
			if callback.is_valid():
				callback.call(true, "Connected")
		else:
			var msg = "Error updating room as guest (%d)." % resp_code
			room_joined.emit(false, msg)
			if callback.is_valid():
				callback.call(false, msg)
	)
	var err = http.request(url, headers, HTTPClient.METHOD_PATCH, body)
	if err != OK:
		http.queue_free()
		var msg = "Error sending confirmation (%d)." % err
		room_joined.emit(false, msg)
		if callback.is_valid():
			callback.call(false, msg)

# Marca el estado de preparación (Ready / Listo) del invitado en Firestore
func set_guest_ready(ready: bool, callback: Callable = Callable()) -> void:
	if is_host or room_code.is_empty():
		return
	is_guest_ready = ready
	var new_status = "READY" if ready else "GUEST_JOINED"
	var update_data = {
		"status": new_status,
		"guest_ready": ready,
		"updated_at": Time.get_datetime_string_from_system()
	}
	var url = _build_patch_url(room_code, update_data)
	var payload = { "fields": _dict_to_firestore_fields(update_data) }
	var body = JSON.stringify(payload)
	var headers = _get_nocache_headers(true)
	
	var http = HTTPRequest.new()
	http.timeout = 8.0
	add_child(http)
	http.request_completed.connect(func(_res: int, code: int, _h: PackedStringArray, _b: PackedByteArray):
		http.queue_free()
		var success = (code >= 200 and code < 300)
		if success:
			print("[OnlineManager] 🟢 Estado Listo del invitado actualizado: ", ready)
			call_deferred("_on_poll_tick")
		if callback.is_valid():
			callback.call(success)
	)
	var err = http.request(url, headers, HTTPClient.METHOD_PATCH, body)
	if err != OK:
		http.queue_free()
		if callback.is_valid():
			callback.call(false)

# El Anfitrión inicia la partida cuando el rival está listo
func start_online_match(callback: Callable = Callable()) -> void:
	if not is_host or room_code.is_empty():
		return
	is_starting_match = true
	var update_data = {
		"status": "IN_BATTLE",
		"updated_at": Time.get_datetime_string_from_system()
	}
	var url = _build_patch_url(room_code, update_data)
	var payload = { "fields": _dict_to_firestore_fields(update_data) }
	var body = JSON.stringify(payload)
	var headers = _get_nocache_headers(true)
	
	var http = HTTPRequest.new()
	http.timeout = 8.0
	add_child(http)
	http.request_completed.connect(func(_res: int, code: int, _h: PackedStringArray, _b: PackedByteArray):
		http.queue_free()
		var success = (code >= 200 and code < 300)
		if success:
			print("[OnlineManager] 🚀 Combate iniciado por el Host!")
			match_ready_to_start.emit()
		else:
			is_starting_match = false
		if callback.is_valid():
			callback.call(success)
	)
	var err = http.request(url, headers, HTTPClient.METHOD_PATCH, body)
	if err != OK:
		http.queue_free()
		is_starting_match = false
		if callback.is_valid():
			callback.call(false)

# Actualiza el equipo del jugador en Firestore (Host o Guest) mientras está en el lobby
func update_my_team(new_team: Array, callback: Callable = Callable()) -> void:
	if room_code.is_empty():
		return
	var field_key = "host_team" if is_host else "guest_team"
	var update_data = {
		field_key: new_team,
		"updated_at": Time.get_datetime_string_from_system()
	}
	if not is_host and is_guest_ready:
		is_guest_ready = false
		update_data["guest_ready"] = false
		update_data["status"] = "GUEST_JOINED"
		
	var url = _build_patch_url(room_code, update_data)
	var payload = { "fields": _dict_to_firestore_fields(update_data) }
	var body = JSON.stringify(payload)
	var headers = _get_nocache_headers(true)
	
	var http = HTTPRequest.new()
	http.timeout = 8.0
	add_child(http)
	http.request_completed.connect(func(_res: int, code: int, _h: PackedStringArray, _b: PackedByteArray):
		http.queue_free()
		var success = (code >= 200 and code < 300)
		if success:
			print("[OnlineManager] 🎒 Equipo actualizado en la sala: ", new_team)
		if callback.is_valid():
			callback.call(success)
	)
	var err = http.request(url, headers, HTTPClient.METHOD_PATCH, body)
	if err != OK:
		http.queue_free()
		if callback.is_valid():
			callback.call(false)

# --- POLLING Y SINCRONIZACIÓN ---
func start_polling(interval: float = 1.0) -> void:
	poll_timer.wait_time = interval
	is_polling = true
	poll_timer.start()

func stop_polling() -> void:
	is_polling = false
	poll_timer.stop()

func _on_poll_tick() -> void:
	if not is_online_match or room_code.is_empty():
		stop_polling()
		return
	if current_http_req != null and is_instance_valid(current_http_req):
		return # Ya hay una petición en curso
		
	var url = "%s/%s?key=%s" % [BASE_ROOMS_URL, room_code, CloudSync.API_KEY]
	current_http_req = HTTPRequest.new()
	current_http_req.timeout = 3.5
	add_child(current_http_req)
	
	current_http_req.request_completed.connect(func(_res: int, code: int, _h: PackedStringArray, b: PackedByteArray):
		var req = current_http_req
		current_http_req = null
		if req and is_instance_valid(req):
			req.queue_free()
			
		if code == 200:
			var resp_text = b.get_string_from_utf8()
			var parsed = JSON.parse_string(resp_text)
			if typeof(parsed) == TYPE_DICTIONARY and parsed.has("fields"):
				_process_room_state(parsed["fields"])
		elif code == 404:
			print("[OnlineManager] ⚠️ La sala ya no existe.")
			stop_polling()
			opponent_left_or_surrendered.emit()
	)
	var err = current_http_req.request(url, _get_nocache_headers(), HTTPClient.METHOD_GET)
	if err != OK:
		print("[OnlineManager] ⚠️ Error iniciando poll request: ", err)
		if current_http_req and is_instance_valid(current_http_req):
			current_http_req.queue_free()
		current_http_req = null

func _process_room_state(fields: Dictionary) -> void:
	var dict = _firestore_fields_to_dict(fields)
	var status = str(dict.get("status", ""))
	
	# Sincronizar nombre y equipo del rival si se actualizan en el lobby
	if is_host:
		var g_name = str(dict.get("guest_name", ""))
		if not g_name.is_empty() and opponent_name != g_name:
			opponent_name = g_name
		var raw_g_team = str(dict.get("guest_team", "[]"))
		var parsed_g_team = JSON.parse_string(raw_g_team)
		if typeof(parsed_g_team) == TYPE_ARRAY and parsed_g_team != opponent_team_ids:
			opponent_team_ids = parsed_g_team
			opponent_team_updated.emit(opponent_team_ids)
	else:
		var h_name = str(dict.get("host_name", ""))
		if not h_name.is_empty() and opponent_name != h_name:
			opponent_name = h_name
		var raw_h_team = str(dict.get("host_team", "[]"))
		var parsed_h_team = JSON.parse_string(raw_h_team)
		if typeof(parsed_h_team) == TYPE_ARRAY and parsed_h_team != opponent_team_ids:
			opponent_team_ids = parsed_h_team
			opponent_team_updated.emit(opponent_team_ids)

	# Gestión de estados de sala (Lobby)
	if is_host:
		if status == "GUEST_JOINED":
			if not opponent_name.is_empty():
				guest_connected.emit(opponent_name, opponent_team_ids)
			if is_guest_ready:
				is_guest_ready = false
				guest_ready_changed.emit(false)
		elif status == "READY":
			if not opponent_name.is_empty():
				guest_connected.emit(opponent_name, opponent_team_ids)
			if not is_guest_ready:
				is_guest_ready = true
				guest_ready_changed.emit(true)
		elif status == "IN_BATTLE":
			if not is_starting_match:
				is_starting_match = true
				print("[OnlineManager] 🚀 [HOST] Sala en IN_BATTLE. Emitiendo match_ready_to_start...")
				match_ready_to_start.emit()
				return
	else:
		# Lado del Guest
		if status == "IN_BATTLE":
			if not is_starting_match:
				is_starting_match = true
				print("[OnlineManager] 🚀 [GUEST] Sala en IN_BATTLE detectada! Emitiendo match_ready_to_start...")
				match_ready_to_start.emit()
				return
		
	# Caso 3: Rival cerró la sala o se rindió
	if status == "CLOSED" or status == "FINISHED":
		opponent_left_or_surrendered.emit()
		return
		
	# Caso 4: Sincronización de acción de combate por turnos
	var seq = int(dict.get("action_seq", 0))
	if seq > last_processed_seq:
		var raw_action = str(dict.get("last_action_json", "{}"))
		var action_data = JSON.parse_string(raw_action)
		if typeof(action_data) == TYPE_DICTIONARY:
			var action_by = str(action_data.get("by", ""))
			# Solo procesar acciones realizadas por el rival
			if action_by != my_role:
				last_processed_seq = seq
				current_turn_role = str(dict.get("current_turn", "HOST"))
				print("[OnlineManager] ⚡ Opponent action received (seq %d): %s" % [seq, action_data.get("type", "")])
				opponent_action_received.emit(action_data)
			else:
				last_processed_seq = seq

func _set_room_status(new_status: String) -> void:
	if room_code.is_empty():
		return
	var update_data = {
		"status": new_status,
		"updated_at": Time.get_datetime_string_from_system()
	}
	var url = _build_patch_url(room_code, update_data)
	var payload = { "fields": _dict_to_firestore_fields(update_data) }
	var body = JSON.stringify(payload)
	var headers = _get_nocache_headers(true)
	
	var http = HTTPRequest.new()
	http.timeout = 8.0
	add_child(http)
	http.request_completed.connect(func(_res: int, _code: int, _h: PackedStringArray, _b: PackedByteArray):
		http.queue_free()
	)
	http.request(url, headers, HTTPClient.METHOD_PATCH, body)

# Envía una acción de combate realizada por el jugador local al documento de la sala
func send_battle_action(action_dict: Dictionary, callback: Callable = Callable()) -> void:
	if not is_online_match or room_code.is_empty():
		return
		
	last_processed_seq += 1
	action_dict["seq"] = last_processed_seq
	action_dict["by"] = my_role
	action_dict["timestamp"] = Time.get_unix_time_from_system()
	
	var next_turn = "GUEST" if my_role == "HOST" else "HOST"
	current_turn_role = next_turn
	
	var update_data = {
		"action_seq": last_processed_seq,
		"current_turn": next_turn,
		"last_action_json": JSON.stringify(action_dict),
		"updated_at": Time.get_datetime_string_from_system()
	}
	var url = _build_patch_url(room_code, update_data)
	var payload = { "fields": _dict_to_firestore_fields(update_data) }
	var body = JSON.stringify(payload)
	var headers = _get_nocache_headers(true)
	
	var http = HTTPRequest.new()
	http.timeout = 8.0
	add_child(http)
	http.request_completed.connect(func(_res: int, code: int, _h: PackedStringArray, _b: PackedByteArray):
		http.queue_free()
		var success = (code >= 200 and code < 300)
		if success:
			print("[OnlineManager] 📤 Acción enviada a la sala (seq %d)" % last_processed_seq)
		else:
			print("[OnlineManager] ❌ Error enviando acción: ", code)
		if callback.is_valid():
			callback.call(success)
	)
	http.request(url, headers, HTTPClient.METHOD_PATCH, body)

# Cierra o elimina la sala al terminar
func leave_or_delete_room() -> void:
	stop_polling()
	if not room_code.is_empty():
		var code = room_code
		var was_host = is_host
		room_code = ""
		var url = "%s/%s?key=%s" % [BASE_ROOMS_URL, code, CloudSync.API_KEY]
		var http = HTTPRequest.new()
		add_child(http)
		http.request_completed.connect(func(_res: int, _code: int, _h: PackedStringArray, _b: PackedByteArray):
			http.queue_free()
		)
		if was_host:
			var err = http.request(url, _get_nocache_headers(), HTTPClient.METHOD_DELETE)
			if err != OK:
				http.queue_free()
		else:
			# Si es el invitado quien sale:
			# Si estaba en combate, marcar FINISHED para que el host reciba la victoria por forfeit
			# Si estaba en el lobby, volver a WAITING para permitir que se una otro invitado
			var guest_exit_status = "FINISHED" if is_starting_match else "WAITING"
			var update_data = {
				"status": guest_exit_status,
				"guest_name": "",
				"guest_team": [],
				"guest_ready": false,
				"updated_at": Time.get_datetime_string_from_system()
			}
			var patch_url = _build_patch_url(code, update_data)
			var payload = { "fields": _dict_to_firestore_fields(update_data) }
			var headers = _get_nocache_headers(true)
			var err = http.request(patch_url, headers, HTTPClient.METHOD_PATCH, JSON.stringify(payload))
			if err != OK:
				http.queue_free()
			
	reset_session()

func reset_session() -> void:
	_session_gen += 1
	stop_polling()
	is_online_match = false
	is_host = false
	room_code = ""
	my_role = ""
	opponent_name = ""
	opponent_team_ids = []
	is_guest_ready = false
	is_starting_match = false
	last_processed_seq = 0
	current_turn_role = "HOST"
