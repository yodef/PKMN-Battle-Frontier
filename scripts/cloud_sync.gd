extends Node

signal cloud_save_completed(success: bool, message: String)
signal cloud_load_completed(success: bool, data: Dictionary, message: String)
signal google_oauth_completed(success: bool, email: String, display_name: String, error_msg: String)

const PROJECT_ID: String = "pokemon-battle-frontier-4add7"
const API_KEY: String = "AIzaSyDDe8OAmIP6vAF1iScuSb0Wo35X3o60-Bg"
const FIRESTORE_BASE_URL: String = "https://firestore.googleapis.com/v1/projects/" + PROJECT_ID + "/databases/(default)/documents/trainers"

var is_saving: bool = false
var is_loading: bool = false
var last_cloud_sync_time: String = ""
var _pending_save_request: Dictionary = {}

var _auth_server: TCPServer = null
var _auth_server_port: int = 8910
var _is_waiting_for_oauth: bool = false
var _oauth_timeout_timer: float = 0.0

var _is_waiting_for_web_oauth: bool = false
var _is_waiting_for_cloud_handshake: bool = false
var _handshake_session_id: String = ""
var _handshake_poll_timer: float = 0.0
var _handshake_http: HTTPRequest = null

func _get_nocache_headers(content_type_json: bool = false) -> PackedStringArray:
	var hdrs = [
		"Cache-Control: no-cache, no-store, must-revalidate",
		"Pragma: no-cache"
	]
	if content_type_json:
		hdrs.append("Content-Type: application/json")
	return PackedStringArray(hdrs)

# Sanitiza el nombre o correo para que sea un ID de documento válido en Firestore
func sanitize_account_key(raw_key: String) -> String:
	var clean = raw_key.strip_edges().to_lower()
	clean = clean.replace("@", "_at_")
	clean = clean.replace(".", "_")
	clean = clean.replace(" ", "_")
	clean = clean.replace("/", "_")
	clean = clean.replace("#", "_")
	clean = clean.replace("+", "_plus_")
	clean = clean.replace("-", "_")
	if clean.is_empty():
		clean = "trainer_guest"
	return clean

# Parsea y normaliza un documento de Firestore a un save_dict de GameData,
# garantizando que un alias personalizado nunca sea sobreescrito por "Trainer".
func parse_trainer_doc_to_save_data(fields: Dictionary) -> Dictionary:
	var save_data: Dictionary = {}
	if fields.has("save_json"):
		var raw_save = str(fields["save_json"].get("stringValue", ""))
		var parsed_save = JSON.parse_string(raw_save)
		if typeof(parsed_save) == TYPE_DICTIONARY:
			save_data = parsed_save
			
	if not save_data.has("profile") or typeof(save_data["profile"]) != TYPE_DICTIONARY:
		save_data["profile"] = {}
		
	# Extraer alias de campos raíz de Firestore (preferir trainer_alias, luego trainer_name)
	var root_alias = ""
	if fields.has("trainer_alias"):
		root_alias = str(fields["trainer_alias"].get("stringValue", "")).strip_edges()
	if root_alias.is_empty() and fields.has("trainer_name"):
		root_alias = str(fields["trainer_name"].get("stringValue", "")).strip_edges()
		
	# Alias existente en save_json
	var existing_alias = str(save_data["profile"].get("trainer_alias", save_data["profile"].get("name", ""))).strip_edges()
	
	# Decisión sobre el alias final: priorizar nombres reales diferentes de "Trainer"
	var final_alias = "Trainer"
	if existing_alias != "" and existing_alias != "Trainer":
		final_alias = existing_alias
	elif root_alias != "" and root_alias != "Trainer":
		final_alias = root_alias
	elif existing_alias != "":
		final_alias = existing_alias
	elif root_alias != "":
		final_alias = root_alias
		
	save_data["profile"]["trainer_alias"] = final_alias
	save_data["profile"]["name"] = final_alias
	
	# Extraer email y profile_id de la raíz si no estuvieran en save_json
	var root_email = str(fields.get("email", {}).get("stringValue", "")).strip_edges()
	if not root_email.is_empty():
		save_data["profile"]["email"] = root_email
	var root_id = str(fields.get("profile_id", {}).get("stringValue", "")).strip_edges()
	if not root_id.is_empty():
		save_data["profile"]["id"] = root_id
		
	return save_data

# --- FIREBASE AUTHENTICATION (EMAIL & VERIFICATION) ---
const FIREBASE_AUTH_SIGNUP_URL: String = "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=" + API_KEY
const FIREBASE_AUTH_SEND_OOB_URL: String = "https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=" + API_KEY
const FIREBASE_AUTH_LOOKUP_URL: String = "https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=" + API_KEY
const FIREBASE_AUTH_SIGNIN_URL: String = "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=" + API_KEY

func firebase_auth_sign_up(email: String, password: String, callback: Callable) -> void:
	var http = HTTPRequest.new()
	http.timeout = 10.0
	add_child(http)
	var payload = {
		"email": email.strip_edges(),
		"password": password,
		"returnSecureToken": true
	}
	var headers = _get_nocache_headers(true)
	http.request_completed.connect(func(_res: int, code: int, _h: PackedStringArray, body: PackedByteArray):
		http.queue_free()
		var resp_text = body.get_string_from_utf8()
		var parsed = JSON.parse_string(resp_text)
		if code >= 200 and code < 300 and typeof(parsed) == TYPE_DICTIONARY:
			var id_token = str(parsed.get("idToken", ""))
			callback.call(true, id_token, "")
		else:
			var err_msg = "Registration failed."
			if typeof(parsed) == TYPE_DICTIONARY and parsed.has("error"):
				var raw_err = str(parsed["error"].get("message", ""))
				if raw_err.contains("EMAIL_EXISTS"):
					err_msg = "An account with this email already exists."
				elif raw_err.contains("INVALID_EMAIL"):
					err_msg = "The email address is invalid."
				elif raw_err.contains("WEAK_PASSWORD"):
					err_msg = "Password should be at least 6 characters."
				else:
					err_msg = raw_err
			callback.call(false, "", err_msg)
	)
	http.request(FIREBASE_AUTH_SIGNUP_URL, headers, HTTPClient.METHOD_POST, JSON.stringify(payload))

