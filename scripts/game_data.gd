extends Node

# --- CLASES DE DATOS ---
class MoveData:
	var name: String
	var type: String
	var base_damage: int
	var cost: int
	var min_energy_req: int
	var can_boost: bool
	var boost_cost: int
	var boost_damage: int
	var boost_applies_burn: bool
	var effect_type: String = "NONE"
	var is_squirtle_shell: bool = false
	var is_pichu_shock: bool = false
	var reduces_foe_speed: bool = false
	var causes_poison: bool = false
	var description: String

	func _init(p_name: String, p_type: String, p_dmg: int, p_cost: int, p_min_req: int, p_can_boost: bool, p_boost_cost: int, p_boost_dmg: int, p_burn: bool, p_desc: String):
		name = p_name
		type = p_type
		base_damage = p_dmg
		cost = p_cost
		min_energy_req = p_min_req
		can_boost = p_can_boost
		boost_cost = p_boost_cost
		boost_damage = p_boost_dmg
		boost_applies_burn = p_burn
		description = p_desc

class PokemonData:
	var id: int
	var pokedex_num: String
	var stage: String = "Basic"
	var name: String
	var max_hp: int
	var current_hp: int
	var max_energy: int
	var current_energy: int
	var speed: int
	var temp_speed_mod: int = 0
	var speed_mod_expires_round: int = 0
	var recover_amount: int = 1
	var type: String
	var weakness: String
	var resistant: String
	var burn_turns: int = 0
	var burn_dmg: int = 1
	var shield_breaker_bonus: int = 0
	var is_poisoned: bool = false
	var toxic_envenomed: bool = false
	var is_flinched: bool = false
	var was_flinched_last_round: bool = false
	var flinched_this_round: bool = false
	var took_damage_last_turn: bool = false
	var is_paralyzed: bool = false
	var paralyze_turns: int = 0
	var is_asleep_turns: int = 0
	var immune_sleep_rounds: int = 0
	var is_frozen: bool = false
	var frozen_turns: int = 0
	var is_confused: bool = false
	var confused_turns: int = 0
	var is_seeded_turns: int = 0
	var is_constricted_dmg: int = 0
	var constricted_turns: int = 0
	var shield_reduction: int = 0
	var shield_turns: int = 0
	var wall_hp: int = 0
	var is_evasive: bool = false
	var evasive_reflects_dmg: int = 0
	var is_digging: bool = false
	var rest_next_turn: bool = false
	var charging_move: String = ""
	var last_move_used: String = ""
	var consecutive_move_count: int = 0
	var damage_buff: int = 0
	var damage_buff_turns: int = 0
	var foe_damage_debuff: int = 0
	var foe_damage_debuff_turns: int = 0
	var lock_foe_move: String = ""
	var amnesia_active: bool = false
	var payday_used: bool = false
	var ground_boost_turns: int = 0
	var texture_path: String
	var passive_name: String = ""
	var passive_desc: String = ""
	var has_passive: bool = false
	var rarity: String = "Common"
	var tier: String = "C"
	var evolves_to: String = ""
	var current_exp: int = 0
	var max_exp: int = 10
	var moves: Array = [] # Siempre 2 movimientos activos

	func get_required_exp() -> int:
		if evolves_to.strip_edges() == "":
			return 0
		var st = stage.strip_edges().to_lower()
		if st == "basic":
			return 10
		elif st == "stage 1":
			return 25
		return 0 # Stage 2 u otras fases no evolucionan más

	func can_evolve_exp() -> bool:
		var req = get_required_exp()
		return req > 0 and current_exp >= req

	func get_effective_speed() -> int:
		return max(1, speed + temp_speed_mod)

# Base de datos de movimientos cargada desde poke_moves.csv
var moves_catalog: Dictionary = {}

# Catálogo completo de Pokémon cargado desde poke_stats.csv
var pokemon_catalog: Dictionary = {} # id -> raw_dict
var all_pokemon_ids: Array[int] = []

# Colección desbloqueada del jugador (todos disponibles)
var player_unlocked_ids: Array[int] = []

# --- PERFIL Y PROGRESO DEL JUGADOR ---
const SAVE_FILE_PATH: String = "user://profile_save.json"

var profile_name: String = "Trainer"
var profile_email: String = ""
var profile_id: String = ""
var profile_auth_provider: String = "Guest" # "Guest", "Google Cloud", "Local"
var profile_is_logged_in: bool = false
var profile_created_at: String = ""
var profile_cloud_key: String = ""
var profile_welcome_claimed: bool = false

# --- SISTEMA DE AMIGOS (FRIENDS) ---
signal friends_updated()
var player_friends: Array = [] # Array de diccionarios: [{ "alias": String, "email": String, "id": String, "added_at": String }]

func get_friends_count() -> int:
	return player_friends.size()

func is_friend(identifier: String) -> bool:
	var clean = identifier.strip_edges().to_lower()
	if clean.is_empty():
		return false
	for f in player_friends:
		if f.get("email", "").to_lower() == clean or f.get("id", "").to_lower() == clean or f.get("alias", "").to_lower() == clean:
			return true
	return false

func add_friend(alias: String, email: String, p_id: String) -> bool:
	var clean_email = email.strip_edges()
	var clean_alias = alias.strip_edges()
	var clean_id = p_id.strip_edges()
	
	if clean_alias.is_empty():
		clean_alias = "Trainer"
		
	# Verificar si ya existe en la lista de amigos
	for f in player_friends:
		if not clean_email.is_empty() and f.get("email", "").to_lower() == clean_email.to_lower():
			return false
		if not clean_id.is_empty() and f.get("id", "").to_lower() == clean_id.to_lower():
			return false
			
	var new_friend = {
		"alias": clean_alias,
		"email": clean_email,
		"id": clean_id,
		"added_at": Time.get_datetime_string_from_system()
	}
	player_friends.append(new_friend)
	save_profile()
	friends_updated.emit()
	print("[GameData] 👥 Friend added: %s (%s - %s). Total friends: %d" % [clean_alias, clean_email, clean_id, player_friends.size()])
	return true

func remove_friend(identifier: String) -> bool:
	var clean = identifier.strip_edges().to_lower()
	if clean.is_empty():
		return false
	var found_idx = -1
	for i in range(player_friends.size()):
		var f = player_friends[i]
		if f.get("email", "").to_lower() == clean or f.get("id", "").to_lower() == clean or f.get("alias", "").to_lower() == clean:
			found_idx = i
			break
	if found_idx != -1:
		var removed = player_friends[found_idx]
		player_friends.remove_at(found_idx)
		save_profile()
		friends_updated.emit()
		print("[GameData] 👥 Friend removed: %s" % removed.get("alias", ""))
		return true
	return false

# Estadísticas personales registradas
var stats_tournaments_won: int = 0
var stats_battles_won: int = 0
var stats_battles_total: int = 0
var stats_packs_opened: int = 0

# Ajustes de configuración
var settings_music_volume: float = 0.8 # 0.0 to 1.0
var settings_music_muted: bool = false
var settings_sfx_volume: float = 0.9 # 0.0 to 1.0
var settings_sfx_muted: bool = false

# Sesión activa (para mostrar el Login Screen en el primer acceso)
var session_entered_lobby: bool = false

# Selección para Combate Libre
var player_team_ids: Array[int] = [0, 1, 2]
var enemy_team_ids: Array[int] = [4, 6, 5]

# --- ESTADO DE CAMPAÑA (TORNEO Y AVENTURA) ---
const TOURNAMENT_TOTAL_MATCHES: int = 9

var is_campaign_mode: bool = false
var campaign_submode: String = "TOURNAMENT" # "TOURNAMENT" or "ADVENTURE"
var is_pvp_mode: bool = false
var is_online_pvp: bool = false
var online_rival_name: String = "Rival"

# Modo Torneo:
var campaign_match_number: int = 1 # 1 to 9 (10 = Tournament Champion)
var campaign_gold: int = 0
var campaign_inventory: Dictionary = {"potion": 0, "revive": 0, "remedy": 0, "ether": 0}
var campaign_player_team_state: Array = []
var current_tournament_rival_team: Array[int] = []
var current_tournament_rival_match: int = -1

# Modo Aventura (Episodios):
var adventure_current_episode: int = 1
var adventure_current_stage: int = 1 # 1 to 4
var adventure_gold: int = 0
var adventure_inventory: Dictionary = {"potion": 0, "revive": 0, "remedy": 0, "ether": 0}
var adventure_player_team_state: Array = []
var adventure_completed_episodes: Array[int] = []
var adventure_unlocked_episodes: Array[int] = [1]
var last_adventure_episode_conquered: bool = false

const ADVENTURE_EPISODES: Dictionary = {
	1: {
		"id": 1,
		"title": "Episode I: Pewter City Gym",
		"subtitle": "Journey through Route 2 & Viridian Forest to challenge Brock!",
		"reward_diamonds_first_clear": 20,
		"stages": [
			{
				"stage_num": 1,
				"trainer_title": "Bug Catcher",
				"trainer_name": "Bug Catcher Sammy",
				"intro": "Go, my bug Pokémon! String Shot won't let you escape!",
				"outro": "My bug Pokémon couldn't hold on...",
				"team_pokemon_names": ["Caterpie", "Weedle"]
			},
			{
				"stage_num": 2,
				"trainer_title": "Fisherman",
				"trainer_name": "Fisherman Barny",
				"intro": "Splash all you want, but my water Pokémon fight hard!",
				"outro": "Hook, line, and sinker... I lost!",
				"team_pokemon_names": ["Magikarp", "Magikarp", "Goldeen"]
			},
			{
				"stage_num": 3,
				"trainer_title": "Beautiful Girl",
				"trainer_name": "Beauty Haley",
				"intro": "Aren't my baby Pokémon adorable? Don't underestimate their charm!",
				"outro": "Oh no! My precious sweeties!",
				"team_pokemon_names": ["Igglybuff", "Cleffa"]
			},
			{
				"stage_num": 4,
				"trainer_title": "Gym Leader Brock",
				"trainer_name": "Gym Leader Brock",
				"is_boss": true,
				"badge_name": "Boulder Badge",
				"intro": "I'm Brock, the Pewter Gym Leader! My rock-hard willpower will test your limits!",
				"outro": "Incredible willpower! You've truly earned the Boulder Badge!",
				"team_pokemon_names": ["Geodude", "Onyx"]
			}
		]
	},
	2: {
		"id": 2,
		"title": "Episode II: Cerulean City Gym",
		"subtitle": "Traverse Mt. Moon and Route 4 to challenge Misty!",
		"locked": true,
		"reward_diamonds_first_clear": 25,
		"stages": []
	}
}

# --- TABLA GLOBAL DE TIPOS ELEMENTALES (DEBILIDADES Y RESISTENCIAS) ---
var global_type_chart: Dictionary = {
	"DARK": { "weakness": "VARIABLE", "resistance": "PSYCHIC" },
	"ELECTRIC": { "weakness": "GROUND", "resistance": "WATER" },
	"THUNDER": { "weakness": "GROUND", "resistance": "WATER" },
	"FIGHTING": { "weakness": "PSYCHIC", "resistance": "DARK" },
	"FIRE": { "weakness": "WATER", "resistance": "GRASS" },
	"GRASS": { "weakness": "FIRE", "resistance": "GROUND" },
	"GROUND": { "weakness": "GRASS", "resistance": "ELECTRIC" },
	"NORMAL": { "weakness": "FIGHTING", "resistance": "VARIABLE" },
	"PSYCHIC": { "weakness": "DARK", "resistance": "FIGHTING" },
	"WATER": { "weakness": "ELECTRIC", "resistance": "FIRE" }
}

func normalize_type_key(t: String) -> String:
	var up = t.strip_edges().to_upper()
	if up == "THUNDER":
		return "ELECTRIC"
	return up

func types_match(type1: String, type2: String) -> bool:
	if type1 == "" or type2 == "" or type1 == "NONE" or type2 == "NONE":
		return false
	return normalize_type_key(type1) == normalize_type_key(type2)

func get_effective_resistances(pkmn_type: String, pkmn_resistant: String) -> Array[String]:
	var norm_type = normalize_type_key(pkmn_type)
	var list: Array[String] = []
	if pkmn_resistant != "" and pkmn_resistant != "NONE" and pkmn_resistant != "VARIABLE":
		var norm_r = normalize_type_key(pkmn_resistant)
		if norm_r != "" and norm_r != "NONE" and not list.has(norm_r):
			list.append(norm_r)
	# Resistencia por naturaleza: mismo tipo excepto NORMAL
	if norm_type != "" and norm_type != "NONE" and norm_type != "NORMAL" and not list.has(norm_type):
		list.append(norm_type)
	return list

func is_attack_resisted(def_type: String, def_resistant: String, atk_type: String) -> bool:
	var norm_atk = normalize_type_key(atk_type)
	if norm_atk == "" or norm_atk == "NONE":
		return false
	var resists = get_effective_resistances(def_type, def_resistant)
	return resists.has(norm_atk)

func get_default_weakness_for_type(type_key: String) -> String:
	var norm = normalize_type_key(type_key)
	if global_type_chart.has(norm):
		var w = str(global_type_chart[norm].get("weakness", "")).strip_edges().to_upper()
		if w != "" and w != "VARIABLE" and w != "NONE":
			return w
	return ""

func get_default_resistance_for_type(type_key: String) -> String:
	var norm = normalize_type_key(type_key)
	if global_type_chart.has(norm):
		var r = str(global_type_chart[norm].get("resistance", "")).strip_edges().to_upper()
		if r != "" and r != "VARIABLE" and r != "NONE":
			return r
	return ""

func load_types_from_csv() -> void:
	var paths_to_try = [
		"res://data/poke_types.csv",
		"D:/Games/Pokemon Battle Frontier/PKMN/poke_types.csv"
	]
	var chosen_path = ""
	var file: FileAccess = null
	
	for p in paths_to_try:
		if not FileAccess.file_exists(p):
			continue
		var candidate = FileAccess.open(p, FileAccess.READ)
		if candidate:
			chosen_path = p
			file = candidate
			break
			
	if not file:
		print("Using default global type chart.")
		return
		
	print("Loading type chart from: ", chosen_path)
	var headers = file.get_csv_line()
	var col_map: Dictionary = {}
	for i in range(headers.size()):
		col_map[headers[i].strip_edges().to_lower()] = i
		
	if not col_map.has("type") or not col_map.has("weakness") or not col_map.has("resistance"):
		file.close()
		print("WARNING: poke_types.csv does not have expected columns (type, weakness, resistance).")
		return
		
	while not file.eof_reached():
		var row = file.get_csv_line()
		if row.size() < 3 or row[col_map["type"]].strip_edges() == "":
			continue
		var t = row[col_map["type"]].strip_edges().to_upper()
		var w = row[col_map["weakness"]].strip_edges().to_upper()
		var r = row[col_map["resistance"]].strip_edges().to_upper()
		
		global_type_chart[t] = { "weakness": w, "resistance": r }
		if t == "ELECTRIC":
			global_type_chart["THUNDER"] = { "weakness": w, "resistance": r }
		elif t == "THUNDER":
			global_type_chart["ELECTRIC"] = { "weakness": w, "resistance": r }
			
	file.close()
	print("Global type chart loaded successfully. Total registered types: ", global_type_chart.size())

func _ready() -> void:
	_setup_global_font_fallbacks()
	if OS.has_feature("mobile") or OS.has_feature("android") or OS.has_feature("ios"):
		DisplayServer.screen_set_orientation(DisplayServer.SCREEN_PORTRAIT)
	load_types_from_csv()
	load_moves_from_csv()
	load_pokemon_from_csv()
	load_profile()

