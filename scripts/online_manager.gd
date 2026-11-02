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
	room_code = generate_room_code()
	is_online_match = true
	is_host = true
	my_role = "HOST"
	last_processed_seq = 0
	current_turn_role = "HOST"
	is_guest_ready = false
	is_starting_match = false
	
	var url = "%s/%s?key=%s" % [BASE_ROOMS_URL, room_code, CloudSync.API_KEY]
	var h_email = GameData.profile_email if GameData else ""
	var t_email = str(target_friend.get("email", ""))
	var t_alias = str(target_friend.get("alias", ""))
	
	var room_data = {
		"room_code": room_code,
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
	var headers = PackedStringArray(["Content-Type: application/json"])
	
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(func(_res: int, code: int, _h: PackedStringArray, _b: PackedByteArray):
		http.queue_free()
		if code >= 200 and code < 300:
			print("[OnlineManager] 🏠 Sala creada con código: ", room_code)
			start_polling()
			room_created.emit(room_code)
			if callback.is_valid():
				callback.call(true, room_code)
		else:
			print("[OnlineManager] ❌ Error creando sala en Firestore: ", code)
			is_online_match = false
			sync_error.emit("No se pudo crear la sala en Google Cloud.")
			if callback.is_valid():
				callback.call(false, "Error %d" % code)
	)
	http.request(url, headers, HTTPClient.METHOD_PATCH, body)

# --- UNIRSE A SALA (GUEST) ---
func join_room(target_code: String, guest_name: String, guest_team: Array, callback: Callable = Callable()) -> void:
	reset_session()
	var clean_code = target_code.strip_edges().to_upper()
	if clean_code.length() < 3:
		var err_msg = "Código de sala no válido (debe tener 4 caracteres)."
		room_joined.emit(false, err_msg)
		if callback.is_valid():
			callback.call(false, err_msg)
		return
		
	var url = "%s/%s?key=%s" % [BASE_ROOMS_URL, clean_code, CloudSync.API_KEY]
	
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(func(_res: int, code: int, _h: PackedStringArray, b: PackedByteArray):
		http.queue_free()
		if code == 200:
			var resp_text = b.get_string_from_utf8()
			var parsed = JSON.parse_string(resp_text)
			if typeof(parsed) == TYPE_DICTIONARY and parsed.has("fields"):
				var dict = _firestore_fields_to_dict(parsed["fields"])
				var status = str(dict.get("status", ""))
				if status != "WAITING" and status != "GUEST_JOINED":
					var msg = "La sala '%s' ya no está disponible (Estado: %s)." % [clean_code, status]
					room_joined.emit(false, msg)
					if callback.is_valid():
						callback.call(false, msg)
					return
					
				# Leer datos del Host
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
					
				# Actualizar sala con datos del Guest y marcar GUEST_JOINED
				_confirm_guest_join(clean_code, guest_name, guest_team, callback)
				return
				
			var msg = "La sala '%s' no contiene datos activos o fue cerrada." % clean_code
			room_joined.emit(false, msg)
			if callback.is_valid():
				callback.call(false, msg)
		elif code == 404:
			var msg = "Sala '%s' no encontrada. Verifica que el anfitrión haya creado la sala." % clean_code
			room_joined.emit(false, msg)
			if callback.is_valid():
				callback.call(false, msg)
		else:
			var msg = "Error al conectar con la sala (%d)." % code
			room_joined.emit(false, msg)
			if callback.is_valid():
				callback.call(false, msg)
	)
	http.request(url, PackedStringArray(), HTTPClient.METHOD_GET)

func _confirm_guest_join(code: String, guest_name: String, guest_team: Array, callback: Callable) -> void:
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
	var headers = PackedStringArray(["Content-Type: application/json"])
	
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(func(_res: int, resp_code: int, _h: PackedStringArray, _b: PackedByteArray):
		http.queue_free()
		if resp_code >= 200 and resp_code < 300:
			print("[OnlineManager] 🎮 Unido con éxito a la sala: ", code)
			start_polling()
			room_joined.emit(true, "Conectado exitosamente")
			if callback.is_valid():
				callback.call(true, "Conectado")
		else:
			var msg = "Error actualizando sala como invitado (%d)." % resp_code
			room_joined.emit(false, msg)
			if callback.is_valid():
				callback.call(false, msg)
	)
	http.request(url, headers, HTTPClient.METHOD_PATCH, body)

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
	var headers = PackedStringArray(["Content-Type: application/json"])
	
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(func(_res: int, code: int, _h: PackedStringArray, _b: PackedByteArray):
		http.queue_free()
		var success = (code >= 200 and code < 300)
		if success:
			print("[OnlineManager] 🟢 Estado Listo del invitado actualizado: ", ready)
		if callback.is_valid():
			callback.call(success)
	)
	http.request(url, headers, HTTPClient.METHOD_PATCH, body)

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
	var headers = PackedStringArray(["Content-Type: application/json"])
	
	var http = HTTPRequest.new()
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
	http.request(url, headers, HTTPClient.METHOD_PATCH, body)

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
	var headers = PackedStringArray(["Content-Type: application/json"])
	
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(func(_res: int, code: int, _h: PackedStringArray, _b: PackedByteArray):
		http.queue_free()
		var success = (code >= 200 and code < 300)
		if success:
			print("[OnlineManager] 🎒 Equipo actualizado en la sala: ", new_team)
		if callback.is_valid():
			callback.call(success)
	)
	http.request(url, headers, HTTPClient.METHOD_PATCH, body)

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
	if current_http_req != null:
		return # Ya hay una petición en curso
		
	var url = "%s/%s?key=%s" % [BASE_ROOMS_URL, room_code, CloudSync.API_KEY]
	current_http_req = HTTPRequest.new()
	add_child(current_http_req)
	
	current_http_req.request_completed.connect(func(_res: int, code: int, _h: PackedStringArray, b: PackedByteArray):
		if current_http_req:
			current_http_req.queue_free()
			current_http_req = null
			
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
	current_http_req.request(url, PackedStringArray(), HTTPClient.METHOD_GET)

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
				match_ready_to_start.emit()
				return
	else:
		# Lado del Guest
		if status == "IN_BATTLE":
			if not is_starting_match:
				is_starting_match = true
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
				print("[OnlineManager] ⚡ Acción de rival recibida (seq %d): %s" % [seq, action_data.get("type", "")])
				opponent_action_received.emit(action_data)

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
	var headers = PackedStringArray(["Content-Type: application/json"])
	
	var http = HTTPRequest.new()
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
	var headers = PackedStringArray(["Content-Type: application/json"])
	
	var http = HTTPRequest.new()
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
		room_code = ""
		var url = "%s/%s?key=%s" % [BASE_ROOMS_URL, code, CloudSync.API_KEY]
		var http = HTTPRequest.new()
		add_child(http)
		http.request_completed.connect(func(_res: int, _code: int, _h: PackedStringArray, _b: PackedByteArray):
			http.queue_free()
		)
		if is_host:
			http.request(url, PackedStringArray(), HTTPClient.METHOD_DELETE)
		else:
			# Si es el invitado, marca la sala como cerrada usando updateMask
			var update_data = {
				"status": "CLOSED",
				"updated_at": Time.get_datetime_string_from_system()
			}
			var patch_url = _build_patch_url(code, update_data)
			var payload = { "fields": _dict_to_firestore_fields(update_data) }
			var headers = PackedStringArray(["Content-Type: application/json"])
			http.request(patch_url, headers, HTTPClient.METHOD_PATCH, JSON.stringify(payload))
			
	reset_session()

func reset_session() -> void:
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