func firebase_auth_send_verification_email(id_token: String, callback: Callable) -> void:
	var http = HTTPRequest.new()
	http.timeout = 10.0
	add_child(http)
	var payload = {
		"requestType": "VERIFY_EMAIL",
		"idToken": id_token
	}
	var headers = _get_nocache_headers(true)
	http.request_completed.connect(func(_res: int, code: int, _h: PackedStringArray, body: PackedByteArray):
		http.queue_free()
		var resp_text = body.get_string_from_utf8()
		var parsed = JSON.parse_string(resp_text)
		if code >= 200 and code < 300:
			callback.call(true, "")
		else:
			var err_msg = "Could not send verification email."
			if typeof(parsed) == TYPE_DICTIONARY and parsed.has("error"):
				err_msg = str(parsed["error"].get("message", err_msg))
			callback.call(false, err_msg)
	)
	http.request(FIREBASE_AUTH_SEND_OOB_URL, headers, HTTPClient.METHOD_POST, JSON.stringify(payload))

func firebase_auth_check_verified(id_token: String, callback: Callable) -> void:
	var http = HTTPRequest.new()
	http.timeout = 10.0
	add_child(http)
	var payload = {
		"idToken": id_token
	}
	var headers = _get_nocache_headers(true)
	http.request_completed.connect(func(_res: int, code: int, _h: PackedStringArray, body: PackedByteArray):
		http.queue_free()
		var resp_text = body.get_string_from_utf8()
		var parsed = JSON.parse_string(resp_text)
		if code >= 200 and code < 300 and typeof(parsed) == TYPE_DICTIONARY and parsed.has("users"):
			var users_arr = parsed["users"]
			if users_arr.size() > 0:
				var is_v = bool(users_arr[0].get("emailVerified", false))
				callback.call(true, is_v, "")
				return
		callback.call(false, false, "Could not verify email status.")
	)
	http.request(FIREBASE_AUTH_LOOKUP_URL, headers, HTTPClient.METHOD_POST, JSON.stringify(payload))

func firebase_auth_sign_in(email: String, password: String, callback: Callable) -> void:
	var http = HTTPRequest.new()
	http.timeout = 10.0
	add_child(http)
	var payload = {
		"email": email.strip_edges(),
		"password": password,
		"returnSecureToken": true
	}
	var headers = _get_nocache_headers(true)
	http.request_completed.connect(func(_res: int, code: int, _h: PackedStringArray, body: PackedByteArray):
		http.queue_free()
		var resp_text = body.get_string_from_utf8()
		var parsed = JSON.parse_string(resp_text)
		if code >= 200 and code < 300 and typeof(parsed) == TYPE_DICTIONARY:
			var id_token = str(parsed.get("idToken", ""))
			callback.call(true, id_token, "")
		else:
			var err_msg = "Sign-in failed."
			if typeof(parsed) == TYPE_DICTIONARY and parsed.has("error"):
				var raw_err = str(parsed["error"].get("message", ""))
				if raw_err.contains("INVALID_LOGIN_CREDENTIALS") or raw_err.contains("EMAIL_NOT_FOUND") or raw_err.contains("INVALID_PASSWORD"):
					err_msg = "Invalid email or password."
				else:
					err_msg = raw_err
			callback.call(false, "", err_msg)
	)
	http.request(FIREBASE_AUTH_SIGNIN_URL, headers, HTTPClient.METHOD_POST, JSON.stringify(payload))

# Comprueba si una cuenta ya existe en Firestore sin sobreescribir datos
func check_account_exists(account_key: String, callback: Callable) -> void:
	var doc_id = sanitize_account_key(account_key)
	var url = "%s/%s?key=%s" % [FIRESTORE_BASE_URL, doc_id, API_KEY]
	var headers = _get_nocache_headers()
	
	var http = HTTPRequest.new()
	http.timeout = 10.0
	add_child(http)
	
	http.request_completed.connect(func(result: int, response_code: int, _resp_headers: PackedStringArray, resp_body: PackedByteArray):
		http.queue_free()
		if response_code == 200:
			var resp_text = resp_body.get_string_from_utf8()
			var parsed = JSON.parse_string(resp_text)
			var save_data: Dictionary = {}
			if typeof(parsed) == TYPE_DICTIONARY and parsed.has("fields"):
				var fields = parsed.get("fields", {})
				save_data = parse_trainer_doc_to_save_data(fields)
			if callback.is_valid():
				callback.call(true, save_data, "")
		elif response_code == 404:
			_check_account_exists_fallback(account_key, callback)
		else:
			var err_msg = "Error HTTP %d" % response_code
			if result != HTTPRequest.RESULT_SUCCESS:
				err_msg = "Connection failed (Code %d)" % result
			if callback.is_valid():
				callback.call(false, {}, err_msg)
	)
	
	var err = http.request(url, headers, HTTPClient.METHOD_GET)
	if err != OK:
		http.queue_free()
		if callback.is_valid():
			callback.call(false, {}, "Request failed to initialize (Error %d)" % err)

func _check_account_exists_fallback(account_key: String, callback: Callable) -> void:
	var clean_query = account_key.strip_edges().to_lower()
	var search_url = "%s?key=%s&pageSize=50" % [FIRESTORE_BASE_URL, API_KEY]
	var http_search = HTTPRequest.new()
	http_search.timeout = 10.0
	add_child(http_search)
	
	http_search.request_completed.connect(func(_res: int, code: int, _hdrs: PackedStringArray, body: PackedByteArray):
		http_search.queue_free()
		if code >= 200 and code < 300:
			var txt = body.get_string_from_utf8()
			var parsed = JSON.parse_string(txt)
			if typeof(parsed) == TYPE_DICTIONARY and parsed.has("documents"):
				var docs = parsed.get("documents", [])
				for doc in docs:
					if typeof(doc) != TYPE_DICTIONARY or not doc.has("fields"):
						continue
					var fields = doc["fields"]
					var t_email = str(fields.get("email", {}).get("stringValue", "")).to_lower()
					var t_alias = str(fields.get("trainer_alias", fields.get("trainer_name", {})).get("stringValue", "")).to_lower()
					var t_id = str(fields.get("profile_id", {}).get("stringValue", "")).to_lower()
					
					var raw_without_gmail = clean_query.trim_suffix("@gmail.com")
					var match_found = false
					if t_email == clean_query or t_alias == clean_query or t_id == clean_query or t_alias == raw_without_gmail:
						match_found = true
					elif not clean_query.contains("@") and (t_email.begins_with(clean_query + "@") or t_alias == clean_query):
						match_found = true
						
					if match_found:
						var save_data = parse_trainer_doc_to_save_data(fields)
						if callback.is_valid():
							callback.call(true, save_data, "")
						return
		if callback.is_valid():
			callback.call(false, {}, "")
	)
	var err = http_search.request(search_url, _get_nocache_headers(), HTTPClient.METHOD_GET)
	if err != OK:
		http_search.queue_free()
		if callback.is_valid():
			callback.call(false, {}, "")