func _setup_global_font_fallbacks() -> void:
	var emoji_path = "res://assets/fonts/emoji_font.ttf"
	if ResourceLoader.exists(emoji_path):
		var emoji_font = load(emoji_path)
		if emoji_font:
			var default_font = ThemeDB.fallback_font
			if default_font is Font and not default_font.fallbacks.has(emoji_font):
				default_font.fallbacks.append(emoji_font)
				print("[GameData] 🔤 Global emoji font fallback registered on ThemeDB!")

func load_moves_from_csv() -> void:
	moves_catalog.clear()
	var paths_to_try = [
		"res://data/poke_moves.csv",
		"D:/Games/Pokemon Battle Frontier/PKMN/poke_moves.csv"
	]
	var chosen_path = ""
	var file: FileAccess = null
	
	for p in paths_to_try:
		if not FileAccess.file_exists(p):
			continue
		var candidate = FileAccess.open(p, FileAccess.READ)
		if candidate:
			chosen_path = p
			file = candidate
			break
			
	if not file:
		print("ERROR: poke_moves.csv not found!")
		return
		
	print("Loading moves database from: ", chosen_path)
	var raw_headers = file.get_csv_line()
	var col_map: Dictionary = {}
	for i in range(raw_headers.size()):
		col_map[raw_headers[i].strip_edges().to_lower()] = i
		
	while not file.eof_reached():
		var row = file.get_csv_line()
		if row.size() < 2 or row[0].strip_edges() == "":
			continue
			
		var get_val = func(col_name: String, fallback_idx: int, def_val: String = "") -> String:
			var k = col_name.to_lower()
			if col_map.has(k):
				var idx = col_map[k]
				if idx < row.size():
					var v = row[idx].strip_edges()
					if v != "": return v
			elif fallback_idx < row.size():
				var v = row[fallback_idx].strip_edges()
				if v != "": return v
			return def_val
			
		var m_id = int(get_val.call("id", 0, "0"))
		var m_name = get_val.call("name", 1, "")
		if m_name == "":
			continue
		var m_type = get_val.call("type", 2, "NORMAL").to_upper()
		var m_dmg = int(get_val.call("base_dmg", 3, "3"))
		var m_cost = int(get_val.call("cost", 4, "0"))
		var m_req = int(get_val.call("min_energy_req", 5, "1"))
		var m_boost_cost = int(get_val.call("boost_cost", 6, "0"))
		var m_boost_dmg = int(get_val.call("boost_dmg", 7, "0"))
		var m_effect_type = get_val.call("effect_type", 8, "NONE").to_upper()
		var m_desc = get_val.call("description", 9, "")
		var m_sfx = get_val.call("sfx", 10, "")
		
		var move_entry = {
			"id": m_id,
			"name": m_name,
			"type": m_type,
			"dmg": m_dmg,
			"cost": m_cost,
			"req": m_req,
			"boost_cost": m_boost_cost,
			"boost_dmg": m_boost_dmg,
			"effect_type": m_effect_type,
			"desc": m_desc,
			"sfx": m_sfx
		}
		var clean_name = m_name.strip_edges().to_lower()
		moves_catalog[clean_name] = move_entry
		moves_catalog[str(m_id)] = move_entry
		if clean_name == "poison powder":
			moves_catalog["posion powder"] = move_entry
		elif clean_name == "posion powder":
			moves_catalog["poison powder"] = move_entry
			
	file.close()
	print("Moves loaded successfully. Total: ", moves_catalog.size())

func get_move_data(identifier: String) -> Dictionary:
	var key = identifier.strip_edges().to_lower()
	if moves_catalog.has(key):
		return moves_catalog[key]
	return {
		"id": 0,
		"name": identifier if identifier != "" else "Tackle",
		"type": "NORMAL",
		"dmg": 3,
		"cost": 0,
		"req": 1,
		"boost_cost": 0,
		"boost_dmg": 0,
		"effect_type": "NONE",
		"desc": "",
		"sfx": ""
	}

func load_pokemon_from_csv() -> void:
	pokemon_catalog.clear()
	all_pokemon_ids.clear()
	
	var paths_to_try = [
		"res://data/poke_stats.csv",
		"D:/Games/Pokemon Battle Frontier/PKMN/poke_stats.csv"
	]
	
	var chosen_path = ""
	var file: FileAccess = null
	var col_map: Dictionary = {}
	
	for p in paths_to_try:
		if not FileAccess.file_exists(p):
			continue
		var candidate = FileAccess.open(p, FileAccess.READ)
		if not candidate:
			continue
		var raw_headers = candidate.get_csv_line()
		var temp_map: Dictionary = {}
		for i in range(raw_headers.size()):
			temp_map[raw_headers[i].strip_edges().to_lower()] = i
		if temp_map.has("name") and temp_map.has("type") and temp_map.has("hp"):
			chosen_path = p
			file = candidate
			col_map = temp_map
			break
		else:
			print("Warning: '%s' does not contain required columns (name, type, hp). Searching fallback..." % p)
			candidate.close()
			
	if not file:
		print("ERROR: No valid poke_stats.csv file found!")
		return
		
	print("Loading Pokémon catalog from: ", chosen_path)
		
	while not file.eof_reached():
		var row = file.get_csv_line()
		if row.size() < 4 or row[0].strip_edges() == "":
			continue
			
		var get_val = func(col_name: String, default_val: String = "") -> String:
			var key = col_name.to_lower()
			if col_map.has(key):
				var idx = col_map[key]
				if idx < row.size():
					var v = row[idx].strip_edges()
					if v != "":
						return v
			return default_val
			
		var raw_name = get_val.call("name", "")
		if raw_name == "":
			continue
			
		var pkmn_id = int(get_val.call("id", "0"))
		var p_num = get_val.call("pokedex_num", "1")
		var p_stage = get_val.call("stage", "Basic")
		if p_stage == "":
			p_stage = "Basic"
		var p_name = raw_name
		
		# Fallback inteligente de estadísticas si aún no se han configurado en el CSV
		var st_low = p_stage.strip_edges().to_lower()
		var def_hp = 10
		var def_energy = 3
		var def_speed = 2
		var def_recover = 1
		
		if st_low == "stage 1":
			def_hp = 20
			def_energy = 5
			def_speed = 2
			def_recover = 2
		elif st_low == "stage 2":
			def_hp = 30
			def_energy = 8
			def_speed = 3
			def_recover = 3
		elif st_low in ["legendary", "legendaria"]:
			def_hp = 35
			def_energy = 8
			def_speed = 4
			def_recover = 3
			
		var raw_hp_val = get_val.call("hp", "")
		var p_hp = int(raw_hp_val) if raw_hp_val != "" and int(raw_hp_val) > 0 else def_hp
		
		var raw_energy_val = get_val.call("energy", "")
		var p_energy = int(raw_energy_val) if raw_energy_val != "" and int(raw_energy_val) > 0 else def_energy
		
		var raw_spd_val = get_val.call("speed", "")
		var p_spd = int(raw_spd_val) if raw_spd_val != "" and int(raw_spd_val) > 0 else def_speed
		
		var raw_rec_val = get_val.call("recover", "")
		var p_rec = int(raw_rec_val) if raw_rec_val != "" and int(raw_rec_val) > 0 else def_recover
		
		var p_type = get_val.call("type", "NORMAL").to_upper()
		if p_type == "":
			p_type = "NORMAL"
		var raw_weak = get_val.call("weakness", "").strip_edges().to_upper()
		var raw_res = get_val.call("resistant", "").strip_edges().to_upper()
		
		# Debilidad: Prioridad a datos del PKMN sobre la tabla global
		var p_weak: String = "NONE"
		if raw_weak != "" and raw_weak != "VARIABLE":
			p_weak = raw_weak
		else:
			var def_w = get_default_weakness_for_type(p_type)
			p_weak = def_w if def_w != "" else "NONE"
			
		# Resistencia: Prioridad a datos del PKMN sobre la tabla global
		var p_res: String = "NONE"
		if raw_res != "" and raw_res != "VARIABLE":
			p_res = raw_res
		else:
			var def_r = get_default_resistance_for_type(p_type)
			p_res = def_r if def_r != "" else "NONE"
			
		var p_tex = get_val.call("texture_file", "")
		if p_tex == "":
			p_tex = "%s.png" % str(p_num).pad_zeros(3)
		
		# Movimiento Pasivo (Opcional)
		var pas_name = get_val.call("passive_name", "")
		var pas_desc = get_val.call("passive_desc", "")
		
		# Referencias a Movimientos Activos (con fallback a Tackle si no están definidos)
		var m1_ref = get_val.call("move1", "")
		if m1_ref == "":
			m1_ref = "Tackle"
		var m2_ref = get_val.call("move2", "")
		if m2_ref == "":
			m2_ref = m1_ref
		
		var m1_data = get_move_data(m1_ref)
		var m2_data = get_move_data(m2_ref)
		
		# Parámetro de disponibilidad al inicio (Iniciales / Starter)
		var p_unlocked_start_str = get_val.call("unlocked_start", "")
		if p_unlocked_start_str == "":
			p_unlocked_start_str = get_val.call("starter", "")
		if p_unlocked_start_str == "":
			p_unlocked_start_str = get_val.call("available_start", "")

		var is_starter: bool = false
		if p_unlocked_start_str != "":
			is_starter = p_unlocked_start_str.to_lower() in ["true", "1", "yes", "si"]
		else:
			is_starter = (pkmn_id in [0, 1, 2, 3])
		
		# Parámetro de Evolución
		var p_evolves_to = get_val.call("evolves_to", "").strip_edges()

		# Parámetro de Rareza (Rarity) para apertura de sobres
		var raw_rarity = get_val.call("rarity", "")
		var p_rarity = "Common"
		if raw_rarity != "":
			p_rarity = raw_rarity
		else:
			if st_low in ["legendary", "legendaria"]:
				p_rarity = "Legendary"
			elif st_low == "stage 2":
				p_rarity = "Epic"
			elif st_low == "stage 1":
				p_rarity = "Rare"
			else:
				p_rarity = "Common"

		var p_tier = get_val.call("tier", "C").strip_edges().to_upper()
		if p_tier == "":
			p_tier = "C"

		var raw_dict = {
			"id": pkmn_id,
			"pokedex_num": p_num,
			"stage": p_stage,
			"rarity": p_rarity,
			"tier": p_tier,
			"evolves_to": p_evolves_to,
			"name": p_name,
			"hp": p_hp,
			"energy": p_energy,
			"speed": p_spd,
			"type": p_type,
			"weakness": p_weak,
			"resistant": p_res,
			"recover": p_rec,
			"texture_file": p_tex,
			"texture_path": "res://assets/cards/" + p_tex,
			"unlocked_start": is_starter,
			
			"passive_name": pas_name,
			"passive_desc": pas_desc,
			
			"m1_name": m1_data["name"],
			"m1_type": m1_data["type"],
			"m1_dmg": m1_data["dmg"],
			"m1_cost": m1_data["cost"],
			"m1_req": m1_data["req"],
			"m1_boost_cost": m1_data["boost_cost"],
			"m1_boost_dmg": m1_data["boost_dmg"],
			"m1_effect_type": m1_data["effect_type"],
			"m1_effect": m1_data["desc"],
			
			"m2_name": m2_data["name"],
			"m2_type": m2_data["type"],
			"m2_dmg": m2_data["dmg"],
			"m2_cost": m2_data["cost"],
			"m2_req": m2_data["req"],
			"m2_boost_cost": m2_data["boost_cost"],
			"m2_boost_dmg": m2_data["boost_dmg"],
			"m2_effect_type": m2_data["effect_type"],
			"m2_effect": m2_data["desc"]
		}
		
		pokemon_catalog[pkmn_id] = raw_dict
		all_pokemon_ids.append(pkmn_id)
		
	file.close()
	player_unlocked_ids.clear()
	player_friends.clear()
	for id in all_pokemon_ids:
		if pokemon_catalog[id].get("unlocked_start", false):
			player_unlocked_ids.append(id)
	print("Catalog loaded successfully. Total Pokémon: %d | Starting unlocked: %d" % [pokemon_catalog.size(), player_unlocked_ids.size()])

func get_pokemon_data(pkmn_id: int) -> Dictionary:
	return pokemon_catalog.get(pkmn_id, {})

func is_pokemon_unlocked(pkmn_id: int) -> bool:
	return pkmn_id in player_unlocked_ids

func unlock_pokemon(pkmn_id: int) -> void:
	if not (pkmn_id in player_unlocked_ids):
		player_unlocked_ids.append(pkmn_id)
		player_unlocked_ids.sort()

func unlock_all_pokemon() -> void:
	for id in all_pokemon_ids:
		if not (id in player_unlocked_ids):
			player_unlocked_ids.append(id)
	player_unlocked_ids.sort()
	print("All cards unlocked. Total: ", player_unlocked_ids.size())

func get_pokemon_id_by_name(pkmn_name: String) -> int:
	var clean = pkmn_name.strip_edges().to_lower()
	if clean == "":
		return -1
	if clean == "onix":
		clean = "onyx"
	for id in all_pokemon_ids:
		var d = pokemon_catalog.get(id, {})
		if str(d.get("name", "")).strip_edges().to_lower() == clean:
			return int(id)
	return -1

func get_evolution_target_id(current_id: int) -> int:
	if not pokemon_catalog.has(current_id):
		return -1
	var d = pokemon_catalog[current_id]
	var evo_name = str(d.get("evolves_to", "")).strip_edges()
	if evo_name == "":
		return -1
	return get_pokemon_id_by_name(evo_name)