# Guarda un perfil completo en Google Cloud Firestore
func save_profile_to_cloud(account_key: String, save_dict: Dictionary, callback: Callable = Callable()) -> void:
	if is_saving:
		_pending_save_request = {
			"account_key": account_key,
			"save_dict": save_dict,
			"callback": callback
		}
		print("[CloudSync] Cloud save currently in flight; queued updated state for: %s" % account_key)
		return
		
	var doc_id = sanitize_account_key(account_key)
	var url = "%s/%s?key=%s" % [FIRESTORE_BASE_URL, doc_id, API_KEY]
	
	var json_str = JSON.stringify(save_dict)
	var prof = save_dict.get("profile", {})
	var p_name = str(prof.get("trainer_alias", prof.get("name", ""))).strip_edges()
	if p_name.is_empty() or p_name == "Trainer":
		if GameData and not GameData.profile_name.is_empty() and GameData.profile_name != "Trainer":
			p_name = GameData.profile_name
		else:
			p_name = "Trainer"
	var p_email = str(prof.get("email", ""))
	if p_email.is_empty() and account_key.contains("@"):
		p_email = account_key
	var p_id = str(prof.get("id", "PKMN-000000"))
	var diamonds = int(save_dict.get("economy", {}).get("diamonds", 0))
	var candies = int(save_dict.get("economy", {}).get("rare_candies", 0))
	var now_iso = Time.get_datetime_string_from_system()
	
	var payload = {
		"fields": {
			"email": { "stringValue": p_email },
			"trainer_alias": { "stringValue": p_name },
			"trainer_name": { "stringValue": p_name },
			"profile_id": { "stringValue": p_id },
			"diamonds": { "integerValue": diamonds },
			"rare_candies": { "integerValue": candies },
			"save_json": { "stringValue": json_str },
			"updated_at": { "stringValue": now_iso }
		}
	}
	
	var body = JSON.stringify(payload)
	var headers = _get_nocache_headers(true)
	
	var http = HTTPRequest.new()
	http.timeout = 10.0
	add_child(http)
	is_saving = true
	
	http.request_completed.connect(func(result: int, response_code: int, _resp_headers: PackedStringArray, resp_body: PackedByteArray):
		is_saving = false
		http.queue_free()
		
		var success = (response_code >= 200 and response_code < 300)
		var msg = ""
		if success:
			last_cloud_sync_time = Time.get_time_string_from_system()
			msg = "Saved successfully to Google Cloud at %s" % last_cloud_sync_time
			print("[CloudSync] ✅ %s (Doc: %s, Alias: %s)" % [msg, doc_id, p_name])
		else:
			var resp_text = resp_body.get_string_from_utf8()
			msg = "Error %d connecting to Google Cloud." % response_code
			print("[CloudSync] ❌ Failed to save to cloud: Code %d: %s" % [response_code, resp_text])
			
		cloud_save_completed.emit(success, msg)
		if callback.is_valid():
			callback.call(success, msg)
			
		if not _pending_save_request.is_empty():
			var pending = _pending_save_request.duplicate()
			_pending_save_request.clear()
			save_profile_to_cloud(pending["account_key"], pending["save_dict"], pending.get("callback", Callable()))
	)
	
	var err = http.request(url, headers, HTTPClient.METHOD_PATCH, body)
	if err != OK:
		is_saving = false
		http.queue_free()
		var msg = "Failed to initiate HTTP request to Google Cloud (Error %d)" % err
		cloud_save_completed.emit(false, msg)
		if callback.is_valid():
			callback.call(false, msg)

# Descarga un perfil desde Google Cloud Firestore
func load_profile_from_cloud(account_key: String, callback: Callable = Callable()) -> void:
	if is_loading:
		if callback.is_valid():
			callback.call(false, {}, "Cloud load already in progress.")
		return
		
	var doc_id = sanitize_account_key(account_key)
	var url = "%s/%s?key=%s" % [FIRESTORE_BASE_URL, doc_id, API_KEY]
	var headers = _get_nocache_headers()
	
	var http = HTTPRequest.new()
	http.timeout = 10.0
	add_child(http)
	is_loading = true
	
	http.request_completed.connect(func(result: int, response_code: int, _resp_headers: PackedStringArray, resp_body: PackedByteArray):
		is_loading = false
		http.queue_free()
		
		if response_code == 200:
			var resp_text = resp_body.get_string_from_utf8()
			var parsed = JSON.parse_string(resp_text)
			if typeof(parsed) == TYPE_DICTIONARY and parsed.has("fields"):
				var fields = parsed.get("fields", {})
				var save_data = parse_trainer_doc_to_save_data(fields)
				last_cloud_sync_time = Time.get_time_string_from_system()
				print("[CloudSync] ✅ Successfully loaded profile from Google Cloud for: ", doc_id, " (Alias: %s)" % save_data["profile"]["name"])
				cloud_load_completed.emit(true, save_data, "Profile loaded from Google Cloud!")
				if callback.is_valid():
					callback.call(true, save_data, "Success")
				return
			
			cloud_load_completed.emit(false, {}, "Invalid data format received from Google Cloud.")
			if callback.is_valid():
				callback.call(false, {}, "Invalid data format.")
		elif response_code == 404:
			# Si no se encontró por ID directo, intentar fallback de búsqueda por alias o email
			_try_search_fallback_on_404(account_key, callback)
		else:
			var resp_text = resp_body.get_string_from_utf8()
			var msg = "Error %d loading from Google Cloud." % response_code
			if response_code == 0 or result != HTTPRequest.RESULT_SUCCESS:
				msg = "Could not reach Google Cloud (Result %d, Code %d). Please check internet connection." % [result, response_code]
			print("[CloudSync] ❌ %s: %s" % [msg, resp_text])
			cloud_load_completed.emit(false, {}, msg)
			if callback.is_valid():
				callback.call(false, {}, msg)
	)
	
	var err = http.request(url, headers, HTTPClient.METHOD_GET)
	if err != OK:
		is_loading = false
		http.queue_free()
		var msg = "Failed to send request to Google Cloud (Error %d)" % err
		cloud_load_completed.emit(false, {}, msg)
		if callback.is_valid():
			callback.call(false, {}, msg)

# Fallback inteligente: si la clave directa da 404, busca en la colección por alias o correo parcial
func _try_search_fallback_on_404(account_key: String, callback: Callable) -> void:
	var clean_query = account_key.strip_edges().to_lower()
	var search_url = "%s?key=%s&pageSize=50" % [FIRESTORE_BASE_URL, API_KEY]
	var http_search = HTTPRequest.new()
	http_search.timeout = 15.0
	add_child(http_search)
	
	http_search.request_completed.connect(func(_res: int, code: int, _hdrs: PackedStringArray, body: PackedByteArray):
		http_search.queue_free()
		if code >= 200 and code < 300:
			var txt = body.get_string_from_utf8()
			var parsed = JSON.parse_string(txt)
			if typeof(parsed) == TYPE_DICTIONARY and parsed.has("documents"):
				var docs = parsed.get("documents", [])
				for doc in docs:
					if typeof(doc) != TYPE_DICTIONARY or not doc.has("fields"):
						continue
					var fields = doc["fields"]
					var t_email = str(fields.get("email", {}).get("stringValue", "")).to_lower()
					var t_alias = str(fields.get("trainer_alias", fields.get("trainer_name", {})).get("stringValue", "")).to_lower()
					var t_id = str(fields.get("profile_id", {}).get("stringValue", "")).to_lower()
					
					var raw_without_gmail = clean_query.trim_suffix("@gmail.com")
					var match_found = false
					if t_email == clean_query or t_alias == clean_query or t_id == clean_query or t_alias == raw_without_gmail:
						match_found = true
					elif not clean_query.contains("@") and (t_email.begins_with(clean_query + "@") or t_alias == clean_query):
						match_found = true
						
					if match_found:
						var save_data = parse_trainer_doc_to_save_data(fields)
						last_cloud_sync_time = Time.get_time_string_from_system()
						print("[CloudSync] ✅ Fallback search found profile for '%s' (Email: %s, Alias: %s)" % [account_key, save_data["profile"]["email"], save_data["profile"]["name"]])
						cloud_load_completed.emit(true, save_data, "Profile loaded from Google Cloud!")
						if callback.is_valid():
							callback.call(true, save_data, "Success")
						return
		# Si tras la búsqueda exhaustiva no existe
		var msg = "Google Account or Trainer '%s' not found in Google Cloud." % account_key
		print("[CloudSync] ⚠️ %s" % msg)
		cloud_load_completed.emit(false, {}, msg)
		if callback.is_valid():
			callback.call(false, {}, msg)
	)
	var err = http_search.request(search_url, _get_nocache_headers(), HTTPClient.METHOD_GET)
	if err != OK:
		http_search.queue_free()
		var msg = "Google Account '%s' not found in Google Cloud." % account_key
		cloud_load_completed.emit(false, {}, msg)
		if callback.is_valid():
			callback.call(false, {}, msg)

# Elimina un documento de perfil en Google Cloud Firestore
func delete_cloud_profile(account_key: String, callback: Callable = Callable()) -> void:
	var doc_id = sanitize_account_key(account_key)
	var url = "%s/%s?key=%s" % [FIRESTORE_BASE_URL, doc_id, API_KEY]
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(func(_r, _c, _h, _b):
		http.queue_free()
		if callback.is_valid():
			callback.call()
	)
	http.request(url, _get_nocache_headers(), HTTPClient.METHOD_DELETE)

# Consulta pública de un perfil para que amigos o rivales puedan inspeccionar su perfil y showcase sin interferir con la sesión
func fetch_public_trainer_profile(account_key: String, callback: Callable) -> void:
	var clean_key = account_key.strip_edges()
	if clean_key.is_empty():
		if callback.is_valid():
			callback.call(false, {}, "Empty account key provided.")
		return
		
	var doc_id = sanitize_account_key(clean_key)
	var url = "%s/%s?key=%s" % [FIRESTORE_BASE_URL, doc_id, API_KEY]
	var http = HTTPRequest.new()
	http.timeout = 8.0
	add_child(http)
	
	http.request_completed.connect(func(_res: int, code: int, _hdrs: PackedStringArray, body: PackedByteArray):
		http.queue_free()
		if code == 200:
			var txt = body.get_string_from_utf8()
			var parsed = JSON.parse_string(txt)
			if typeof(parsed) == TYPE_DICTIONARY and parsed.has("fields"):
				var save_data = parse_trainer_doc_to_save_data(parsed["fields"])
				if callback.is_valid():
					callback.call(true, save_data, "")
				return
		elif code == 404:
			# Fallback: buscar en colección por correo, alias o profile_id
			_fetch_public_fallback_search(clean_key, callback)
			return
			
		if callback.is_valid():
			callback.call(false, {}, "Could not load trainer profile (HTTP %d)." % code)
	)
	var err = http.request(url, _get_nocache_headers(), HTTPClient.METHOD_GET)
	if err != OK:
		http.queue_free()
		if callback.is_valid():
			callback.call(false, {}, "HTTP error %d initiating request." % err)