# Obtiene el estado de evolución de un Pokémon según las cartas que posee el jugador en su colección
func get_pokemon_evolution_chain_status(pkmn_id: int) -> Dictionary:
	if not pokemon_catalog.has(pkmn_id):
		return {
			"has_evolution": false,
			"status": "NONE",
			"text_badge": "— No Evo",
			"icon": "—",
			"color_hex": "#78909C",
			"tooltip": "No evolution data available.",
			"sort_rank": 4
		}
		
	var target1_id = get_evolution_target_id(pkmn_id)
	if target1_id == -1:
		return {
			"has_evolution": false,
			"status": "NONE",
			"text_badge": "— No Evo",
			"icon": "—",
			"color_hex": "#78909C",
			"tooltip": "Basic Pokémon with no evolution line.",
			"sort_rank": 4
		}
		
	var t1_data = pokemon_catalog.get(target1_id, {})
	var t1_name = str(t1_data.get("name", "Stage 1"))
	var t1_unlocked = is_pokemon_unlocked(target1_id)
	
	var target2_id = get_evolution_target_id(target1_id)
	var has_stage2 = (target2_id != -1)
	var t2_name = ""
	var t2_unlocked = false
	if has_stage2:
		var t2_data = pokemon_catalog.get(target2_id, {})
		t2_name = str(t2_data.get("name", "Stage 2"))
		t2_unlocked = is_pokemon_unlocked(target2_id)
		
	if has_stage2:
		if t1_unlocked and t2_unlocked:
			return {
				"has_evolution": true,
				"status": "FULL",
				"target1_id": target1_id,
				"target1_name": t1_name,
				"target1_unlocked": true,
				"has_stage2": true,
				"target2_id": target2_id,
				"target2_name": t2_name,
				"target2_unlocked": true,
				"text_badge": "⏫ S1+S2 ✓",
				"icon": "⏫",
				"color_hex": "#69F0AE",
				"tooltip": "Evolution line fully unlocked!\nEvolves into %s and %s." % [t1_name, t2_name],
				"sort_rank": 1
			}
		elif t1_unlocked:
			return {
				"has_evolution": true,
				"status": "STAGE1_ONLY",
				"target1_id": target1_id,
				"target1_name": t1_name,
				"target1_unlocked": true,
				"has_stage2": true,
				"target2_id": target2_id,
				"target2_name": t2_name,
				"target2_unlocked": false,
				"text_badge": "⏫ S1 ✓",
				"icon": "⏫",
				"color_hex": "#4DD0E1",
				"tooltip": "Evolves into %s (Owned).\nNote: %s is not yet unlocked in your collection." % [t1_name, t2_name],
				"sort_rank": 2
			}
		else:
			return {
				"has_evolution": true,
				"status": "LOCKED",
				"target1_id": target1_id,
				"target1_name": t1_name,
				"target1_unlocked": false,
				"has_stage2": true,
				"target2_id": target2_id,
				"target2_name": t2_name,
				"target2_unlocked": t2_unlocked,
				"text_badge": "🔒 Needs S1",
				"icon": "🔒",
				"color_hex": "#FFB74D",
				"tooltip": "Cannot evolve in tournament: %s card is missing from your collection!" % t1_name,
				"sort_rank": 3
			}
	else:
		# Only 1 evolution stage (Basic -> Stage 1)
		if t1_unlocked:
			return {
				"has_evolution": true,
				"status": "STAGE1_ONLY",
				"target1_id": target1_id,
				"target1_name": t1_name,
				"target1_unlocked": true,
				"has_stage2": false,
				"target2_id": -1,
				"target2_name": "",
				"target2_unlocked": false,
				"text_badge": "⏫ S1 ✓",
				"icon": "⏫",
				"color_hex": "#69F0AE",
				"tooltip": "Ready to evolve into %s!" % t1_name,
				"sort_rank": 2
			}
		else:
			return {
				"has_evolution": true,
				"status": "LOCKED",
				"target1_id": target1_id,
				"target1_name": t1_name,
				"target1_unlocked": false,
				"has_stage2": false,
				"target2_id": -1,
				"target2_name": "",
				"target2_unlocked": false,
				"text_badge": "🔒 Needs S1",
				"icon": "🔒",
				"color_hex": "#FFB74D",
				"tooltip": "Cannot evolve in tournament: %s card is missing from your collection!" % t1_name,
				"sort_rank": 3
			}

# Recompensa dinámica al derrotar un Pokémon según su rareza y fase
func calculate_pkmn_defeat_reward(rarity_str: String, stage_str: String = "") -> Dictionary:
	var r = rarity_str.strip_edges().to_lower()
	var st = stage_str.strip_edges().to_lower()
	var gold = 0
	var diamonds = 0
	
	if r in ["epic", "epica", "epico", "sr", "super rare"] or st == "stage 2":
		# Epic / Stage 2: 8-12 G, high chance (~75%) for 2-4 Diamonds
		gold = randi_range(8, 12)
		if randf() < 0.75:
			diamonds = randi_range(2, 4)
	elif r in ["rare", "rara", "raro", "r"] or st == "stage 1":
		# Rare / Stage 1: 4-7 G, moderate-high chance (~45%) for 1-3 Diamonds
		gold = randi_range(4, 7)
		if randf() < 0.45:
			diamonds = randi_range(1, 3)
	elif r in ["uncommon", "poco común", "poco comun"]:
		# Uncommon: 2-5 G, moderate chance (~25%) for 1-2 Diamonds
		gold = randi_range(2, 5)
		if randf() < 0.25:
			diamonds = randi_range(1, 2)
	elif r in ["legendary", "legendaria", "legendario", "ur", "ultra rare"]:
		# Legendary: 15-25 G, 100% chance for 3-5 Diamonds
		gold = randi_range(15, 25)
		diamonds = randi_range(3, 5)
	else:
		# Common (default): 1-3 G, low chance (~15%) for 1 Diamond
		gold = randi_range(1, 3)
		if randf() < 0.15:
			diamonds = 1
			
	return {
		"gold": gold,
		"diamonds": diamonds
	}

# --- SISTEMA DE RAREZA Y SOBRES (BOOSTER PACKS) ---
signal diamonds_changed(new_diamonds: int)
signal rare_candies_changed(new_candies: int)
signal card_stocks_changed()

var player_diamonds: int = 0:
	set(val):
		player_diamonds = val
		diamonds_changed.emit(player_diamonds)

var player_rare_candies: int = 0:
	set(val):
		player_rare_candies = max(0, val)
		rare_candies_changed.emit(player_rare_candies)

var player_card_stocks: Dictionary = {} # int pkmn_id -> int stock_count

func get_card_stock(pkmn_id: int) -> int:
	if player_card_stocks.has(pkmn_id):
		return int(player_card_stocks[pkmn_id])
	if pkmn_id in player_unlocked_ids:
		return 1
	return 0

func add_card_copy(pkmn_id: int) -> int:
	var current = get_card_stock(pkmn_id)
	var new_count = current + 1
	player_card_stocks[pkmn_id] = new_count
	if not (pkmn_id in player_unlocked_ids):
		unlock_pokemon(pkmn_id)
	card_stocks_changed.emit()
	return new_count

func get_recycle_candy_value(rarity_str: String) -> int:
	var r = rarity_str.strip_edges().to_lower()
	if r in ["legendary", "legendaria", "legendario", "ur", "ultra rare"]:
		return 40
	elif r in ["epic", "epica", "epico", "sr", "super rare"]:
		return 15
	elif r in ["rare", "rara", "raro", "r"]:
		return 5
	elif r in ["uncommon", "poco común", "poco comun"]:
		return 2
	else: # Common / Starter
		return 1

func get_hidden_shop_candy_cost(rarity_str: String) -> int:
	return get_recycle_candy_value(rarity_str) * 10

func get_duplicate_cards() -> Array[Dictionary]:
	var dupes: Array[Dictionary] = []
	for id in player_unlocked_ids:
		var count = get_card_stock(id)
		if count > 1:
			var card_info = pokemon_catalog.get(id, {}).duplicate()
			card_info["stock"] = count
			card_info["dupes_count"] = count - 1
			card_info["candy_value"] = get_recycle_candy_value(str(card_info.get("rarity", "Common")))
			dupes.append(card_info)
	return dupes

func recycle_card_copy(pkmn_id: int) -> int:
	var current = get_card_stock(pkmn_id)
	if current <= 1:
		return 0
	player_card_stocks[pkmn_id] = current - 1
	var cat = pokemon_catalog.get(pkmn_id, {})
	var candies = get_recycle_candy_value(str(cat.get("rarity", "Common")))
	player_rare_candies += candies
	card_stocks_changed.emit()
	add_daily_mission_progress("recycle_cards", 1)
	save_profile()
	return candies

func recycle_all_duplicates() -> Dictionary:
	var total_recycled = 0
	var total_candies = 0
	for id in player_unlocked_ids:
		var count = get_card_stock(id)
		if count > 1:
			var excess = count - 1
			var cat = pokemon_catalog.get(id, {})
			var val = get_recycle_candy_value(str(cat.get("rarity", "Common")))
			total_recycled += excess
			total_candies += excess * val
			player_card_stocks[id] = 1
	if total_candies > 0:
		player_rare_candies += total_candies
		card_stocks_changed.emit()
		add_daily_mission_progress("recycle_cards", total_recycled)
		save_profile()
	return {
		"recycled_count": total_recycled,
		"candies_earned": total_candies
	}

func buy_card_from_hidden_shop(pkmn_id: int) -> Dictionary:
	if not pokemon_catalog.has(pkmn_id):
		return { "success": false, "message": "Card not found in catalog." }
	var cat = pokemon_catalog[pkmn_id]
	var cost = get_hidden_shop_candy_cost(str(cat.get("rarity", "Common")))
	if player_rare_candies < cost:
		return { "success": false, "message": "Not enough Rare Candies! Requires 🍬 %d Candies." % cost }
	player_rare_candies -= cost
	var new_stock = add_card_copy(pkmn_id)
	save_profile()
	return { "success": true, "message": "Purchased successfully!", "card": cat, "cost": cost, "stock": new_stock }

func get_card_rarity_weight(rarity_str: String) -> int:
	var r = rarity_str.strip_edges().to_lower()
	if r in ["legendary", "legendaria", "legendario", "ur", "ultra rare"]:
		return 3
	elif r in ["epic", "epica", "epico", "sr", "super rare"]:
		return 8
	elif r in ["rare", "rara", "raro", "r"]:
		return 18
	elif r in ["uncommon", "poco común", "poco comun"]:
		return 35
	else: # Common / Starter
		return 65

func get_rarity_display_info(rarity_str: String) -> Dictionary:
	var r = rarity_str.strip_edges().to_lower()
	if r in ["legendary", "legendaria", "legendario", "ur", "ultra rare"]:
		return { "name": "Legendary", "stars": "⭐⭐⭐⭐", "color": Color("#FFD700"), "border": Color("#FFE066") }
	elif r in ["epic", "epica", "epico", "sr", "super rare"]:
		return { "name": "Epic", "stars": "⭐⭐⭐", "color": Color("#BA68C8"), "border": Color("#CE93D8") }
	elif r in ["rare", "rara", "raro", "r"]:
		return { "name": "Rare", "stars": "⭐⭐", "color": Color("#29B6F6"), "border": Color("#81D4FA") }
	elif r in ["uncommon", "poco común", "poco comun"]:
		return { "name": "Uncommon", "stars": "✦✦", "color": Color("#66BB6A"), "border": Color("#81C784") }
	elif r in ["initial", "inicial", "starter"]:
		return { "name": "Starter", "stars": "⭐", "color": Color("#4DD0E1"), "border": Color("#80DEEA") }
	else:
		return { "name": "Common", "stars": "⚪", "color": Color("#B0BEC5"), "border": Color("#90A4AE") }

func get_rarity_sort_rank(rarity_str: String) -> int:
	var r = rarity_str.strip_edges().to_lower()
	if r in ["legendary", "legendaria", "legendario", "ur", "ultra rare"]:
		return 1
	elif r in ["epic", "epica", "epico", "sr", "super rare"]:
		return 2
	elif r in ["rare", "rara", "raro", "r"]:
		return 3
	elif r in ["uncommon", "poco común", "poco comun"]:
		return 4
	elif r in ["initial", "inicial", "starter"]:
		return 5
	else:
		return 6

func get_tier_color(tier_str: String) -> Color:
	match tier_str.strip_edges().to_upper():
		"S+":
			return Color("#E040FB") # Vivid Magenta / God Tier
		"S":
			return Color("#FFD700") # Pure Gold / Elite
		"A":
			return Color("#00E676") # Emerald Green / Competitive
		"B":
			return Color("#00B0FF") # Electric Blue / Solid
		"C":
			return Color("#FF9100") # Amber / Mid
		"D":
			return Color("#90A4AE") # Cool Slate / Early
		_:
			return Color("#CBD5E1")

func get_tier_display_text(tier_str: String) -> String:
	var t = tier_str.strip_edges().to_upper()
	if t == "":
		return "Tier C"
	return "Tier " + t

# --- SISTEMA DE RECOMPENSAS Y MISIONES DIARIAS ---
signal daily_rewards_changed()

var daily_login_last_date: String = "" # "YYYY-MM-DD"
var daily_login_streak: int = 1 # 1 a 7
var daily_login_claimed_today: bool = false

var daily_missions_date: String = "" # "YYYY-MM-DD"
var daily_missions: Array[Dictionary] = []
var daily_bonus_chest_claimed: bool = false

const DAILY_LOGIN_CALENDAR: Array[Dictionary] = [
	{ "day": 1, "diamonds": 5,  "candies": 0,  "label": "5 💎" },
	{ "day": 2, "diamonds": 0,  "candies": 15, "label": "15 🍬" },
	{ "day": 3, "diamonds": 10, "candies": 0,  "label": "10 💎" },
	{ "day": 4, "diamonds": 0,  "candies": 25, "label": "25 🍬" },
	{ "day": 5, "diamonds": 15, "candies": 0,  "label": "15 💎" },
	{ "day": 6, "diamonds": 0,  "candies": 40, "label": "40 🍬" },
	{ "day": 7, "diamonds": 25, "candies": 50, "label": "25 💎 + 50 🍬" }
]

const DAILY_MISSION_POOL: Array[Dictionary] = [
	{
		"id": "win_battles",
		"icon": "⚔️",
		"title": "Frontier Champion",
		"desc": "Win 3 Battles (Campaign or Quick Battle)",
		"type": "win_battles",
		"target": 3,
		"reward_diamonds": 6
	},
	{
		"id": "super_effective",
		"icon": "💥",
		"title": "Type Mastery",
		"desc": "Land 5 Super Effective attacks in Battle",
		"type": "super_effective",
		"target": 5,
		"reward_diamonds": 6
	},
	{
		"id": "switch_pkmn",
		"icon": "🔄",
		"title": "Tactical Rotation",
		"desc": "Switch Pokémon from Bench 3 times",
		"type": "switch_pkmn",
		"target": 3,
		"reward_diamonds": 5
	},
	{
		"id": "open_packs",
		"icon": "🛍️",
		"title": "Pack Collector",
		"desc": "Open 2 Booster Packs in the Shop",
		"type": "open_packs",
		"target": 2,
		"reward_diamonds": 5
	},
	{
		"id": "recycle_cards",
		"icon": "♻️",
		"title": "Candy Alchemy",
		"desc": "Recycle 3 Duplicate Cards for Candies",
		"type": "recycle_cards",
		"target": 3,
		"reward_diamonds": 5
	},
	{
		"id": "defeat_gym",
		"icon": "🏆",
		"title": "Tournament Glory",
		"desc": "Defeat 3 Trainers in Campaign Tournament",
		"type": "defeat_gym",
		"target": 3,
		"reward_diamonds": 8
	},
	{
		"id": "recharge_energy",
		"icon": "⚡",
		"title": "Power Surge",
		"desc": "Recharge Energy 4 times during Battles",
		"type": "recharge_energy",
		"target": 4,
		"reward_diamonds": 5
	},
	{
		"id": "heal_hp",
		"icon": "🩹",
		"title": "Field Medic",
		"desc": "Recover HP 3 times (Moves or Potions)",
		"type": "heal_hp",
		"target": 3,
		"reward_diamonds": 6
	},
	{
		"id": "play_moves",
		"icon": "🎯",
		"title": "Move Mastery",
		"desc": "Execute 8 Moves in Battle",
		"type": "play_moves",
		"target": 8,
		"reward_diamonds": 5
	}
]

func check_and_update_daily_system() -> void:
	var today = Time.get_date_string_from_system()
	var dirty = false
	
	# 1. Calendario de Login Diario
	if daily_login_last_date != today:
		if daily_login_last_date == "":
			daily_login_streak = 1
			daily_login_claimed_today = false
		else:
			if daily_login_claimed_today:
				daily_login_streak = (daily_login_streak % 7) + 1
			daily_login_claimed_today = false
		daily_login_last_date = today
		dirty = true
		
	# 2. Misiones Diarias
	if daily_missions_date != today or daily_missions.is_empty():
		_generate_daily_missions()
		daily_bonus_chest_claimed = false
		daily_missions_date = today
		dirty = true
		
	if dirty:
		save_profile()
		daily_rewards_changed.emit()