func _fetch_public_fallback_search(query_key: String, callback: Callable) -> void:
	var clean_query = query_key.strip_edges().to_lower()
	var search_url = "%s?key=%s&pageSize=50" % [FIRESTORE_BASE_URL, API_KEY]
	var http_search = HTTPRequest.new()
	http_search.timeout = 10.0
	add_child(http_search)
	
	http_search.request_completed.connect(func(_res: int, code: int, _hdrs: PackedStringArray, body: PackedByteArray):
		http_search.queue_free()
		if code >= 200 and code < 300:
			var txt = body.get_string_from_utf8()
			var parsed = JSON.parse_string(txt)
			if typeof(parsed) == TYPE_DICTIONARY and parsed.has("documents"):
				var docs = parsed.get("documents", [])
				for doc in docs:
					if typeof(doc) != TYPE_DICTIONARY or not doc.has("fields"):
						continue
					var fields = doc["fields"]
					var t_email = str(fields.get("email", {}).get("stringValue", "")).to_lower()
					var t_alias = str(fields.get("trainer_alias", fields.get("trainer_name", {})).get("stringValue", "")).to_lower()
					var t_id = str(fields.get("profile_id", {}).get("stringValue", "")).to_lower()
					
					var match_found = false
					if t_email == clean_query or t_alias == clean_query or t_id == clean_query:
						match_found = true
					elif clean_query.contains("@") and t_email == clean_query:
						match_found = true
					elif not clean_query.contains("@") and (t_email.begins_with(clean_query + "@") or t_alias == clean_query):
						match_found = true
						
					if match_found:
						var save_data = parse_trainer_doc_to_save_data(fields)
						if callback.is_valid():
							callback.call(true, save_data, "")
						return
		if callback.is_valid():
			callback.call(false, {}, "Trainer not found in Google Cloud.")
	)
	var err = http_search.request(search_url, _get_nocache_headers(), HTTPClient.METHOD_GET)
	if err != OK:
		http_search.queue_free()
		if callback.is_valid():
			callback.call(false, {}, "Search request failed.")

# Guarda automáticamente el perfil actual si tiene cuenta de nube activa
func sync_current_profile_to_cloud(callback: Callable = Callable()) -> void:
	if not GameData:
		return
	if not GameData.profile_auth_provider.begins_with("Google"):
		return
	var key = GameData.profile_email
	if key.is_empty():
		key = GameData.profile_cloud_key
	if key.is_empty():
		key = GameData.profile_name
	if key.is_empty():
		return
	var save_dict = GameData.get_save_dict()
	save_profile_to_cloud(key, save_dict, callback)

# Busca entrenadores en Firestore por correo, alias o ID
func search_trainers(query_text: String, callback: Callable) -> void:
	var clean_query = query_text.strip_edges().to_lower()
	var url = "%s?key=%s&pageSize=50" % [FIRESTORE_BASE_URL, API_KEY]
	var headers = _get_nocache_headers()
	
	var http = HTTPRequest.new()
	add_child(http)
	
	http.request_completed.connect(func(result: int, response_code: int, _resp_headers: PackedStringArray, resp_body: PackedByteArray):
		http.queue_free()
		
		if response_code >= 200 and response_code < 300:
			var resp_text = resp_body.get_string_from_utf8()
			var parsed = JSON.parse_string(resp_text)
			var results: Array = []
			
			if typeof(parsed) == TYPE_DICTIONARY and parsed.has("documents"):
				var docs = parsed.get("documents", [])
				var my_email = GameData.profile_email.strip_edges().to_lower() if GameData else ""
				var my_id = GameData.profile_id.strip_edges().to_lower() if GameData else ""
				var my_alias = GameData.profile_name.strip_edges().to_lower() if GameData else ""
				
				for doc in docs:
					if typeof(doc) != TYPE_DICTIONARY or not doc.has("fields"):
						continue
					var f = doc["fields"]
					var t_email = str(f.get("email", {}).get("stringValue", "")).strip_edges()
					var t_alias = str(f.get("trainer_alias", f.get("trainer_name", {})).get("stringValue", "")).strip_edges()
					var t_id = str(f.get("profile_id", {}).get("stringValue", "")).strip_edges()
					var t_diamonds = int(f.get("diamonds", {}).get("integerValue", 0))
					
					# Si los datos raíz están incompletos o son genéricos, inspeccionar save_json
					if (t_alias.is_empty() or t_alias == "Trainer" or t_email.is_empty() or t_id.is_empty()) and f.has("save_json"):
						var raw_s = str(f["save_json"].get("stringValue", ""))
						var p_s = JSON.parse_string(raw_s)
						if typeof(p_s) == TYPE_DICTIONARY and p_s.has("profile"):
							var p_prof = p_s["profile"]
							if t_alias.is_empty() or t_alias == "Trainer":
								var inner_alias = str(p_prof.get("trainer_alias", p_prof.get("name", ""))).strip_edges()
								if not inner_alias.is_empty() and inner_alias != "Trainer":
									t_alias = inner_alias
							if t_email.is_empty():
								t_email = str(p_prof.get("email", "")).strip_edges()
							if t_id.is_empty():
								t_id = str(p_prof.get("id", "")).strip_edges()
					if t_alias.is_empty():
						t_alias = "Trainer"
						
					var is_self = false
					if not my_email.is_empty() and t_email.to_lower() == my_email:
						is_self = true
					elif not my_id.is_empty() and t_id.to_lower() == my_id:
						is_self = true
					elif not my_alias.is_empty() and my_alias != "trainer" and t_alias.to_lower() == my_alias:
						is_self = true
						
					# Filtrar por query
					var match_found = false
					if clean_query.is_empty():
						match_found = true
					else:
						if t_email.to_lower().contains(clean_query):
							match_found = true
						elif t_alias.to_lower().contains(clean_query):
							match_found = true
						elif t_id.to_lower().contains(clean_query):
							match_found = true
							
					if match_found:
						results.append({
							"alias": t_alias,
							"email": t_email,
							"id": t_id,
							"diamonds": t_diamonds,
							"is_self": is_self
						})
						
			if callback.is_valid():
				callback.call(true, results, "Success")
		else:
			if callback.is_valid():
				callback.call(false, [], "Error %d connecting to Google Cloud." % response_code)
	)
	
	var err = http.request(url, headers, HTTPClient.METHOD_GET)
	if err != OK:
		http.queue_free()
		if callback.is_valid():
			callback.call(false, [], "Failed to initiate search request.")

# Consulta salas activas de amigos o retos directos
func fetch_friend_rooms(friends_list: Array, my_email: String, callback: Callable) -> void:
	var url = "https://firestore.googleapis.com/v1/projects/%s/databases/(default)/documents/rooms?key=%s&pageSize=50" % [PROJECT_ID, API_KEY]
	var headers = _get_nocache_headers()
	
	var http = HTTPRequest.new()
	add_child(http)
	
	http.request_completed.connect(func(result: int, response_code: int, _resp_headers: PackedStringArray, resp_body: PackedByteArray):
		http.queue_free()
		
		if response_code >= 200 and response_code < 300:
			var resp_text = resp_body.get_string_from_utf8()
			var parsed = JSON.parse_string(resp_text)
			var direct_invites: Array = []
			var friend_rooms: Array = []
			
			if typeof(parsed) == TYPE_DICTIONARY and parsed.has("documents"):
				var docs = parsed.get("documents", [])
				var clean_my_email = my_email.strip_edges().to_lower()
				
				# Conjuntos de amigos para búsqueda rápida
				var friend_emails = []
				for fr in friends_list:
					if typeof(fr) == TYPE_DICTIONARY:
						var fe = str(fr.get("email", "")).strip_edges().to_lower()
						if not fe.is_empty():
							friend_emails.append(fe)
							
				for doc in docs:
					if typeof(doc) != TYPE_DICTIONARY or not doc.has("fields"):
						continue
					var f = doc["fields"]
					var status = str(f.get("status", {}).get("stringValue", ""))
					if status != "WAITING":
						continue
						
					var r_code = str(f.get("room_code", {}).get("stringValue", ""))
					var h_name = str(f.get("host_name", {}).get("stringValue", "Host"))
					var h_email = str(f.get("host_email", {}).get("stringValue", ""))
					var target_email = str(f.get("target_friend_email", {}).get("stringValue", "")).strip_edges().to_lower()
					var target_alias = str(f.get("target_friend_alias", {}).get("stringValue", ""))
					
					var info = {
						"room_code": r_code,
						"host_name": h_name,
						"host_email": h_email,
						"target_email": target_email,
						"target_alias": target_alias
					}
					
					# ¿Es un reto directo dirigido a mí?
					if not clean_my_email.is_empty() and target_email == clean_my_email:
						direct_invites.append(info)
					# ¿Es una sala creada por alguno de mis amigos?
					elif not h_email.is_empty() and h_email.to_lower() in friend_emails:
						friend_rooms.append(info)
						
			if callback.is_valid():
				callback.call(true, {
					"direct_invites": direct_invites,
					"friend_rooms": friend_rooms
				}, "Success")
		else:
			if callback.is_valid():
				callback.call(false, { "direct_invites": [], "friend_rooms": [] }, "Failed to fetch friend rooms")
	)
	
	var err = http.request(url, headers, HTTPClient.METHOD_GET)
	if err != OK:
		http.queue_free()
		if callback.is_valid():
			callback.call(false, { "direct_invites": [], "friend_rooms": [] }, "HTTP Request Error")

# --- GOOGLE OAUTH FLOW (WEB POPUP / CLOUD HANDSHAKE / LOCAL SERVER) ---

func _process(delta: float) -> void:
	# 1. Flujo Web (Popup de Firebase Auth mediante JavaScriptBridge)
	if _is_waiting_for_web_oauth:
		_oauth_timeout_timer -= delta
		if _oauth_timeout_timer <= 0.0:
			_is_waiting_for_web_oauth = false
			google_oauth_completed.emit(false, "", "", "Tiempo de espera agotado al conectar con Google.")
			return
			
		if ClassDB.class_exists("JavaScriptBridge"):
			var raw_status = JavaScriptBridge.eval("window.getFirebaseAuthStatus ? window.getFirebaseAuthStatus() : ''")
			if raw_status != null and typeof(raw_status) == TYPE_STRING and not str(raw_status).is_empty():
				var parsed = JSON.parse_string(str(raw_status))
				if typeof(parsed) == TYPE_DICTIONARY:
					var state = str(parsed.get("state", "idle"))
					if state == "success":
						_is_waiting_for_web_oauth = false
						var email = str(parsed.get("email", ""))
						var user_name = str(parsed.get("name", ""))
						JavaScriptBridge.eval("window.firebaseAuthStatus = { state: 'idle', email: '', name: '', uid: '', error: '' }")
						google_oauth_completed.emit(true, email, user_name, "")
						return
					elif state == "error":
						_is_waiting_for_web_oauth = false
						var err_msg = str(parsed.get("error", "Error al autenticar con Google."))
						JavaScriptBridge.eval("window.firebaseAuthStatus = { state: 'idle', email: '', name: '', uid: '', error: '' }")
						google_oauth_completed.emit(false, "", "", err_msg)
						return
		return

	# 2. Flujo Cloud Handshake (Mobile APK / Fallback universal)
	if _is_waiting_for_cloud_handshake:
		_oauth_timeout_timer -= delta
		if _oauth_timeout_timer <= 0.0:
			_stop_cloud_handshake()
			google_oauth_completed.emit(false, "", "", "Tiempo de espera agotado. Puedes reintentar o ingresar manualmente.")
			return
			
		_handshake_poll_timer -= delta
		if _handshake_poll_timer <= 0.0:
			_handshake_poll_timer = 1.2
			_poll_handshake_session()
		return

	# 3. Flujo Loopback Server (PC Desktop)
	if _is_waiting_for_oauth and _auth_server != null:
		_oauth_timeout_timer -= delta
		if _oauth_timeout_timer <= 0.0:
			stop_google_oauth_server()
			google_oauth_completed.emit(false, "", "", "Tiempo de espera agotado. Puedes reintentar o usar inicio manual.")
			return
			
		if _auth_server.is_connection_available():
			var peer: StreamPeerTCP = _auth_server.take_connection()
			if peer:
				_handle_auth_client_connection(peer)

func start_google_oauth_flow() -> bool:
	stop_google_oauth_server()
	
	# Plataforma Web: Popup directo de Firebase Auth en el navegador
	if OS.has_feature("web"):
		if ClassDB.class_exists("JavaScriptBridge"):
			_is_waiting_for_web_oauth = true
			_oauth_timeout_timer = 120.0
			JavaScriptBridge.eval("if (window.loginWithGoogleWeb) { window.loginWithGoogleWeb(); }")
			return true
		return false
		
	# Plataforma Móvil (Android APK / iOS): Cloud Handshake con navegador del sistema
	if OS.has_feature("mobile"):
		return _start_cloud_handshake_oauth()
		
	# Plataforma PC Windows / Linux / macOS: Intentar TCPServer loopback
	_auth_server = TCPServer.new()
	var port = 8910
	var err = ERR_UNAVAILABLE
	for p in range(8910, 8920):
		err = _auth_server.listen(p, "127.0.0.1")
		if err == OK:
			port = p
			break
			
	if err != OK:
		print("[CloudSync] Puerto local ocupado, recurriendo a Cloud Handshake...")
		return _start_cloud_handshake_oauth()
		
	_auth_server_port = port
	_is_waiting_for_oauth = true
	_oauth_timeout_timer = 120.0
	
	var auth_url = "http://localhost:%d/" % _auth_server_port
	print("[CloudSync] 🌐 Abriendo navegador para Google OAuth en: ", auth_url)
	OS.shell_open(auth_url)
	return true