func _generate_daily_missions() -> void:
	var available = DAILY_MISSION_POOL.duplicate()
	available.shuffle()
	daily_missions.clear()
	for i in range(min(3, available.size())):
		var t = available[i]
		daily_missions.append({
			"id": t["id"],
			"icon": t["icon"],
			"title": t["title"],
			"desc": t["desc"],
			"type": t["type"],
			"current": 0,
			"target": t["target"],
			"reward_diamonds": t["reward_diamonds"],
			"claimed": false
		})

func swap_daily_mission(mission_index: int) -> Dictionary:
	if mission_index < 0 or mission_index >= daily_missions.size():
		return { "success": false, "message": "Invalid mission index." }
		
	var m = daily_missions[mission_index]
	if m.get("claimed", false):
		return { "success": false, "message": "Cannot swap an already claimed mission." }
		
	if player_diamonds < 1:
		return { "success": false, "message": "Not enough Diamonds! Requires 💎 1." }
		
	player_diamonds -= 1
	
	var active_ids = []
	for existing in daily_missions:
		active_ids.append(existing.get("id", ""))
		
	var candidates = []
	for c in DAILY_MISSION_POOL:
		if not (c["id"] in active_ids):
			candidates.append(c)
			
	if candidates.is_empty():
		for c in DAILY_MISSION_POOL:
			if c["id"] != m.get("id", ""):
				candidates.append(c)
				
	candidates.shuffle()
	var new_t = candidates[0]
	var new_mission = {
		"id": new_t["id"],
		"icon": new_t["icon"],
		"title": new_t["title"],
		"desc": new_t["desc"],
		"type": new_t["type"],
		"current": 0,
		"target": new_t["target"],
		"reward_diamonds": new_t["reward_diamonds"],
		"claimed": false
	}
	daily_missions[mission_index] = new_mission
	save_profile()
	daily_rewards_changed.emit()
	play_combat_sfx("switch")
	return { "success": true, "message": "Mission swapped!", "new_mission": new_mission }

func claim_daily_login_reward() -> Dictionary:
	check_and_update_daily_system()
	if daily_login_claimed_today:
		return { "success": false, "message": "Today's login reward already claimed!" }
		
	var idx = clampi(daily_login_streak - 1, 0, DAILY_LOGIN_CALENDAR.size() - 1)
	var reward = DAILY_LOGIN_CALENDAR[idx]
	var d_earned = int(reward.get("diamonds", 0))
	var c_earned = int(reward.get("candies", 0))
	
	if d_earned > 0:
		player_diamonds += d_earned
	if c_earned > 0:
		player_rare_candies += c_earned
		
	daily_login_claimed_today = true
	save_profile()
	daily_rewards_changed.emit()
	play_combat_sfx("heal")
	return {
		"success": true,
		"diamonds": d_earned,
		"candies": c_earned,
		"streak": daily_login_streak
	}

func claim_daily_mission_reward(mission_index: int) -> Dictionary:
	if mission_index < 0 or mission_index >= daily_missions.size():
		return { "success": false, "message": "Invalid mission index." }
		
	var m = daily_missions[mission_index]
	if m.get("claimed", false):
		return { "success": false, "message": "Mission already claimed." }
		
	if m.get("current", 0) < m.get("target", 1):
		return { "success": false, "message": "Mission objective not yet reached." }
		
	m["claimed"] = true
	var reward = int(m.get("reward_diamonds", 5))
	player_diamonds += reward
	save_profile()
	daily_rewards_changed.emit()
	play_combat_sfx("hit_super")
	return { "success": true, "reward_diamonds": reward }

func claim_daily_bonus_chest() -> Dictionary:
	if daily_bonus_chest_claimed:
		return { "success": false, "message": "Daily bonus chest already claimed today." }
		
	if not are_all_daily_missions_claimed():
		return { "success": false, "message": "Must claim all 3 daily missions first!" }
		
	daily_bonus_chest_claimed = true
	player_diamonds += 10
	save_profile()
	daily_rewards_changed.emit()
	play_combat_sfx("heal")
	return { "success": true, "reward_diamonds": 10 }

func are_all_daily_missions_claimed() -> bool:
	if daily_missions.size() < 3:
		return false
	for m in daily_missions:
		if not m.get("claimed", false):
			return false
	return true

func has_any_daily_reward_ready() -> bool:
	check_and_update_daily_system()
	if not daily_login_claimed_today:
		return true
	for m in daily_missions:
		if not m.get("claimed", false) and m.get("current", 0) >= m.get("target", 1):
			return true
	if not daily_bonus_chest_claimed and are_all_daily_missions_claimed():
		return true
	return false

func add_daily_mission_progress(mission_type: String, amount: int = 1) -> void:
	check_and_update_daily_system()
	var any_updated = false
	for m in daily_missions:
		if m.get("type", "") == mission_type and not m.get("claimed", false):
			var cur = m.get("current", 0)
			var target = m.get("target", 1)
			if cur < target:
				m["current"] = mini(cur + amount, target)
				any_updated = true
				print("Daily Mission Progress [%s]: %d/%d" % [m.get("title", ""), m["current"], target])
	if any_updated:
		save_profile()
		daily_rewards_changed.emit()

# --- PREFERENCIAS DE COMBATE ---
var battle_speed_index: int = 0 # 0=1x, 1=1.5x, 2=2x, 3=3x

# --- MATERIALES Y EFECTOS FOIL HOLOGRÁFICOS ---
var card_foil_shader: Shader = null

func get_card_foil_shader() -> Shader:
	if not card_foil_shader:
		if ResourceLoader.exists("res://assets/shaders/card_foil.gdshader"):
			card_foil_shader = load("res://assets/shaders/card_foil.gdshader")
	return card_foil_shader

func create_card_foil_material(rarity_str: String) -> ShaderMaterial:
	var r = rarity_str.strip_edges().to_lower()
	var s = get_card_foil_shader()
	if not s:
		return null
		
	if r in ["rare", "rara", "raro", "r"]:
		var mat = ShaderMaterial.new()
		mat.shader = s
		mat.set_shader_parameter("foil_style", 0) # 0 = Rare: Brillo metálico plateado puro, sin estrellas ni arcoíris
		mat.set_shader_parameter("foil_color_1", Color("#E6F2FF", 0.65))
		mat.set_shader_parameter("foil_color_2", Color("#FFFFFF", 0.50))
		mat.set_shader_parameter("sheen_width", 0.16)
		mat.set_shader_parameter("rainbow_mix", 0.0)
		mat.set_shader_parameter("sparkle_strength", 0.0)
		mat.set_shader_parameter("ambient_foil", 0.02)
		mat.set_shader_parameter("intensity", 0.75)
		mat.set_shader_parameter("shimmer_speed", 0.85)
		return mat
	elif r in ["epic", "epica", "epico", "sr", "super rare"]:
		var mat = ShaderMaterial.new()
		mat.shader = s
		mat.set_shader_parameter("foil_style", 1) # 1 = Epic: Barrido cósmico violeta/turquesa con estrellas sutiles
		mat.set_shader_parameter("foil_color_1", Color("#BA68C8", 0.70))
		mat.set_shader_parameter("foil_color_2", Color("#00E5FF", 0.55))
		mat.set_shader_parameter("sheen_width", 0.22)
		mat.set_shader_parameter("rainbow_mix", 0.35)
		mat.set_shader_parameter("sparkle_strength", 0.45)
		mat.set_shader_parameter("sparkle_density", 0.85)
		mat.set_shader_parameter("ambient_foil", 0.10)
		mat.set_shader_parameter("intensity", 0.85)
		mat.set_shader_parameter("shimmer_speed", 1.0)
		return mat
	elif r in ["legendary", "legendaria", "legendario", "ur", "ultra rare"]:
		var mat = ShaderMaterial.new()
		mat.shader = s
		mat.set_shader_parameter("foil_style", 2) # 2 = Legendary: Supernova dorada radiante, prisma arcoíris completo y lluvia de estrellas
		mat.set_shader_parameter("foil_color_1", Color("#FFD700", 0.90))
		mat.set_shader_parameter("foil_color_2", Color("#FF6D00", 0.75))
		mat.set_shader_parameter("sheen_width", 0.30)
		mat.set_shader_parameter("rainbow_mix", 0.75)
		mat.set_shader_parameter("sparkle_strength", 0.95)
		mat.set_shader_parameter("sparkle_density", 0.70)
		mat.set_shader_parameter("ambient_foil", 0.22)
		mat.set_shader_parameter("intensity", 1.20)
		mat.set_shader_parameter("shimmer_speed", 1.25)
		return mat
		
	return null

func apply_foil_overlay(target_node: Control, rarity_str: String) -> ColorRect:
	if not target_node:
		return null
		
	var existing: ColorRect = target_node.get_node_or_null("FoilOverlay") as ColorRect
	var mat = create_card_foil_material(rarity_str)
	
	if not mat:
		if existing:
			existing.visible = false
		return null
		
	var overlay: ColorRect = existing
	if not overlay:
		overlay = ColorRect.new()
		overlay.name = "FoilOverlay"
		overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
		overlay.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		overlay.size_flags_vertical = Control.SIZE_EXPAND_FILL
		overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		target_node.add_child(overlay)
		
	overlay.material = mat
	overlay.visible = true
	return overlay

# --- GESTIÓN DE AUDIO SFX (ORIGINALES GBA EN PKMN/MOVES_SFX) ---
const SFX_FOLDER_PATH: String = "D:/Games/Pokemon Battle Frontier/PKMN/MOVES_SFX/"
var sfx_audio_cache: Dictionary = {} # filename -> AudioStreamMP3
var sfx_player_node: AudioStreamPlayer = null

const SFX_THEMATIC_FALLBACKS: Dictionary = {
	"fury attack": "Fury Attack 2hits.mp3",
	"fury swipes": "Fury Swipes 2hits.mp3",
	"double slap": "Double Slap 2hits.mp3",
	"arm thrust": "Arm Thrust 2hits.mp3",
	"comet punch": "Comet Punch 2hits.mp3",
	"barrage": "Barrage 2hits.mp3",
	"spike cannon": "Spike Cannon 2hits.mp3",
	"pin missile": "Pin Missile 2hits.mp3",
	"bone rush": "Bone Rush 2hits.mp3",
	"bullet seed": "Bullet Seed 2hits.mp3",
	"rock blast": "Rock Blast 2hits.mp3",
	"triple kick": "Triple Kick 2hits.mp3",
	"twineedle": "Twineedle 2hits.mp3",
	"double kick": "Double Kick 2hits.mp3",
	"will-o-wisp": "Will O Wisp.mp3",
	"mud-slap": "Mud Slap.mp3",
	"u-turn": "U turn.mp3",
	"x-scissor": "Cut.mp3",
	"v-create": "V create.mp3",
	"soft-boiled": "Softboiled.mp3",
	"hi jump kick": "Hi Jump Kick.mp3",
	"fire fang": "Fire Spin.mp3",
	"inferno": "Blast Burn.mp3",
	"flash cannon": "Zap Cannon.mp3",
	"bug bite": "Bite.mp3",
	"bug buzz": "Silver Wind.mp3",
	"toxic spikes": "Spikes.mp3",
	"poison jab": "Poison Tail.mp3",
	"venoshock": "Sludge Bomb.mp3",
	"hurricane": "Whirlwind.mp3",
	"air slash": "Air Cutter.mp3",
	"discharge": "Thunderbolt.mp3",
	"bulldoze": "Rock Tomb.mp3",
	"earth power": "Earthquake.mp3",
	"stomping tantrum": "Earthquake.mp3",
	"disarming voice": "Hyper Voice.mp3",
	"moonblast": "Swift.mp3",
	"incinerate": "Flame Wheel.mp3",
	"echoed voice": "Hyper Voice.mp3",
	"play rough": "Dizzy Punch.mp3",
	"aqua jet": "Water Pulse.mp3",
	"aqua ring": "Water Sport.mp3",
	"aqua tail": "Waterfall.mp3",
	"assurance": "Feint Attack.mp3",
	"aura sphere": "Psybeam.mp3",
	"belch": "Sludge.mp3",
	"brine": "Bubble Beam.mp3",
	"bullet punch": "Mach Punch.mp3",
	"burn up": "Overheat.mp3",
	"clear smog": "Smog.mp3",
	"close combat": "Cross Chop.mp3",
	"counter-cut": "Cut.mp3",
	"cross poison": "Poison Tail.mp3",
	"double hit": "Double Slap 2hits.mp3",
	"dragon pulse": "Dragon Claw.mp3",
	"dragon rush": "Dragon Claw.mp3",
	"dragon tail": "Slam.mp3",
	"drain punch": "Mega Punch.mp3",
	"drill run": "Drill Peck.mp3",
	"electro ball": "Zap Cannon.mp3",
	"flame charge": "Flame Wheel.mp3",
	"flare blitz": "Overheat.mp3",
	"giga impact": "Hyper Beam.mp3",
	"grassy terrain": "Ingrain.mp3",
	"gyro ball": "Rollout.mp3",
	"hammer arm": "Mega Punch.mp3",
	"high confusion": "Confusion.mp3",
	"ice shard": "Icy Wind.mp3",
	"iron head": "Headbutt.mp3",
	"kinetic beam": "Psybeam.mp3",
	"last resort": "Facade.mp3",
	"lava plume": "Eruption.mp3",
	"leaf tornado": "Twister.mp3",
	"liquidation": "Hydro Pump.mp3",
	"low sweep": "Low Kick.mp3",
	"might sphere": "Psybeam.mp3",
	"mind bending": "Confusion.mp3",
	"payback": "Revenge.mp3",
	"pluck": "Peck.mp3",
	"poison claw": "Crush Claw.mp3",
	"power whip": "Vine Whip.mp3",
	"primal coat": "Ancient Power.mp3",
	"psycho cut": "Slash.mp3",
	"razor shell": "Crabhammer.mp3",
	"rock polish": "Harden.mp3",
	"rock wrecker": "Rock Slide.mp3",
	"seed bomb": "Bullet Seed 2hits.mp3",
	"shell smash": "Withdraw.mp3",
	"smack down": "Rock Throw.mp3",
	"special punch": "Mega Punch.mp3",
	"stone edge": "Rock Slide.mp3",
	"struggle bug": "Leech Life.mp3",
	"tailwind": "Whirlwind.mp3",
	"thunder fang": "Spark.mp3",
	"venom drench": "Toxic.mp3",
	"zen headbutt": "Headbutt.mp3"
}

func get_audio_stream_from_file(filename: String) -> AudioStream:
	if filename == "":
		return null
	var clean_fn = filename.strip_edges()
	if not clean_fn.ends_with(".mp3") and not clean_fn.ends_with(".wav") and not clean_fn.ends_with(".ogg"):
		clean_fn += ".mp3"
		
	if sfx_audio_cache.has(clean_fn):
		return sfx_audio_cache[clean_fn]
		
	var paths = [
		"res://assets/sfx/" + clean_fn,
		"res://assets/sfx/moves/" + clean_fn,
		SFX_FOLDER_PATH + clean_fn,
		"D:/Games/Pokemon Battle Frontier/SFX/" + clean_fn
	]
	
	for p in paths:
		if p.begins_with("res://") and ResourceLoader.exists(p):
			var res_stream = load(p) as AudioStream
			if res_stream:
				sfx_audio_cache[clean_fn] = res_stream
				return res_stream
		elif FileAccess.file_exists(p):
			if clean_fn.ends_with(".mp3"):
				var f = FileAccess.open(p, FileAccess.READ)
				if f:
					var buf = f.get_buffer(f.get_length())
					f.close()
					var stream = AudioStreamMP3.new()
					stream.data = buf
					sfx_audio_cache[clean_fn] = stream
					return stream
			elif clean_fn.ends_with(".ogg"):
				var stream = AudioStreamOggVorbis.load_from_file(p)
				if stream:
					sfx_audio_cache[clean_fn] = stream
					return stream
				
	return null

func get_move_sfx_stream(move_name_or_id: String) -> AudioStream:
	var m_data = get_move_data(move_name_or_id)
	var sfx_name = m_data.get("sfx", "")
	var m_name = m_data.get("name", move_name_or_id)
	var clean_lower = m_name.strip_edges().to_lower()
	
	# 1. Archivo configurado explícitamente en la columna 'sfx'
	if sfx_name != "":
		var s = get_audio_stream_from_file(sfx_name)
		if s: return s
		
	# 2. Nombre del movimiento directo .mp3
	var direct_s = get_audio_stream_from_file(m_name + ".mp3")
	if direct_s: return direct_s
	
	# 3. Mapeo temático o variantes multi-hit (ej: "Fury Attack 2hits.mp3")
	if SFX_THEMATIC_FALLBACKS.has(clean_lower):
		var fallback_fn = SFX_THEMATIC_FALLBACKS[clean_lower]
		var s = get_audio_stream_from_file(fallback_fn)
		if s: return s
		
	# 4. Probar sin guiones
	var no_dash = clean_lower.replace("-", " ")
	if no_dash != clean_lower:
		var s = get_audio_stream_from_file(no_dash.capitalize() + ".mp3")
		if s: return s
		
	return null

func play_move_sfx(move_name_or_id: String) -> void:
	var stream = get_move_sfx_stream(move_name_or_id)
	play_custom_sfx(stream)

func play_combat_sfx(sfx_type: String) -> void:
	var filename = ""
	match sfx_type:
		"hit_normal": filename = "Hit Normal Damage.mp3"
		"hit_super": filename = "Hit Super Effective.mp3"
		"hit_weak": filename = "Hit Weak Not Very Effective.mp3"
		"heal": filename = "In-Battle Heal HP Restore.mp3"
		"faint": filename = "In-Battle Faint No Health.mp3"
		"switch": filename = "In-Battle Recall Switch Pokeball.mp3"
		"purchase": filename = "purchase.wav"
		"use": filename = "use.wav"
		_: filename = sfx_type
		
	var stream = get_audio_stream_from_file(filename)
	play_custom_sfx(stream)

func play_custom_sfx(stream: AudioStream) -> void:
	if not stream:
		return
	if settings_sfx_muted or settings_sfx_volume <= 0.01:
		return
	if not sfx_player_node or not is_instance_valid(sfx_player_node):
		sfx_player_node = AudioStreamPlayer.new()
		sfx_player_node.name = "GlobalSFXPlayer"
		add_child(sfx_player_node)
		
	sfx_player_node.stream = stream
	sfx_player_node.volume_db = get_sfx_db()
	sfx_player_node.play()

func open_booster_pack(pack_type: String = "test", cost_diamonds: int = 0) -> Array[Dictionary]:
	if player_diamonds < cost_diamonds:
		return []
		
	player_diamonds -= cost_diamonds
	var result: Array[Dictionary] = []
	if all_pokemon_ids.is_empty():
		return result
		
	var candidate_ids = all_pokemon_ids.duplicate()
	candidate_ids.shuffle()
	
	var picked_ids: Array[int] = []
	for step in range(min(3, candidate_ids.size())):
		var total_weight = 0
		var weights: Array[int] = []
		for id in candidate_ids:
			var d = pokemon_catalog.get(id, {})
			var r = str(d.get("rarity", "Common"))
			var w = get_card_rarity_weight(r)
			total_weight += w
			weights.append(total_weight)
			
		var roll = randi_range(1, max(1, total_weight))
		var chosen_idx = 0
		for i in range(weights.size()):
			if roll <= weights[i]:
				chosen_idx = i
				break
				
		var chosen_id = candidate_ids[chosen_idx]
		picked_ids.append(chosen_id)
		candidate_ids.remove_at(chosen_idx)
		
	for id in picked_ids:
		var d = pokemon_catalog.get(id, {}).duplicate()
		var was_new = not is_pokemon_unlocked(id)
		var new_stock = add_card_copy(id)
		d["is_new"] = was_new
		d["stock"] = new_stock
		result.append(d)
		
	stats_packs_opened += 1
	add_daily_mission_progress("open_packs", 1)
	save_profile()
	return result

# Genera una instancia viva para combate
func create_pokemon_instance(pkmn_id: int) -> PokemonData:
	if not pokemon_catalog.has(pkmn_id):
		if pokemon_catalog.size() > 0:
			pkmn_id = all_pokemon_ids[0]
		else:
			return null
			
	var d = pokemon_catalog[pkmn_id]
	var p = PokemonData.new()
	p.id = d["id"]
	p.pokedex_num = d["pokedex_num"]
	p.stage = d.get("stage", "Basic")
	p.rarity = d.get("rarity", "Common")
	p.tier = d.get("tier", "C")
	p.evolves_to = d.get("evolves_to", "")
	p.current_exp = 0
	p.max_exp = p.get_required_exp()
	p.name = d["name"]
	p.max_hp = d["hp"]
	p.current_hp = d["hp"]
	p.max_energy = d["energy"]
	p.current_energy = d["energy"]
	p.speed = d["speed"]
	p.recover_amount = d["recover"]
	p.type = d["type"]
	p.weakness = d["weakness"]
	p.resistant = d["resistant"]
	p.texture_path = d["texture_path"]
	p.burn_turns = 0
	p.temp_speed_mod = 0
	p.is_poisoned = false
	p.toxic_envenomed = false
	p.is_flinched = false
	p.was_flinched_last_round = false
	p.flinched_this_round = false
	p.took_damage_last_turn = false
	p.burn_dmg = 1
	p.shield_breaker_bonus = 0
	p.is_paralyzed = false
	p.is_asleep_turns = 0
	p.is_frozen = false
	p.is_confused = false
	p.is_seeded_turns = 0
	p.is_constricted_dmg = 0
	p.shield_reduction = 0
	p.shield_turns = 0
	p.wall_hp = 0
	p.is_evasive = false
	p.evasive_reflects_dmg = 0
	p.is_digging = false
	p.rest_next_turn = false
	p.charging_move = ""
	p.last_move_used = ""
	p.consecutive_move_count = 0
	p.damage_buff = 0
	p.damage_buff_turns = 0
	p.foe_damage_debuff = 0
	p.foe_damage_debuff_turns = 0
	p.lock_foe_move = ""
	p.amnesia_active = false
	p.payday_used = false
	p.ground_boost_turns = 0
	
	# Habilidad Pasiva
	p.passive_name = d["passive_name"]
	p.passive_desc = d["passive_desc"]
	p.has_passive = (p.passive_name.strip_edges() != "")
	if p.has_passive and p.passive_name.strip_edges().to_lower() == "agility":
		p.speed += 1
	
	# Movimiento Activo 1
	var m1 = MoveData.new(
		d["m1_name"], d["m1_type"], d["m1_dmg"], d["m1_cost"], d["m1_req"],
		d["m1_boost_cost"] > 0, d["m1_boost_cost"], d["m1_boost_dmg"],
		d["m1_effect_type"] == "BURN", d["m1_effect"]
	)
	m1.effect_type = d["m1_effect_type"]
	m1.reduces_foe_speed = (m1.effect_type == "SLOW_FOE")
	m1.is_pichu_shock = (m1.effect_type == "PICHU_SHOCK")
	m1.causes_poison = (m1.effect_type == "POISON_IF_FASTER" or m1.effect_type == "POISON")
		
	# Movimiento Activo 2
	var m2 = MoveData.new(
		d["m2_name"], d["m2_type"], d["m2_dmg"], d["m2_cost"], d["m2_req"],
		d["m2_boost_cost"] > 0, d["m2_boost_cost"], d["m2_boost_dmg"],
		d["m2_effect_type"] == "BURN", d["m2_effect"]
	)
	m2.effect_type = d["m2_effect_type"]
	m2.reduces_foe_speed = (m2.effect_type == "SLOW_FOE")
	m2.is_pichu_shock = (m2.effect_type == "PICHU_SHOCK")
	m2.causes_poison = (m2.effect_type == "POISON_IF_FASTER" or m2.effect_type == "POISON")
	
	p.moves = [m1, m2]
	return p

# --- MÉTODOS DE CAMPAÑA (TORNEO Y AVENTURA) ---
# Billetera Global de Campaña: campaign_gold es compartido permanentemente entre Torneo y Aventura
func get_active_campaign_gold() -> int:
	return campaign_gold

func set_active_campaign_gold(val: int) -> void:
	campaign_gold = max(0, val)
	adventure_gold = campaign_gold

func add_active_campaign_gold(val: int) -> void:
	campaign_gold = max(0, campaign_gold + val)
	adventure_gold = campaign_gold

func get_active_campaign_inventory() -> Dictionary:
	if campaign_submode == "ADVENTURE":
		return adventure_inventory
	return campaign_inventory

func get_active_campaign_team_state() -> Array:
	if campaign_submode == "ADVENTURE":
		return adventure_player_team_state
	return campaign_player_team_state

func swap_campaign_team_members(idx_a: int, idx_b: int) -> bool:
	var team = get_active_campaign_team_state()
	if idx_a < 0 or idx_a >= team.size() or idx_b < 0 or idx_b >= team.size():
		return false
	if idx_a == idx_b:
		return false
	var tmp = team[idx_a]
	team[idx_a] = team[idx_b]
	team[idx_b] = tmp
	save_profile()
	return true

func set_campaign_team_leader(index: int) -> bool:
	var team = get_active_campaign_team_state()
	if index <= 0 or index >= team.size():
		return false
	var leader = team.pop_at(index)
	team.insert(0, leader)
	save_profile()
	return true

func reset_campaign() -> void:
	is_campaign_mode = false
	campaign_match_number = 1
	# Nota: campaign_gold y player_diamonds se conservan permanentemente
	campaign_inventory = {"potion": 0, "revive": 0, "remedy": 0, "ether": 0}
	campaign_player_team_state.clear()
	current_tournament_rival_team.clear()
	current_tournament_rival_match = -1

func init_campaign_team(chosen_ids: Array) -> void:
	campaign_player_team_state.clear()
	for cid in chosen_ids:
		var d = pokemon_catalog.get(cid, {})
		var r = str(d.get("rarity", "Common")).strip_edges().to_lower()
		var st = str(d.get("stage", "Basic")).strip_edges().to_lower()
		var is_legendary = (r in ["legendary", "legendaria", "legendario", "ur", "ultra rare"]) or (st == "legendary")
		if st == "basic" and not is_legendary:
			var inst = create_pokemon_instance(cid)
			if inst:
				campaign_player_team_state.append({
					"id": cid,
					"name": inst.name,
					"stage": inst.stage,
					"type": inst.type,
					"current_hp": inst.max_hp,
					"max_hp": inst.max_hp,
					"speed": inst.speed,
					"texture_path": inst.texture_path,
					"current_exp": 0,
					"max_exp": 10,
					"burn_turns": 0,
					"is_poisoned": false,
					"is_flinched": false
				})
	campaign_match_number = 1
	campaign_inventory = {"potion": 0, "revive": 0, "remedy": 0, "ether": 0}
	current_tournament_rival_team.clear()
	current_tournament_rival_match = -1

func change_campaign_team(chosen_ids: Array) -> void:
	var old_hp = {}
	var old_exp = {}
	var old_burn = {}
	var old_poison = {}
	var old_flinch = {}
	for p in campaign_player_team_state:
		old_hp[p["id"]] = p["current_hp"]
		old_exp[p["id"]] = p.get("current_exp", 0)
		old_burn[p["id"]] = p.get("burn_turns", 0)
		old_poison[p["id"]] = p.get("is_poisoned", false)
		old_flinch[p["id"]] = p.get("is_flinched", false)
	campaign_player_team_state.clear()
	for cid in chosen_ids:
		var d = pokemon_catalog.get(cid, {})
		var r = str(d.get("rarity", "Common")).strip_edges().to_lower()
		var st = str(d.get("stage", "Basic")).strip_edges().to_lower()
		var is_legendary = (r in ["legendary", "legendaria", "legendario", "ur", "ultra rare"]) or (st == "legendary")
		if st == "basic" and not is_legendary:
			var inst = create_pokemon_instance(cid)
			if inst:
				var hp = old_hp.get(cid, inst.max_hp)
				var exp_val = old_exp.get(cid, 0)
				var burn_val = old_burn.get(cid, 0)
				var poison_val = old_poison.get(cid, false)
				var flinch_val = old_flinch.get(cid, false)
				campaign_player_team_state.append({
					"id": cid,
					"name": inst.name,
					"stage": inst.stage,
					"type": inst.type,
					"current_hp": hp,
					"max_hp": inst.max_hp,
					"speed": inst.speed,
					"texture_path": inst.texture_path,
					"current_exp": exp_val,
					"max_exp": 10,
					"burn_turns": burn_val,
					"is_poisoned": poison_val,
					"is_flinched": flinch_val
				})
	current_tournament_rival_team.clear()
	current_tournament_rival_match = -1

# --- MÉTODOS DE MODO AVENTURA ---
func reset_adventure_episode(episode_id: int) -> void:
	adventure_current_episode = episode_id
	adventure_current_stage = 1
	# Nota: campaign_gold y player_diamonds se conservan permanentemente
	adventure_inventory = {"potion": 0, "revive": 0, "remedy": 0, "ether": 0}
	adventure_player_team_state.clear()

func init_adventure_team(episode_id: int, chosen_ids: Array) -> void:
	adventure_current_episode = episode_id
	adventure_current_stage = 1
	adventure_inventory = {"potion": 0, "revive": 0, "remedy": 0, "ether": 0}
	adventure_player_team_state.clear()
	for cid in chosen_ids:
		var d = pokemon_catalog.get(cid, {})
		var r = str(d.get("rarity", "Common")).strip_edges().to_lower()
		var st = str(d.get("stage", "Basic")).strip_edges().to_lower()
		var is_legendary = (r in ["legendary", "legendaria", "legendario", "ur", "ultra rare"]) or (st == "legendary")
		if st == "basic" and not is_legendary:
			var inst = create_pokemon_instance(cid)
			if inst:
				adventure_player_team_state.append({
					"id": cid,
					"name": inst.name,
					"stage": inst.stage,
					"type": inst.type,
					"current_hp": inst.max_hp,
					"max_hp": inst.max_hp,
					"speed": inst.speed,
					"texture_path": inst.texture_path,
					"current_exp": 0,
					"max_exp": 10,
					"burn_turns": 0,
					"is_poisoned": false,
					"is_flinched": false
				})