func _start_cloud_handshake_oauth() -> bool:
	_stop_cloud_handshake()
	_handshake_session_id = "sess_%d_%d" % [int(Time.get_unix_time_from_system()), randi() % 900000 + 100000]
	_is_waiting_for_cloud_handshake = true
	_oauth_timeout_timer = 120.0
	_handshake_poll_timer = 0.5
	
	var auth_url = "https://yodef.github.io/PKMN-Battle-Frontier/auth.html?session=%s" % _handshake_session_id
	print("[CloudSync] 🌐 Abriendo navegador para Cloud Handshake OAuth en: ", auth_url)
	OS.shell_open(auth_url)
	return true

func _stop_cloud_handshake() -> void:
	_is_waiting_for_cloud_handshake = false
	if _handshake_http:
		_handshake_http.queue_free()
		_handshake_http = null

func _poll_handshake_session() -> void:
	if _handshake_http != null:
		return
		
	var url = "https://firestore.googleapis.com/v1/projects/%s/databases/(default)/documents/auth_sessions/%s?key=%s" % [PROJECT_ID, _handshake_session_id, API_KEY]
	_handshake_http = HTTPRequest.new()
	_handshake_http.timeout = 5.0
	add_child(_handshake_http)
	
	_handshake_http.request_completed.connect(func(_res: int, code: int, _hdrs: PackedStringArray, body: PackedByteArray):
		if _handshake_http:
			_handshake_http.queue_free()
			_handshake_http = null
			
		if not _is_waiting_for_cloud_handshake:
			return
			
		if code == 200:
			var txt = body.get_string_from_utf8()
			var parsed = JSON.parse_string(txt)
			if typeof(parsed) == TYPE_DICTIONARY and parsed.has("fields"):
				var fields = parsed.get("fields", {})
				var email = str(fields.get("email", {}).get("stringValue", ""))
				var user_name = str(fields.get("name", {}).get("stringValue", ""))
				if not email.is_empty():
					print("[CloudSync] ✅ Cloud Handshake exitoso para: %s (%s)" % [user_name, email])
					var session_to_delete = _handshake_session_id
					_stop_cloud_handshake()
					_delete_cloud_session(session_to_delete)
					google_oauth_completed.emit(true, email, user_name, "")
	)
	var err = _handshake_http.request(url, _get_nocache_headers(), HTTPClient.METHOD_GET)
	if err != OK:
		if _handshake_http:
			_handshake_http.queue_free()
			_handshake_http = null

func _delete_cloud_session(session_id: String) -> void:
	var del_http = HTTPRequest.new()
	del_http.timeout = 5.0
	add_child(del_http)
	del_http.request_completed.connect(func(_r, _c, _h, _b): del_http.queue_free())
	var del_url = "https://firestore.googleapis.com/v1/projects/%s/databases/(default)/documents/auth_sessions/%s?key=%s" % [PROJECT_ID, session_id, API_KEY]
	del_http.request(del_url, _get_nocache_headers(), HTTPClient.METHOD_DELETE)

func stop_google_oauth_server() -> void:
	_is_waiting_for_oauth = false
	_is_waiting_for_web_oauth = false
	_stop_cloud_handshake()
	if _auth_server:
		_auth_server.stop()
		_auth_server = null

func _handle_auth_client_connection(peer: StreamPeerTCP) -> void:
	peer.poll()
	var bytes_avail = peer.get_available_bytes()
	var attempts = 0
	while bytes_avail == 0 and attempts < 20:
		OS.delay_msec(10)
		peer.poll()
		bytes_avail = peer.get_available_bytes()
		attempts += 1
		
	if bytes_avail == 0:
		print("[CloudSync Auth] Client connected but sent 0 bytes.")
		peer.disconnect_from_host()
		return
		
	var req_text = peer.get_utf8_string(bytes_avail)
	var first_line = req_text.split("\r\n")[0]
	print("[CloudSync Auth] Received HTTP Request: ", first_line)
	var tokens = first_line.split(" ")
	if tokens.size() < 2:
		peer.disconnect_from_host()
		return
		
	var path_and_query = tokens[1]
	
	if path_and_query == "/" or path_and_query.begins_with("/?"):
		var html = _get_oauth_html_content()
		var html_bytes = html.to_utf8_buffer()
		var resp = "HTTP/1.1 200 OK\r\n"
		resp += "Content-Type: text/html; charset=UTF-8\r\n"
		resp += "Content-Length: %d\r\n" % html_bytes.size()
		resp += "Access-Control-Allow-Origin: *\r\n"
		resp += "Connection: close\r\n\r\n"
		peer.put_data(resp.to_utf8_buffer())
		peer.put_data(html_bytes)
		peer.disconnect_from_host()
		
	elif path_and_query.begins_with("/callback"):
		var email = ""
		var display_name = ""
		var uid = ""
		
		var q_idx = path_and_query.find("?")
		if q_idx != -1:
			var query_str = path_and_query.substr(q_idx + 1)
			var pairs = query_str.split("&")
			for pair in pairs:
				var kv = pair.split("=")
				if kv.size() == 2:
					var k = kv[0].uri_decode()
					var v = kv[1].uri_decode()
					if k == "email":
						email = v.strip_edges()
					elif k == "name":
						display_name = v.strip_edges()
					elif k == "uid":
						uid = v.strip_edges()
						
		var ok_json = "{\"status\":\"ok\"}"
		var ok_bytes = ok_json.to_utf8_buffer()
		var resp = "HTTP/1.1 200 OK\r\n"
		resp += "Content-Type: application/json\r\n"
		resp += "Content-Length: %d\r\n" % ok_bytes.size()
		resp += "Access-Control-Allow-Origin: *\r\n"
		resp += "Connection: close\r\n\r\n" + ok_json
		peer.put_data(resp.to_utf8_buffer())
		peer.disconnect_from_host()
		
		stop_google_oauth_server()
		if not email.is_empty():
			google_oauth_completed.emit(true, email, display_name, "")
		else:
			google_oauth_completed.emit(false, "", "", "No se recibió un correo válido de Google.")
	else:
		var resp = "HTTP/1.1 404 Not Found\r\nConnection: close\r\n\r\n"
		peer.put_data(resp.to_utf8_buffer())
		peer.disconnect_from_host()