func change_adventure_team(chosen_ids: Array) -> void:
	var old_hp = {}
	var old_exp = {}
	var old_burn = {}
	var old_poison = {}
	var old_flinch = {}
	for p in adventure_player_team_state:
		old_hp[p["id"]] = p["current_hp"]
		old_exp[p["id"]] = p.get("current_exp", 0)
		old_burn[p["id"]] = p.get("burn_turns", 0)
		old_poison[p["id"]] = p.get("is_poisoned", false)
		old_flinch[p["id"]] = p.get("is_flinched", false)
	adventure_player_team_state.clear()
	for cid in chosen_ids:
		var d = pokemon_catalog.get(cid, {})
		var r = str(d.get("rarity", "Common")).strip_edges().to_lower()
		var st = str(d.get("stage", "Basic")).strip_edges().to_lower()
		var is_legendary = (r in ["legendary", "legendaria", "legendario", "ur", "ultra rare"]) or (st == "legendary")
		if st == "basic" and not is_legendary:
			var inst = create_pokemon_instance(cid)
			if inst:
				var hp = old_hp.get(cid, inst.max_hp)
				var exp_val = old_exp.get(cid, 0)
				var burn_val = old_burn.get(cid, 0)
				var poison_val = old_poison.get(cid, false)
				var flinch_val = old_flinch.get(cid, false)
				adventure_player_team_state.append({
					"id": cid,
					"name": inst.name,
					"stage": inst.stage,
					"type": inst.type,
					"current_hp": hp,
					"max_hp": inst.max_hp,
					"speed": inst.speed,
					"texture_path": inst.texture_path,
					"current_exp": exp_val,
					"max_exp": 10,
					"burn_turns": burn_val,
					"is_poisoned": poison_val,
					"is_flinched": flinch_val
				})

func get_adventure_episode_info(episode_id: int) -> Dictionary:
	return ADVENTURE_EPISODES.get(episode_id, {})

func get_adventure_total_stages(episode_id: int) -> int:
	var ep = ADVENTURE_EPISODES.get(episode_id, {})
	var stages = ep.get("stages", [])
	return stages.size()

func get_adventure_stage_info(episode_id: int, stage_num: int) -> Dictionary:
	var ep = ADVENTURE_EPISODES.get(episode_id, {})
	var stages = ep.get("stages", [])
	for s in stages:
		if int(s.get("stage_num", 0)) == stage_num:
			return s
	return {}

func get_adventure_rival_team(episode_id: int, stage_num: int) -> Array[int]:
	var stage = get_adventure_stage_info(episode_id, stage_num)
	var names = stage.get("team_pokemon_names", [])
	var team: Array[int] = []
	for n in names:
		var pid = get_pokemon_id_by_name(n)
		if pid != -1:
			team.append(pid)
	return team

func is_adventure_episode_unlocked(episode_id: int) -> bool:
	return episode_id in adventure_unlocked_episodes

func is_adventure_episode_completed(episode_id: int) -> bool:
	return episode_id in adventure_completed_episodes

func complete_adventure_episode(episode_id: int) -> int:
	# Returns diamonds awarded (20 if first clear, 0 if already completed)
	var bonus = 0
	if not (episode_id in adventure_completed_episodes):
		adventure_completed_episodes.append(episode_id)
		var ep_info = ADVENTURE_EPISODES.get(episode_id, {})
		bonus = int(ep_info.get("reward_diamonds_first_clear", 20))
		player_diamonds += bonus
		# Unlock next episode
		var next_ep = episode_id + 1
		if not (next_ep in adventure_unlocked_episodes):
			adventure_unlocked_episodes.append(next_ep)
	save_profile()
	return bonus

func check_and_apply_campaign_evolutions() -> Array[Dictionary]:
	var evolutions_occurred: Array[Dictionary] = []
	var team_state = get_active_campaign_team_state()
	for i in range(team_state.size()):
		var p = team_state[i]
		var current_id = int(p["id"])
		var st = str(p.get("stage", "Basic")).strip_edges().to_lower()
		var req_exp = 10 if st == "basic" else (25 if st == "stage 1" else 0)
		var cur_exp = int(p.get("current_exp", 0))
		
		if req_exp > 0 and cur_exp >= req_exp:
			var target_id = get_evolution_target_id(current_id)
			if target_id != -1 and is_pokemon_unlocked(target_id):
				var target_inst = create_pokemon_instance(target_id)
				if target_inst:
					var from_name = p["name"]
					var to_name = target_inst.name
					var old_max = int(p["max_hp"])
					var new_max = target_inst.max_hp
					var hp_gain = new_max - old_max
					
					p["id"] = target_id
					p["name"] = target_inst.name
					p["stage"] = target_inst.stage
					p["type"] = target_inst.type
					p["speed"] = target_inst.speed
					p["texture_path"] = target_inst.texture_path
					p["max_hp"] = new_max
					p["current_hp"] = min(new_max, int(p["current_hp"]) + max(0, hp_gain))
					p["current_exp"] = 0 # El siguiente stage llega con 0 EXP
					p["max_exp"] = target_inst.get_required_exp()
					
					evolutions_occurred.append({
						"from_name": from_name,
						"to_name": to_name,
						"from_id": current_id,
						"to_id": target_id,
						"new_stage": target_inst.stage
					})
			else:
				# No evoluciona porque falta tener la carta conseguida
				p["current_exp"] = min(cur_exp, req_exp)
	return evolutions_occurred

func use_potion_on_campaign_pkmn(index: int) -> bool:
	var inv = get_active_campaign_inventory()
	var team_state = get_active_campaign_team_state()
	if inv.get("potion", 0) <= 0:
		return false
	if index < 0 or index >= team_state.size():
		return false
	var p_data = team_state[index]
	if p_data["current_hp"] <= 0:
		return false # No cura si está KO, requiere Revive
	if p_data["current_hp"] >= p_data["max_hp"]:
		return false # Ya está al máximo
		
	p_data["current_hp"] = min(p_data["max_hp"], p_data["current_hp"] + 10)
	inv["potion"] -= 1
	return true

func use_revive_on_campaign_pkmn(index: int) -> bool:
	var inv = get_active_campaign_inventory()
	var team_state = get_active_campaign_team_state()
	if inv.get("revive", 0) <= 0:
		return false
	if index < 0 or index >= team_state.size():
		return false
	var p_data = team_state[index]
	if p_data["current_hp"] > 0:
		return false # Solo se puede usar en un Pokémon en estado KO (<= 0 HP)
		
	# Revive con el 50% de sus HP máximos (mínimo 1 HP)
	p_data["current_hp"] = max(1, int(p_data["max_hp"] / 2.0))
	inv["revive"] -= 1
	return true

func buy_campaign_potion() -> bool:
	var cur_gold = get_active_campaign_gold()
	var inv = get_active_campaign_inventory()
	if cur_gold >= 3:
		set_active_campaign_gold(cur_gold - 3)
		inv["potion"] = inv.get("potion", 0) + 1
		return true
	return false

func buy_campaign_revive() -> bool:
	var cur_gold = get_active_campaign_gold()
	var inv = get_active_campaign_inventory()
	if cur_gold >= 6:
		set_active_campaign_gold(cur_gold - 6)
		inv["revive"] = inv.get("revive", 0) + 1
		return true
	return false

func use_remedy_on_campaign_pkmn(index: int) -> bool:
	var inv = get_active_campaign_inventory()
	var team_state = get_active_campaign_team_state()
	if inv.get("remedy", 0) <= 0:
		return false
	if index < 0 or index >= team_state.size():
		return false
	var p_data = team_state[index]
	var has_status = (int(p_data.get("burn_turns", 0)) > 0) or bool(p_data.get("is_poisoned", false)) or bool(p_data.get("is_flinched", false)) or bool(p_data.get("is_paralyzed", false)) or (int(p_data.get("paralyze_turns", 0)) > 0) or (int(p_data.get("is_asleep_turns", 0)) > 0) or bool(p_data.get("is_frozen", false)) or bool(p_data.get("is_confused", false)) or (int(p_data.get("is_constricted_dmg", 0)) > 0)
	if not has_status:
		return false
	p_data["burn_turns"] = 0
	p_data["is_poisoned"] = false
	p_data["toxic_envenomed"] = false
	p_data["is_flinched"] = false
	p_data["is_paralyzed"] = false
	p_data["paralyze_turns"] = 0
	p_data["is_asleep_turns"] = 0
	p_data["is_frozen"] = false
	p_data["frozen_turns"] = 0
	p_data["is_confused"] = false
	p_data["confused_turns"] = 0
	p_data["is_constricted_dmg"] = 0
	p_data["constricted_turns"] = 0
	inv["remedy"] -= 1
	return true

func buy_campaign_remedy() -> bool:
	var cur_gold = get_active_campaign_gold()
	var inv = get_active_campaign_inventory()
	if cur_gold >= 2:
		set_active_campaign_gold(cur_gold - 2)
		inv["remedy"] = inv.get("remedy", 0) + 1
		return true
	return false

func buy_campaign_ether() -> bool:
	var cur_gold = get_active_campaign_gold()
	var inv = get_active_campaign_inventory()
	if cur_gold >= 3:
		set_active_campaign_gold(cur_gold - 3)
		inv["ether"] = inv.get("ether", 0) + 1
		return true
	return false

# --- TOURNAMENT STRUCTURE & RIVAL GENERATION ---
func get_tournament_match_info(match_num: int) -> Dictionary:
	match match_num:
		1:
			return {
				"phase_num": 1,
				"phase_name": "Classification",
				"match_in_phase": 1,
				"reward_gold": 10,
				"reward_diamonds": 1,
				"desc": "Battle 1/3 (Warmup): 1 Basic Pokémon (Quick test battle)"
			}
		2:
			return {
				"phase_num": 1,
				"phase_name": "Classification",
				"match_in_phase": 2,
				"reward_gold": 15,
				"reward_diamonds": 2,
				"desc": "Battle 2/3 (Duo): 2 Basic Pokémon (Fast-paced clash)"
			}
		3:
			return {
				"phase_num": 1,
				"phase_name": "Classification",
				"match_in_phase": 3,
				"reward_gold": 25,
				"reward_diamonds": 5,
				"desc": "Battle 3/3 (Phase 1 Finale): 1 Basic + 1 Stage 1 Pokémon (+5 💎 Phase Bonus!)"
			}
		4:
			return {
				"phase_num": 2,
				"phase_name": "Elimination",
				"match_in_phase": 1,
				"reward_gold": 20,
				"reward_diamonds": 2,
				"desc": "Battle 1/3 (Duel): 1 Stage 1 Pokémon (Speed & tactics test)"
			}
		5:
			return {
				"phase_num": 2,
				"phase_name": "Elimination",
				"match_in_phase": 2,
				"reward_gold": 25,
				"reward_diamonds": 3,
				"desc": "Battle 2/3 (Tag Team): 2 Evolved / Strong Pokémon"
			}
		6:
			return {
				"phase_num": 2,
				"phase_name": "Elimination",
				"match_in_phase": 3,
				"reward_gold": 40,
				"reward_diamonds": 10,
				"desc": "Battle 3/3 (Phase 2 Finale): 2 Stage 1 / Tier A Pokémon (+10 💎 Phase Bonus!)"
			}
		7:
			return {
				"phase_num": 3,
				"phase_name": "Grand Finale",
				"match_in_phase": 1,
				"reward_gold": 30,
				"reward_diamonds": 4,
				"desc": "Battle 1/3 (Quarterfinals): 1 Stage 2 + 1 Stage 1 Pokémon"
			}
		8:
			return {
				"phase_num": 3,
				"phase_name": "Grand Finale",
				"match_in_phase": 2,
				"reward_gold": 40,
				"reward_diamonds": 5,
				"desc": "Battle 2/3 (Semifinals): 1 Stage 2 + 1 Elite Tier A Pokémon"
			}
		9:
			return {
				"phase_num": 3,
				"phase_name": "Grand Finale",
				"match_in_phase": 3,
				"reward_gold": 75,
				"reward_diamonds": 25,
				"desc": "Battle 3/3 (Championship): 3 Elite Tier A Pokémon! (+25 💎 Trophy Bonus!)"
			}
		_:
			return {
				"phase_num": 3,
				"phase_name": "Grand Finale",
				"match_in_phase": 3,
				"reward_gold": 0,
				"reward_diamonds": 0,
				"desc": "Tournament Complete"
			}

func get_tournament_candidates(stage_target: String = "any", rarity_target: String = "any", allowed_tiers: Array = ["D", "C", "B", "A"]) -> Array[int]:
	var result: Array[int] = []
	var st_clean = stage_target.strip_edges().to_lower()
	var r_clean = rarity_target.strip_edges().to_lower()
	
	for id in all_pokemon_ids:
		var d = pokemon_catalog.get(id, {})
		var r = str(d.get("rarity", "Common")).strip_edges().to_lower()
		var st = str(d.get("stage", "Basic")).strip_edges().to_lower()
		
		# 1. Ban Legendary rarity and stage completely from tournament rivals
		if r in ["legendary", "legendaria", "legendario", "ur", "ultra rare"] or st == "legendary":
			continue
			
		# 2. Ban Tier S and S+ strictly - Rivals MUST stay below Tier S (Tier D, C, B, A only)
		var p_tier = str(d.get("tier", "C")).strip_edges().to_upper()
		if p_tier in ["S", "S+", "SS", "SSS"]:
			continue
		if not allowed_tiers.is_empty() and not (p_tier in allowed_tiers):
			continue
			
		# 3. Filter stage
		var stage_ok = false
		if st_clean == "basic":
			stage_ok = (st == "basic")
		elif st_clean == "stage 1" or st_clean == "stage1":
			stage_ok = (st == "stage 1" or st == "stage1")
		elif st_clean == "stage 2" or st_clean == "stage2":
			stage_ok = (st == "stage 2" or st == "stage2")
		elif st_clean == "" or st_clean == "any":
			stage_ok = true
			
		if not stage_ok:
			continue
			
		# 4. Filter rarity
		if r_clean != "" and r_clean != "any":
			if r_clean == "common":
				if not (r in ["common", "comun", "común"]):
					continue
			elif r_clean == "uncommon":
				if not (r in ["uncommon", "poco común", "poco comun"]):
					continue
			elif r_clean == "rare":
				if not (r in ["rare", "rara", "raro", "r"]):
					continue
			elif r_clean == "epic":
				if not (r in ["epic", "epica", "épica", "epico"]):
					continue
			elif r != r_clean:
				continue
				
		result.append(id)
	return result

func pick_random_unique(pool: Array[int], count: int, exclude_ids: Array = []) -> Array[int]:
	var available: Array[int] = []
	for id in pool:
		if not (id in exclude_ids):
			available.append(id)
	available.shuffle()
	
	var picked: Array[int] = []
	for i in range(min(count, available.size())):
		picked.append(available[i])
		
	# Fallback if pool had fewer than count
	if picked.size() < count and not pool.is_empty():
		var copy_pool = pool.duplicate()
		copy_pool.shuffle()
		for id in copy_pool:
			if not (id in picked):
				picked.append(id)
				if picked.size() >= count:
					break
		while picked.size() < count:
			picked.append(copy_pool[randi() % copy_pool.size()])
			
	return picked

func generate_tournament_rival_team(match_num: int) -> Array[int]:
	match match_num:
		1:
			# Match 1 (Phase 1 Warmup): 1 Basic Pokémon (Tier D/C) - fast opening duel
			var pool = get_tournament_candidates("basic", "any", ["D", "C"])
			return pick_random_unique(pool, 1)
		2:
			# Match 2 (Phase 1 Skirmish): 2 Basic Pokémon (Tier C/B)
			var pool = get_tournament_candidates("basic", "any", ["C", "B"])
			return pick_random_unique(pool, 2)
		3:
			# Match 3 (Phase 1 Finale): 1 Basic (Tier B/C) + 1 Stage 1 (Tier B/A)
			var b = pick_random_unique(get_tournament_candidates("basic", "any", ["C", "B"]), 1)
			var s1 = pick_random_unique(get_tournament_candidates("stage 1", "any", ["C", "B", "A"]), 1, b)
			return b + s1
		4:
			# Match 4 (Phase 2 Duel): 1 Stage 1 Pokémon (Tier B/A) - snappy evolved clash
			var pool = get_tournament_candidates("stage 1", "any", ["B", "A"])
			return pick_random_unique(pool, 1)
		5:
			# Match 5 (Phase 2 Tag Team): 1 Stage 1 + 1 Basic (Tier B/A)
			var s1 = pick_random_unique(get_tournament_candidates("stage 1", "any", ["B", "A"]), 1)
			var b = pick_random_unique(get_tournament_candidates("basic", "any", ["B", "A"]), 1, s1)
			return s1 + b
		6:
			# Match 6 (Phase 2 Finale): 2 Pokémon: Stage 1 or Tier A powerhouses
			var pool = get_tournament_candidates("stage 1", "any", ["B", "A"])
			var team = pick_random_unique(pool, 2)
			if team.size() < 2:
				var backup = pick_random_unique(get_tournament_candidates("basic", "any", ["A"]), 1, team)
				team += backup
			return team
		7:
			# Match 7 (Phase 3 Contender): 1 Stage 2 (Tier A/B) + 1 Stage 1 / Basic (Tier A/B)
			var s2 = pick_random_unique(get_tournament_candidates("stage 2", "any", ["B", "A"]), 1)
			var support = pick_random_unique(get_tournament_candidates("stage 1", "any", ["B", "A"]), 1, s2)
			if support.is_empty():
				support = pick_random_unique(get_tournament_candidates("basic", "any", ["A"]), 1, s2)
			return s2 + support
		8:
			# Match 8 (Phase 3 Semifinals): 1 Stage 2 (Tier A) + 1 Elite Tier A Pokémon
			var s2 = pick_random_unique(get_tournament_candidates("stage 2", "any", ["A"]), 1)
			var elite = pick_random_unique(get_tournament_candidates("stage 1", "any", ["A"]), 1, s2)
			if elite.is_empty():
				elite = pick_random_unique(get_tournament_candidates("basic", "any", ["A"]), 1, s2)
			return s2 + elite
		9:
			# Match 9 (Phase 3 Grand Championship): 3 Elite Tier A Pokémon (NO Legendaries, strictly < Tier S!)
			var s2_pool = get_tournament_candidates("stage 2", "any", ["A"])
			var other_a_pool = get_tournament_candidates("any", "any", ["A"])
			var team: Array[int] = []
			var leader = pick_random_unique(s2_pool, 1)
			if not leader.is_empty():
				team.append_array(leader)
			var rest = pick_random_unique(other_a_pool, 3 - team.size(), team)
			team.append_array(rest)
			while team.size() < 3:
				var fill = pick_random_unique(get_tournament_candidates("any", "any", ["B", "A"]), 1, team)
				if fill.is_empty(): break
				team.append_array(fill)
			return team
		_:
			return pick_random_unique(get_tournament_candidates("basic", "any", ["D", "C"]), 1)

func get_campaign_rival_team(match_num: int) -> Array[int]:
	if match_num == current_tournament_rival_match and not current_tournament_rival_team.is_empty():
		return current_tournament_rival_team
		
	current_tournament_rival_team = generate_tournament_rival_team(match_num)
	current_tournament_rival_match = match_num
	return current_tournament_rival_team

func get_item_texture(item_name: String) -> Texture2D:
	var clean = item_name.strip_edges().to_lower()
	var file_name = "C Potion.png"
	if clean == "revive":
		file_name = "R Revive.png"
	elif clean == "remedy":
		file_name = "C Remedy.png"
	elif clean == "ether":
		file_name = "C Ether.png"
	var res_path = "res://assets/items/" + file_name
	if ResourceLoader.exists(res_path):
		return load(res_path)
	var paths = [
		ProjectSettings.globalize_path(res_path),
		"D:/Games/Pokemon Battle Frontier/ITEMS/" + file_name
	]
	for p in paths:
		if FileAccess.file_exists(p):
			var img = Image.load_from_file(p)
			if img:
				return ImageTexture.create_from_image(img)
	return null

func get_booster_pack_texture() -> Texture2D:
	var res_path = "res://assets/kanto_booster_pack.png"
	if ResourceLoader.exists(res_path):
		return load(res_path)
	var paths = [
		ProjectSettings.globalize_path(res_path),
		"D:/Games/Pokemon Battle Frontier/ART/Kanto Booster Pack.PNG",
		"D:/Games/Pokemon Battle Frontier/ART/Kanto Booster Pack.png",
		"D:/Games/Pokemon Battle Frontier/APP/pkmn-battle-frontier/assets/kanto_booster_pack.png"
	]
	for p in paths:
		if FileAccess.file_exists(p):
			var img = Image.load_from_file(p)
			if img:
				return ImageTexture.create_from_image(img)
	return null

func get_booster_rarity_rates() -> Array[Dictionary]:
	var counts = {}
	var weighted = {}
	var total_w = 0.0
	for id in all_pokemon_ids:
		var d = pokemon_catalog.get(id, {})
		var r_info = get_rarity_display_info(str(d.get("rarity", "Common")))
		var r_name = r_info["name"]
		if r_name == "Starter":
			r_name = "Common"
		var w = get_card_rarity_weight(str(d.get("rarity", "Common")))
		counts[r_name] = counts.get(r_name, 0) + 1
		weighted[r_name] = weighted.get(r_name, 0) + w
		total_w += w
		
	var rates: Array[Dictionary] = []
	var rarities_order = ["Common", "Uncommon", "Rare", "Epic", "Legendary"]
	for r_name in rarities_order:
		var w = weighted.get(r_name, 0)
		var pct = (float(w) / max(1.0, total_w)) * 100.0
		var r_info = get_rarity_display_info(r_name)
		rates.append({
			"name": r_name,
			"stars": r_info.get("stars", "⭐"),
			"color": r_info.get("color", Color.WHITE),
			"border": r_info.get("border", Color.WHITE),
			"percent": pct,
			"count": counts.get(r_name, 0)
		})
	return rates

var pokemon_textures_cache: Dictionary = {}

# Carga de texturas segura: busca primero en el proyecto y si no en la carpeta externa PKMN
func get_pokemon_texture(texture_path_or_file: String) -> Texture2D:
	if texture_path_or_file.strip_edges() == "":
		return null
	var key = texture_path_or_file.strip_edges()
	if pokemon_textures_cache.has(key):
		return pokemon_textures_cache[key]
		
	var tex: Texture2D = null
	var file_name = texture_path_or_file.get_file()
	
	# Candidatos a probar dentro de res://
	var res_candidates: Array[String] = []
	if texture_path_or_file.begins_with("res://"):
		res_candidates.append(texture_path_or_file)
	res_candidates.append("res://assets/cards/" + file_name)
	
	# Si tiene paréntesis como "125 (239).png", extraer "239.png" y "0239.png"
	var regex_paren = RegEx.new()
	regex_paren.compile("\\((\\d+)\\)")
	var match_res = regex_paren.search(file_name)
	if match_res:
		var inner_num = match_res.get_string(1)
		res_candidates.append("res://assets/cards/" + inner_num + ".png")
		res_candidates.append("res://assets/cards/%s.png" % inner_num.pad_zeros(3))
	
	for r_path in res_candidates:
		if ResourceLoader.exists(r_path):
			tex = load(r_path)
			if tex:
				break
				
	# Si no se encontró en res://, probar carga directa desde disco (PC)
	if not tex:
		var paths_on_disk = [
			ProjectSettings.globalize_path("res://assets/cards/" + file_name),
			"D:/Games/Pokemon Battle Frontier/PKMN/" + file_name,
			"D:/Games/Pokemon Battle Frontier/PKMN/cards/" + file_name
		]
		if match_res:
			var inner_num = match_res.get_string(1)
			paths_on_disk.append("D:/Games/Pokemon Battle Frontier/PKMN/" + inner_num + ".png")
			paths_on_disk.append("D:/Games/Pokemon Battle Frontier/PKMN/%s.png" % inner_num.pad_zeros(3))
			
		for disk_p in paths_on_disk:
			if FileAccess.file_exists(disk_p):
				var img = Image.load_from_file(disk_p)
				if img:
					tex = ImageTexture.create_from_image(img)
					break
					
	if tex:
		pokemon_textures_cache[key] = tex
	return tex

# --- ICONOS OFICIALES DE TIPOS ELEMENTALES ---
const TYPE_ICON_FILES = {
	"GRASS": "20px-Grass_icon.png",
	"FIRE": "20px-Fire_icon.png",
	"WATER": "20px-Water_icon.png",
	"THUNDER": "20px-Electric_icon.png",
	"ELECTRIC": "20px-Electric_icon.png",
	"NORMAL": "20px-Normal_icon.png",
	"DARK": "20px-Dark_icon.png",
	"POISON": "20px-Poison_icon.png",
	"BUG": "20px-Bug_icon.png",
	"FLYING": "20px-Flying_icon.png",
	"PSYCHIC": "20px-Psychic_icon.png",
	"FIGHTING": "20px-Fighting_icon.png",
	"GROUND": "20px-Ground_icon.png",
	"ROCK": "20px-Rock_icon.png",
	"STEEL": "20px-Steel_icon.png",
	"ICE": "20px-Ice_icon.png",
	"DRAGON": "20px-Dragon_icon.png",
	"FAIRY": "20px-Fairy_icon.png",
	"GHOST": "20px-Ghost_icon.png"
}

# --- COLORES PRIMARIOS ELEMENTALES ---
const TYPE_PRIMARY_COLORS: Dictionary = {
	"NORMAL": Color("#B0BEC5"), # Gris plateado brillante
	"FIRE": Color("#FF5722"), # Naranja fuego vibrante
	"WATER": Color("#29B6F6"), # Azul agua celeste vivo
	"GRASS": Color("#4CAF50"), # Verde esmeralda vivo
	"ELECTRIC": Color("#FFD700"), # Amarillo eléctrico puro
	"THUNDER": Color("#FFD700"),
	"ICE": Color("#4DD0E1"), # Cian hielo glaciar
	"FIGHTING": Color("#EF5350"), # Rojo carmesí marcial
	"POISON": Color("#AB47BC"), # Violeta magenta veneno
	"GROUND": Color("#D4A373"), # Tierra ocre cálido
	"FLYING": Color("#81D4FA"), # Celeste aerodinámico
	"PSYCHIC": Color("#F06292"), # Rosa psíquico
	"BUG": Color("#8BC34A"), # Verde lima bicho
	"ROCK": Color("#D7CCC8"), # Gris piedra ocre
	"GHOST": Color("#9575CD"), # Púrpura espectral
	"DRAGON": Color("#7986CB"), # Azul índigo dragón
	"STEEL": Color("#CFD8DC"), # Acero metálico claro
	"DARK": Color("#A55EEA"), # Amatista oscuro / siniestro legible
	"FAIRY": Color("#F48FB1"), # Rosa pastel hada
}

func get_type_primary_color(type_name: String) -> Color:
	var key = type_name.strip_edges().to_upper()
	if TYPE_PRIMARY_COLORS.has(key):
		return TYPE_PRIMARY_COLORS[key]
	return TYPE_PRIMARY_COLORS["NORMAL"]

var type_icons_cache: Dictionary = {}

func get_type_icon_texture(type_name: String) -> Texture2D:
	var key = type_name.strip_edges().to_upper()
	if type_icons_cache.has(key):
		return type_icons_cache[key]
		
	if not TYPE_ICON_FILES.has(key):
		return null
		
	var file_name = TYPE_ICON_FILES[key]
	var res_path = "res://assets/types/" + file_name
	var img: Image = null
	
	var disk_paths = [
		ProjectSettings.globalize_path(res_path),
		"D:/Games/Pokemon Battle Frontier/Icons/" + file_name
	]
	for p in disk_paths:
		if FileAccess.file_exists(p):
			img = Image.load_from_file(p)
			if img:
				break
				
	if not img and ResourceLoader.exists(res_path):
		var src_tex = load(res_path)
		if src_tex is Texture2D:
			img = src_tex.get_image()
			
	var tex: Texture2D = null
	if img:
		img.convert(Image.FORMAT_RGBA8)
		var type_col = get_type_primary_color(key)
		for y in range(img.get_height()):
			for x in range(img.get_width()):
				var px = img.get_pixel(x, y)
				if px.a > 0.0:
					img.set_pixel(x, y, Color(type_col.r * px.r, type_col.g * px.g, type_col.b * px.b, px.a))
		tex = ImageTexture.create_from_image(img)
		type_icons_cache[key] = tex
	return tex

# --- COLORES DE IMPACTO ELEMENTAL PARA ANIMACIÓN DE ATAQUES ---
const TYPE_HIT_COLORS: Dictionary = {
	"NORMAL": Color(2.2, 2.2, 2.2), # Destello blanco de impacto
	"FIRE": Color(2.4, 0.45, 0.15), # Fuego ardiente naranja rojizo
	"WATER": Color(0.2, 1.3, 2.5), # Agua torrente azul celeste
	"GRASS": Color(0.3, 2.3, 0.4), # Planta verde esmeralda
	"ELECTRIC": Color(2.4, 2.2, 0.2), # Eléctrico amarillo relámpago
	"THUNDER": Color(2.4, 2.2, 0.2), # Equivalente
	"ICE": Color(0.8, 2.2, 2.5), # Hielo cian gélido
	"FIGHTING": Color(2.3, 0.65, 0.2), # Lucha rojo ladrillo / impacto marcial
	"POISON": Color(1.9, 0.3, 2.1), # Veneno magenta tóxico
	"GROUND": Color(2.1, 1.25, 0.4), # Tierra arcilla / ámbar
	"FLYING": Color(0.6, 1.8, 2.5), # Volador azul eólico
	"PSYCHIC": Color(2.4, 0.3, 1.4), # Psíquico rosa místico brillante
	"BUG": Color(1.3, 2.1, 0.35), # Bicho verde lima
	"ROCK": Color(1.8, 1.4, 0.7), # Roca ocre arenoso
	"GHOST": Color(1.3, 0.5, 2.2), # Fantasma púrpura espectral
	"DRAGON": Color(1.4, 0.6, 2.4), # Dragón índigo radiante
	"STEEL": Color(1.9, 2.1, 2.4), # Acero destello metálico plateado
	"DARK": Color(1.4, 0.4, 1.7), # Siniestro violeta oscuro
	"FAIRY": Color(2.4, 1.1, 1.8), # Hada rosa radiante
}

func get_type_hit_color(type_name: String) -> Color:
	var key = type_name.strip_edges().to_upper()
	if TYPE_HIT_COLORS.has(key):
		return TYPE_HIT_COLORS[key]
	return TYPE_HIT_COLORS["NORMAL"]

# --- GESTIÓN DE PERFIL, GUARDADO Y AJUSTES DE AUDIO ---
func has_saved_profile() -> bool:
	return FileAccess.file_exists(SAVE_FILE_PATH)

func get_music_db() -> float:
	if settings_music_muted or settings_music_volume <= 0.01:
		return -80.0
	return linear_to_db(clamp(settings_music_volume, 0.01, 1.0))

func get_sfx_db() -> float:
	if settings_sfx_muted or settings_sfx_volume <= 0.01:
		return -80.0
	return linear_to_db(clamp(settings_sfx_volume, 0.01, 1.0))

const WELCOME_GIFT_DIAMONDS: int = 25
const WELCOME_GIFT_RARE_CANDIES: int = 50