func _get_oauth_html_content() -> String:
	return """<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Pokémon Battle Frontier - Conectar con Google</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Press+Start+2P&family=Rubik:wght@400;600;700&display=swap" rel="stylesheet">
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      background: radial-gradient(circle at 50% 30%, #151d2a 0%, #0a0d14 100%);
      color: #e0e6ed;
      font-family: 'Rubik', sans-serif;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      min-height: 100vh;
      padding: 20px;
    }
    .card {
      background: rgba(18, 26, 38, 0.95);
      border: 2px solid #2a3b50;
      border-radius: 16px;
      box-shadow: 0 12px 40px rgba(0, 0, 0, 0.6), 0 0 20px rgba(78, 161, 255, 0.15);
      padding: 36px 32px;
      max-width: 440px;
      width: 100%;
      text-align: center;
      backdrop-filter: blur(10px);
    }
    .title-logo {
      font-family: 'Press Start 2P', monospace;
      font-size: 13px;
      color: #ffd700;
      text-shadow: 2px 2px 0px #000;
      margin-bottom: 12px;
      letter-spacing: 1px;
    }
    .subtitle {
      font-size: 13px;
      color: #8da2be;
      margin-bottom: 24px;
      line-height: 1.5;
    }
    .btn-google {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      gap: 12px;
      width: 100%;
      background: #ffffff;
      color: #1f1f1f;
      border: none;
      border-radius: 10px;
      padding: 14px 20px;
      font-size: 15px;
      font-weight: 600;
      font-family: 'Rubik', sans-serif;
      cursor: pointer;
      box-shadow: 0 4px 12px rgba(0,0,0,0.3);
      transition: all 0.2s ease;
    }
    .btn-google:hover {
      background: #f1f3f4;
      transform: translateY(-2px);
      box-shadow: 0 6px 16px rgba(0,0,0,0.4);
    }
    .btn-google:active {
      transform: translateY(0);
    }
    .btn-google:disabled {
      opacity: 0.6;
      cursor: not-allowed;
      transform: none;
    }
    .status-box {
      margin-top: 20px;
      font-size: 13px;
      min-height: 24px;
      color: #9cb3ce;
    }
    .footer-note {
      margin-top: 24px;
      font-size: 11px;
      color: #55687d;
    }
  </style>
  <script type="module">
    import { initializeApp } from "https://www.gstatic.com/firebasejs/10.12.0/firebase-app.js";
    import { getAuth, signInWithPopup, GoogleAuthProvider } from "https://www.gstatic.com/firebasejs/10.12.0/firebase-auth.js";

    const firebaseConfig = {
      apiKey: "AIzaSyDDe8OAmIP6vAF1iScuSb0Wo35X3o60-Bg",
      authDomain: "pokemon-battle-frontier-4add7.firebaseapp.com",
      projectId: "pokemon-battle-frontier-4add7"
    };

    const app = initializeApp(firebaseConfig);
    const auth = getAuth(app);
    const provider = new GoogleAuthProvider();
    provider.setCustomParameters({ prompt: 'select_account' });

    async function triggerGoogleLogin() {
      const btn = document.getElementById('btn-google');
      const status = document.getElementById('status-msg');
      btn.disabled = true;
      status.innerHTML = "⏳ Abriendo selector de cuenta de Google...";

      try {
        const result = await signInWithPopup(auth, provider);
        const user = result.user;
        const alias = user.displayName || user.email.split('@')[0];
        status.innerHTML = "✅ Conectado como <b>" + alias + "</b> (" + user.email + "). Sincronizando con el juego...";
        
        const callbackUrl = '/callback?email=' + encodeURIComponent(user.email) + 
                            '&name=' + encodeURIComponent(alias) + 
                            '&uid=' + encodeURIComponent(user.uid);
                            
        await fetch(callbackUrl);
        
        document.getElementById('main-card').innerHTML = 
          '<div style="font-size:48px;margin-bottom:12px;">✨</div>' +
          '<h2 style="color:#2ecc71;margin-bottom:8px;">¡Sesión Iniciada!</h2>' +
          '<p style="color:#e0e6ed;font-size:15px;margin-bottom:12px;">Bienvenido, <b>' + alias + '</b></p>' +
          '<p style="color:#8da2be;font-size:13px;margin-bottom:20px;">Tu cuenta <code>' + user.email + '</code> fue vinculada con éxito.</p>' +
          '<p style="color:#ffd700;font-size:12px;">Ya puedes cerrar esta pestaña y volver al juego Pokémon Battle Frontier.</p>';
        
        setTimeout(() => { window.close(); }, 3000);
      } catch (err) {
        console.error("Auth error:", err);
        btn.disabled = false;
        if (err.code === 'auth/popup-closed-by-user') {
          status.innerHTML = "⚠️ Cancelaste la ventana de inicio de sesión. Haz clic de nuevo para reintentar.";
        } else if (err.code === 'auth/popup-blocked') {
          status.innerHTML = "⚠️ Tu navegador bloqueó la ventana emergente. Permite ventanas emergentes o haz clic nuevamente en el botón.";
        } else {
          status.innerHTML = "❌ Error: " + err.message;
        }
      }
    }

    window.triggerGoogleLogin = triggerGoogleLogin;
  </script>
</head>
<body>
  <div class="card" id="main-card">
    <div style="font-size:36px;margin-bottom:10px;">⚡</div>
    <div class="title-logo">POKÉMON BATTLE FRONTIER</div>
    <div class="subtitle">Haz clic en el botón a continuación para elegir tu cuenta de Google y sincronizar tu partida en la nube.</div>
    <button id="btn-google" class="btn-google" onclick="triggerGoogleLogin()">
      <svg width="20" height="20" viewBox="0 0 24 24">
        <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
        <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
        <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.06H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.94l2.85-2.22.81-.63z"/>
        <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.06l3.66 2.84c.87-2.6 3.3-4.52 6.16-4.52z"/>
      </svg>
      Continuar con Google
    </button>
    <div class="status-box" id="status-msg">Haz clic en 'Continuar con Google' arriba para conectar tu cuenta.</div>
    <div class="footer-note">Google Cloud Firestore • Cifrado seguro</div>
  </div>
</body>
</html>"""