func can_claim_welcome_gift() -> bool:
	if profile_welcome_claimed:
		return false
	if stats_packs_opened > 0 or stats_battles_total > 0 or stats_tournaments_won > 0:
		return false
	if player_unlocked_ids.size() > 4:
		return false
	if campaign_gold > 0 or adventure_current_episode > 1 or adventure_current_stage > 1:
		return false
	return true

func claim_welcome_gift() -> bool:
	if not can_claim_welcome_gift():
		print("[GameData] ⚠️ Regalo de bienvenida ya reclamado o cuenta con actividad previa.")
		return false
	player_diamonds += WELCOME_GIFT_DIAMONDS
	player_rare_candies += WELCOME_GIFT_RARE_CANDIES
	profile_welcome_claimed = true
	save_profile(true)
	diamonds_changed.emit(player_diamonds)
	rare_candies_changed.emit(player_rare_candies)
	print("[GameData] 🎉 Regalo de bienvenida reclamado con éxito: +%d Gemas, +%d Caramelos!" % [WELCOME_GIFT_DIAMONDS, WELCOME_GIFT_RARE_CANDIES])
	return true

func create_new_profile(p_name: String = "Trainer", provider: String = "Guest", p_email: String = "", auto_sync_cloud: bool = false) -> void:
	var clean = p_name.strip_edges()
	profile_name = clean if clean != "" else "Trainer"
	profile_email = p_email.strip_edges()
	profile_id = "PKMN-%d" % (randi() % 900000 + 100000)
	profile_auth_provider = provider
	profile_is_logged_in = true
	profile_created_at = Time.get_datetime_string_from_system()
	if not profile_email.is_empty():
		profile_cloud_key = profile_email
	stats_tournaments_won = 0
	stats_battles_won = 0
	stats_battles_total = 0
	stats_packs_opened = 0
	player_diamonds = 0
	player_rare_candies = 0
	profile_welcome_claimed = false
	reset_campaign()
	adventure_current_episode = 1
	adventure_current_stage = 1
	adventure_gold = 0
	adventure_inventory = {"potion": 0, "revive": 0, "remedy": 0, "ether": 0}
	adventure_player_team_state.clear()
	adventure_completed_episodes.clear()
	adventure_unlocked_episodes = [1]
	
	# Conservar cartas si ya existían cartas desbloqueadas en este dispositivo
	if player_unlocked_ids.is_empty():
		player_card_stocks.clear()
		for id in all_pokemon_ids:
			if pokemon_catalog[id].get("unlocked_start", false):
				player_unlocked_ids.append(id)
				player_card_stocks[id] = 1
		player_unlocked_ids.sort()
	else:
		for id in player_unlocked_ids:
			if not player_card_stocks.has(id) or player_card_stocks[id] < 1:
				player_card_stocks[id] = 1
				
	save_profile(auto_sync_cloud)
	diamonds_changed.emit(player_diamonds)
	rare_candies_changed.emit(player_rare_candies)
	print("Profile created for Trainer '%s' (Email: '%s'). Welcome gift pending claim!" % [profile_name, profile_email])

func create_or_update_profile(p_name: String, provider: String = "Local", p_email: String = "", auto_sync_cloud: bool = false) -> void:
	var clean = p_name.strip_edges()
	if clean != "":
		profile_name = clean
	if p_email.strip_edges() != "":
		profile_email = p_email.strip_edges()
		profile_cloud_key = profile_email
	profile_auth_provider = provider
	profile_is_logged_in = true
	if profile_created_at == "":
		profile_created_at = Time.get_datetime_string_from_system()
	save_profile(auto_sync_cloud)

func get_save_dict() -> Dictionary:
	return {
		"version": 1,
		"profile": {
			"name": profile_name,
			"trainer_alias": profile_name,
			"email": profile_email,
			"id": profile_id,
			"auth_provider": profile_auth_provider,
			"is_logged_in": profile_is_logged_in,
			"created_at": profile_created_at,
			"cloud_key": profile_cloud_key,
			"welcome_gift_claimed": profile_welcome_claimed
		},
		"stats": {
			"tournaments_won": stats_tournaments_won,
			"battles_won": stats_battles_won,
			"battles_total": stats_battles_total,
			"packs_opened": stats_packs_opened
		},
		"economy": {
			"diamonds": player_diamonds,
			"rare_candies": player_rare_candies
		},
		"collection": {
			"unlocked_ids": player_unlocked_ids,
			"stocks": player_card_stocks
		},
		"campaign": {
			"match_number": campaign_match_number,
			"gold": campaign_gold,
			"inventory": campaign_inventory,
			"team_state": campaign_player_team_state
		},
		"adventure": {
			"current_episode": adventure_current_episode,
			"current_stage": adventure_current_stage,
			"gold": adventure_gold,
			"inventory": adventure_inventory,
			"team_state": adventure_player_team_state,
			"completed_episodes": adventure_completed_episodes,
			"unlocked_episodes": adventure_unlocked_episodes
		},
		"settings": {
			"music_volume": settings_music_volume,
			"music_muted": settings_music_muted,
			"sfx_volume": settings_sfx_volume,
			"sfx_muted": settings_sfx_muted
		},
		"daily": {
			"login_last_date": daily_login_last_date,
			"login_streak": daily_login_streak,
			"login_claimed_today": daily_login_claimed_today,
			"missions_date": daily_missions_date,
			"missions": daily_missions,
			"bonus_chest_claimed": daily_bonus_chest_claimed
		},
		"friends": player_friends.duplicate(true)
	}

func apply_save_dict(data: Dictionary) -> bool:
	if typeof(data) != TYPE_DICTIONARY:
		return false
		
	# Cargar perfil
	var prof = data.get("profile", {})
	profile_name = prof.get("trainer_alias", prof.get("name", "Trainer"))
	profile_email = prof.get("email", "")
	profile_id = prof.get("id", "")
	profile_auth_provider = prof.get("auth_provider", "Guest")
	profile_is_logged_in = prof.get("is_logged_in", false)
	profile_created_at = prof.get("created_at", "")
	profile_cloud_key = prof.get("cloud_key", "")
	profile_welcome_claimed = bool(prof.get("welcome_gift_claimed", false))
	if profile_cloud_key.is_empty() and not profile_email.is_empty():
		profile_cloud_key = profile_email
		
	# Cargar amigos
	player_friends.clear()
	var raw_friends = data.get("friends", [])
	if typeof(raw_friends) == TYPE_ARRAY:
		for item in raw_friends:
			if typeof(item) == TYPE_DICTIONARY:
				player_friends.append(item.duplicate(true))
	
	# Cargar estadísticas con fusión (mantener el máximo progreso alcanzado)
	var st = data.get("stats", {})
	stats_tournaments_won = maxi(stats_tournaments_won, int(st.get("tournaments_won", 0)))
	stats_battles_won = maxi(stats_battles_won, int(st.get("battles_won", 0)))
	stats_battles_total = maxi(stats_battles_total, int(st.get("battles_total", 0)))
	stats_packs_opened = maxi(stats_packs_opened, int(st.get("packs_opened", 0)))
	
	# Cargar economía directa de la partida (sin sobreescribir ni resetear si el jugador tiene 0)
	var econ = data.get("economy", {})
	player_diamonds = int(econ.get("diamonds", 0))
	player_rare_candies = int(econ.get("rare_candies", 0))
	diamonds_changed.emit(player_diamonds)
	rare_candies_changed.emit(player_rare_candies)
	
	# Cargar colección (FUSIÓN INTELIGENTE: Jamás perder cartas ya obtenidas)
	var col = data.get("collection", {})
	var unl = col.get("unlocked_ids", [])
	if typeof(unl) == TYPE_ARRAY and unl.size() > 0:
		for id in unl:
			var int_id = int(id)
			if not (int_id in player_unlocked_ids) and pokemon_catalog.has(int_id):
				player_unlocked_ids.append(int_id)
		player_unlocked_ids.sort()
		
	# Si la cuenta ya tiene cartas obtenidas, sobres abiertos, batallas o torneos, el regalo inicial ya expiró o fue usado
	if stats_packs_opened > 0 or stats_battles_total > 0 or stats_tournaments_won > 0 or player_unlocked_ids.size() > 4 or (typeof(unl) == TYPE_ARRAY and unl.size() > 4):
		profile_welcome_claimed = true
		
	# Cargar stocks (mantener la cantidad más alta de cada carta)
	var raw_stocks = col.get("stocks", {})
	if typeof(raw_stocks) == TYPE_DICTIONARY:
		for k in raw_stocks.keys():
			var card_id = int(k)
			var cloud_stock = int(raw_stocks[k])
			player_card_stocks[card_id] = maxi(player_card_stocks.get(card_id, 0), cloud_stock)
	for id in player_unlocked_ids:
		if not player_card_stocks.has(id) or player_card_stocks[id] < 1:
			player_card_stocks[id] = 1
		
	# Cargar campaña
	var camp = data.get("campaign", {})
	campaign_match_number = int(camp.get("match_number", 1))
	campaign_gold = int(camp.get("gold", 0))
	campaign_inventory = camp.get("inventory", {"potion": 0, "revive": 0, "remedy": 0, "ether": 0})
	if not campaign_inventory.has("remedy"):
		campaign_inventory["remedy"] = 0
	if not campaign_inventory.has("ether"):
		campaign_inventory["ether"] = 0
	campaign_player_team_state = camp.get("team_state", [])
	
	# Cargar aventura
	var adv = data.get("adventure", {})
	adventure_current_episode = int(adv.get("current_episode", 1))
	adventure_current_stage = int(adv.get("current_stage", 1))
	var legacy_adv_gold = int(adv.get("gold", 0))
	if legacy_adv_gold > 0 and campaign_gold == 0:
		campaign_gold = legacy_adv_gold
	adventure_gold = campaign_gold
	adventure_inventory = adv.get("inventory", {"potion": 0, "revive": 0, "remedy": 0, "ether": 0})
	if not adventure_inventory.has("remedy"):
		adventure_inventory["remedy"] = 0
	if not adventure_inventory.has("ether"):
		adventure_inventory["ether"] = 0
	adventure_player_team_state = adv.get("team_state", [])
	var raw_comp = adv.get("completed_episodes", [])
	adventure_completed_episodes.clear()
	for c in raw_comp:
		adventure_completed_episodes.append(int(c))
	var raw_unl = adv.get("unlocked_episodes", [1])
	adventure_unlocked_episodes.clear()
	for u in raw_unl:
		adventure_unlocked_episodes.append(int(u))
	if not (1 in adventure_unlocked_episodes):
		adventure_unlocked_episodes.append(1)
		
	# Sanitizar: si el episodio ya fue completado o la etapa excede el total, reiniciar progreso del run
	var total_ep_stages = get_adventure_total_stages(adventure_current_episode)
	if adventure_current_episode in adventure_completed_episodes and adventure_current_stage >= total_ep_stages:
		reset_adventure_episode(adventure_current_episode)
	elif adventure_current_stage > total_ep_stages:
		reset_adventure_episode(adventure_current_episode)
		
	if campaign_gold > 0 or adventure_current_episode > 1 or adventure_current_stage > 1:
		profile_welcome_claimed = true
	
	# Cargar ajustes
	var sett = data.get("settings", {})
	settings_music_volume = float(sett.get("music_volume", 0.8))
	settings_music_muted = bool(sett.get("music_muted", false))
	settings_sfx_volume = float(sett.get("sfx_volume", 0.9))
	settings_sfx_muted = bool(sett.get("sfx_muted", false))
	
	# Cargar misiones diarias
	var daily = data.get("daily", {})
	daily_login_last_date = str(daily.get("login_last_date", ""))
	daily_login_streak = int(daily.get("login_streak", 1))
	if daily_login_streak <= 0:
		daily_login_streak = 1
	daily_login_claimed_today = bool(daily.get("login_claimed_today", false))
	daily_missions_date = str(daily.get("missions_date", ""))
	daily_missions.clear()
	var raw_m = daily.get("missions", [])
	if raw_m is Array:
		for item in raw_m:
			if item is Dictionary:
				daily_missions.append(item)
	daily_bonus_chest_claimed = bool(daily.get("bonus_chest_claimed", false))
	
	check_and_update_daily_system()
	
	return true

func save_profile(trigger_cloud_sync: bool = true) -> bool:
	var save_dict = get_save_dict()
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if not file:
		print("ERROR: Could not open save file for writing: ", SAVE_FILE_PATH)
		return false
	var json_str = JSON.stringify(save_dict, "\t")
	file.store_string(json_str)
	file.close()
	print("Profile saved successfully to: ", SAVE_FILE_PATH)
	
	# En Web: Sincronizar sistema de archivos de memoria con IndexedDB del navegador
	if OS.has_feature("web") and ClassDB.class_exists("JavaScriptBridge"):
		JavaScriptBridge.eval("if (window.godotSyncFS) { window.godotSyncFS(); } else if (window.FS && FS.syncfs) { FS.syncfs(false, function(err){}); }")
	
	# Sincronización automática en segundo plano con Google Cloud si la cuenta está ligada
	if trigger_cloud_sync and profile_auth_provider.begins_with("Google"):
		var main_loop = Engine.get_main_loop()
		if main_loop and main_loop is SceneTree and main_loop.root:
			var cs = main_loop.root.get_node_or_null("CloudSync")
			if cs:
				cs.sync_current_profile_to_cloud()
				
	return true

func load_profile() -> bool:
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		return false
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if not file:
		return false
	var json_text = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_text)
	if parse_result != OK:
		print("ERROR: Failed to parse save file JSON")
		return false
		
	var data = json.data
	var ok = apply_save_dict(data)
	if ok:
		print("Profile loaded successfully for Trainer: ", profile_name)
	return ok

func erase_profile() -> void:
	if FileAccess.file_exists(SAVE_FILE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_FILE_PATH))
		
	if OS.has_feature("web") and ClassDB.class_exists("JavaScriptBridge"):
		JavaScriptBridge.eval("if (window.godotSyncFS) { window.godotSyncFS(); } else if (window.FS && FS.syncfs) { FS.syncfs(false, function(err){}); }")
		
	profile_name = "Trainer"
	profile_email = ""
	profile_id = ""
	profile_auth_provider = "Guest"
	profile_is_logged_in = false
	profile_created_at = ""
	profile_cloud_key = ""
	stats_tournaments_won = 0
	stats_battles_won = 0
	stats_battles_total = 0
	stats_packs_opened = 0
	player_diamonds = 0
	player_rare_candies = 0
	
	reset_campaign()
	adventure_current_episode = 1
	adventure_current_stage = 1
	adventure_gold = 0
	adventure_inventory = {"potion": 0, "revive": 0, "remedy": 0, "ether": 0}
	adventure_player_team_state.clear()
	adventure_completed_episodes.clear()
	adventure_unlocked_episodes = [1]
	
	player_unlocked_ids.clear()
	player_friends.clear()
	for id in all_pokemon_ids:
		if pokemon_catalog[id].get("unlocked_start", false):
			player_unlocked_ids.append(id)
	player_unlocked_ids.sort()
	
	session_entered_lobby = false
	daily_login_last_date = ""
	daily_login_streak = 1
	daily_login_claimed_today = false
	daily_missions_date = ""
	daily_missions.clear()
	daily_bonus_chest_claimed = false
	settings_music_volume = 0.8
	settings_music_muted = false
	settings_sfx_volume = 0.9
	settings_sfx_muted = false
	print("Profile erased. Starting fresh!")
