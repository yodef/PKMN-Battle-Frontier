extends Node

# --- VERSION DEL JUEGO & ACTUALIZACIONES ---
const GAME_VERSION: String = "v0.6.3"
var update_direct_fallback_url: String = ""

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

func format_move_boost_summary(b_cost: int, b_dmg: int, eff_type: String, desc: String) -> String:
	if b_cost <= 0:
		return ""
	var parts: Array[String] = []
	if b_dmg > 0:
		parts.append("+%d Extra DMG" % b_dmg)
	var d_low = desc.to_lower()
	if eff_type == "FLINCH":
		parts.append("Inflicts Flinch")
	elif eff_type == "BURN" and b_dmg == 0:
		if "3 dmg" in d_low:
			parts.append("Inflicts Burn (3 DMG x 2 rds)")
		elif "2 dmg" in d_low:
			parts.append("Inflicts Burn (2 DMG x 2 rds)")
		else:
			parts.append("Inflicts Burn (1 DMG x 2 rds)")
	elif eff_type == "CONFUSION" and b_dmg == 0:
		parts.append("Inflicts Confusion")
	elif eff_type == "FREEZE" and b_dmg == 0:
		parts.append("Inflicts Freeze")
	elif eff_type == "PARALYZE" and b_dmg == 0:
		parts.append("Inflicts Paralyze")
	elif eff_type == "RECOIL":
		parts.append("Avoids Recoil DMG")
	elif eff_type == "DOUBLE_DMG":
		parts.append("Deals X2 DMG")
	elif eff_type == "LIFE_DRAIN" and "100%" in d_low:
		parts.append("100% HP Drain")
	elif eff_type == "SLOW_FOE" and ("extra energy" in d_low and "reduce" in d_low):
		parts.append("-1 Foe Speed")
	if parts.is_empty():
		return "Boosted Effect"
	return " & ".join(parts)

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
	var region: String = "Kanto"
	var evolves_from: String = ""
	var evolves_to: String = ""
	var required_stone: String = ""
	var required_exp: int = 0
	var current_exp: int = 0
	var max_exp: int = 10
	var moves: Array = [] # Siempre 2 movimientos activos

	func get_required_exp() -> int:
		if evolves_to.strip_edges() == "":
			return 0
		if required_exp > 0:
			return required_exp
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

# Cartas favoritas marcadas por el jugador
var player_favorites: Array[int] = []
# Top 3 Pokémon favoritos elegidos para exhibir en el perfil
var profile_showcase_ids: Array[int] = []

func is_pokemon_favorite(id: int) -> bool:
	return id in player_favorites

func set_pokemon_favorite(id: int, is_fav: bool) -> void:
	if is_fav:
		if id not in player_favorites:
			player_favorites.append(id)
	else:
		player_favorites.erase(id)

func toggle_pokemon_favorite(id: int) -> bool:
	var new_state = not is_pokemon_favorite(id)
	set_pokemon_favorite(id, new_state)
	return new_state

func set_profile_showcase(ids: Array) -> void:
	profile_showcase_ids.clear()
	for id in ids:
		var int_id = int(id)
		if int_id not in profile_showcase_ids and profile_showcase_ids.size() < 3:
			profile_showcase_ids.append(int_id)

func get_profile_showcase() -> Array[int]:
	if profile_showcase_ids.is_empty():
		for fid in player_favorites:
			if profile_showcase_ids.size() < 3 and fid not in profile_showcase_ids:
				profile_showcase_ids.append(fid)
		if profile_showcase_ids.is_empty():
			for uid in player_unlocked_ids:
				if profile_showcase_ids.size() < 3 and uid not in profile_showcase_ids:
					profile_showcase_ids.append(uid)
	return profile_showcase_ids

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
const GameLocalizationScript = preload("res://scripts/localization.gd")
signal language_changed(new_lang: String)
var settings_language: String = "en" # "en" (English) or "es" (Español)
var settings_music_volume: float = 0.8 # 0.0 to 1.0
var settings_music_muted: bool = false
var settings_sfx_volume: float = 0.9 # 0.0 to 1.0
var settings_sfx_muted: bool = false

func normalize_language_code(lang: String) -> String:
	var c = lang.strip_edges().to_lower()
	if c in ["es", "esp", "español", "espanol", "spanish", "1"]:
		return "es"
	return "en"

func is_spanish() -> bool:
	return settings_language == "es"

func get_current_language() -> String:
	return settings_language

func tr_text(en_text: String, es_text: String = "") -> String:
	if settings_language == "es":
		if es_text != "":
			return es_text
		return GameLocalizationScript.translate_en_to_es(en_text)
	return en_text

func set_language(lang: String, persist: bool = true) -> void:
	var norm = normalize_language_code(lang)
	var changed = (settings_language != norm)
	settings_language = norm
	apply_language_to_scene_tree()
	if changed:
		language_changed.emit(settings_language)
	if persist:
		save_profile()

func apply_language_to_scene_tree() -> void:
	var tree = get_tree()
	if tree and tree.root:
		GameLocalizationScript.translate_node_tree(tree.root, settings_language)

func _on_scene_node_added(node: Node) -> void:
	if settings_language == "es" and node:
		GameLocalizationScript.translate_node_tree(node, settings_language)

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

# Modo Tutorial de Combate:
var is_tutorial_mode: bool = false
var tutorial_completed: bool = false
var tutorial_reward_claimed: bool = false
var just_completed_tutorial: bool = false

# Modo Torneo:
const ITEM_COST_POTION: int = 5
const ITEM_COST_SUPER_POTION: int = 9
const ITEM_COST_HYPER_POTION: int = 15
const ITEM_COST_POKE_FLUTE: int = 20
const ITEM_COST_REVIVE: int = 9
const ITEM_COST_REMEDY: int = 3
const ITEM_COST_ETHER: int = 5
const ITEM_COST_STONE: int = 10

const EVOLUTION_STONE_TYPES: Array[String] = [
	"Fire", "Water", "Leaf", "Thunder", "Ground",
	"Heart", "Night", "Psyche", "Punch", "Scale"
]

const DEFAULT_INVENTORY: Dictionary = {
	"potion": 0,
	"super_potion": 0,
	"hyper_potion": 0,
	"revive": 0,
	"remedy": 0,
	"ether": 0,
	"poke_flute": 0
}

var campaign_match_number: int = 1 # 1 to 9 (10 = Tournament Champion)
var campaign_gold: int = 0
var campaign_inventory: Dictionary = DEFAULT_INVENTORY.duplicate()
var campaign_player_team_state: Array = []
var current_tournament_rival_team: Array[int] = []
var current_tournament_rival_match: int = -1

# Modo Aventura (Episodios):
var adventure_current_episode: int = 1
var adventure_current_stage: int = 1 # 1 to 4
var adventure_gold: int = 0
var adventure_inventory: Dictionary = DEFAULT_INVENTORY.duplicate()
var adventure_player_team_state: Array = []
var adventure_completed_episodes: Array[int] = []
var adventure_unlocked_episodes: Array[int] = [1]
var last_adventure_episode_conquered: bool = false
var adventure_ep5_selected_route: String = "rocket_hideout"
var adventure_ep5_cleared_routes: Array[String] = []
var adventure_ep6_selected_route: String = "silph_co"
var adventure_ep6_cleared_routes: Array[String] = []
var adventure_ep7_selected_route: String = "pokemon_mansion"
var adventure_ep7_cleared_routes: Array[String] = []

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
		"subtitle": "Traverse Mt. Moon and Route 4 to challenge Gym Leader Misty!",
		"reward_diamonds_first_clear": 25,
		"stages": [
			{
				"stage_num": 1,
				"trainer_title": "Bird Keeper",
				"trainer_name": "Bird Keeper Perry",
				"intro": "The sky belongs to my bird Pokémon! Spearow and Pidgey, dive in!",
				"outro": "Grounded already? What a fierce flight!",
				"team_pokemon_names": ["Spearow", "Pidgey"]
			},
			{
				"stage_num": 2,
				"trainer_title": "Lass",
				"trainer_name": "Lass Iris",
				"intro": "Listen closely to my Jigglypuff's soothing melody... sleep tight!",
				"outro": "My lullaby wasn't enough to stop you!",
				"team_pokemon_names": ["Jigglypuff"]
			},
			{
				"stage_num": 3,
				"trainer_title": "Team Rocket Grunt",
				"trainer_name": "Rocket Grunt",
				"intro": "Hand over your rare cards! Ekans and Zubat, strike from the shadows!",
				"outro": "Team Rocket is blasting off again?!",
				"team_pokemon_names": ["Ekans", "Zubat"]
			},
			{
				"stage_num": 4,
				"trainer_title": "Hiker",
				"trainer_name": "Hiker Marcos",
				"intro": "Mt. Moon's boulders are tough, but my rock crew is tougher!",
				"outro": "Crumbled to dust! You've got sheer power!",
				"team_pokemon_names": ["Geodude", "Rhyhorn"]
			},
			{
				"stage_num": 5,
				"trainer_title": "Gym Leader Misty",
				"trainer_name": "Gym Leader Misty",
				"is_boss": true,
				"badge_name": "Cascade Badge",
				"intro": "I'm Misty, the Tomboyish Mermaid! My Water Pokémon will wash you away!",
				"outro": "You're genuinely talented! You've earned the Cascade Badge!",
				"team_pokemon_names": ["Staryu", "Psyduck", "Starmie"]
			}
		]
	},
	3: {
		"id": 3,
		"title": "Episode III: Vermilion City Gym",
		"subtitle": "Board the S.S. Anne and battle through Vermilion to challenge Gym Leader Lt. Surge!",
		"reward_diamonds_first_clear": 30,
		"stages": [
			{
				"stage_num": 1,
				"trainer_title": "Camper",
				"trainer_name": "Camper Drew",
				"intro": "Watch your step! Sandshrew digs into battle with sandstorms and sharp claws!",
				"outro": "Buried in defeat... you saw right through my defense!",
				"team_pokemon_names": ["Sandshrew"]
			},
			{
				"stage_num": 2,
				"trainer_title": "Picnicker",
				"trainer_name": "Picnicker Diana",
				"intro": "Aren't Clefairy and Pikachu the cutest? But don't underestimate their spark!",
				"outro": "Oh no, our spark fizzled out!",
				"team_pokemon_names": ["Clefairy", "Pikachu"]
			},
			{
				"stage_num": 3,
				"trainer_title": "Sailor",
				"trainer_name": "Sailor Dwayne",
				"intro": "Ahoy! The S.S. Anne is full of tough sailors. Poliwhirl, deliver a tidal punch!",
				"outro": "Washed overboard! What a solid fighter you are!",
				"team_pokemon_names": ["Poliwhirl"]
			},
			{
				"stage_num": 4,
				"trainer_title": "Black Belt",
				"trainer_name": "Black Belt Toru",
				"intro": "Martial arts focus! Mankey and Machop, show them our rigorous training!",
				"outro": "Hoo-hah! Your combat technique was superior!",
				"team_pokemon_names": ["Mankey", "Machop"]
			},
			{
				"stage_num": 5,
				"trainer_title": "Rival",
				"trainer_name": "Rival Blue",
				"intro": "Hey! Still trailing behind me? Charmeleon and Ivysaur will show you true power!",
				"outro": "What?! How did you get this strong already? Smell ya later!",
				"team_pokemon_names": ["Charmeleon", "Ivysaur"]
			},
			{
				"stage_num": 6,
				"trainer_title": "Team Rocket Grunt",
				"trainer_name": "Rocket Grunt Jax",
				"intro": "Team Rocket's shadows lurk everywhere! Arbok and Persian, take their Pokémon!",
				"outro": "Blast! Boss Giovanni won't be happy with this failure!",
				"team_pokemon_names": ["Arbok", "Persian"]
			},
			{
				"stage_num": 7,
				"trainer_title": "Gym Leader Lt. Surge",
				"trainer_name": "Gym Leader Lt. Surge",
				"is_boss": true,
				"badge_name": "Thunder Badge",
				"intro": "Ten-hut! I'm Lt. Surge, the Lightning American! Electric Pokémon saved me in war... they'll shock you into submission!",
				"outro": "Whoa! You're the real deal, soldier! Take the Thunder Badge!",
				"team_pokemon_names": ["Voltorb", "Magneton", "Raichu"]
			}
		]
	},
	4: {
		"id": 4,
		"title": "Episode IV: Celadon City Gym",
		"subtitle": "Traverse Route 9, Rock Tunnel, and Route 7 to challenge Gym Leader Erika!",
		"reward_diamonds_first_clear": 35,
		"stages": [
			{
				"stage_num": 1,
				"trainer_title": "Youngster",
				"trainer_name": "Youngster Joey",
				"intro": "My Sandshrew and Rattata are full of energy! Think you can keep up?",
				"outro": "Whoa, you're pretty tough! Good match!",
				"team_pokemon_names": ["Sandshrew", "Rattata"]
			},
			{
				"stage_num": 2,
				"trainer_title": "PokéManiac",
				"trainer_name": "PokéManiac Miguel",
				"intro": "Electricity, magnets, and static spheres! My electric trio will shock you!",
				"outro": "My circuit breaker tripped! What overwhelming power!",
				"team_pokemon_names": ["Voltorb", "Magnemite", "Pikachu"]
			},
			{
				"stage_num": 3,
				"trainer_title": "Hiker",
				"trainer_name": "Hiker Clark",
				"intro": "Rock-solid determination! Rhyhorn and Graveler, crush their spirit with sheer force!",
				"outro": "Even the toughest boulders crumble against your power!",
				"team_pokemon_names": ["Rhyhorn", "Graveler"]
			},
			{
				"stage_num": 4,
				"trainer_title": "Bird Keeper",
				"trainer_name": "Bird Keeper Donald",
				"intro": "Look up to the sky! Pidgeotto and Fearow rule the winds with razor-sharp talons!",
				"outro": "Shot down from the sky! What remarkable speed you have!",
				"team_pokemon_names": ["Pidgeotto", "Fearow"]
			},
			{
				"stage_num": 5,
				"trainer_title": "Rich Girl",
				"trainer_name": "Rich Girl Chloe",
				"intro": "Only the most elegant and pampered Pokémon belong on my team! Clefairy and Jigglypuff, show them true class!",
				"outro": "Unbelievable! My precious darlings were defeated?!",
				"team_pokemon_names": ["Clefairy", "Jigglypuff"]
			},
			{
				"stage_num": 6,
				"trainer_title": "Rival",
				"trainer_name": "Rival Blue",
				"intro": "You made it all the way to Celadon? Alakazam's intellect and Blastoise's hydro cannons will blast you back to Pallet Town!",
				"outro": "What?! No way! You got lucky again... but don't think you're ahead of me! Smell ya later!",
				"team_pokemon_names": ["Alakazam", "Blastoise"]
			},
			{
				"stage_num": 7,
				"trainer_title": "Tunnel Explorer",
				"trainer_name": "Spelunker Gordon",
				"intro": "Deep beneath the dark Rock Tunnel, the ground trembles! Digglet and Dugtrio, strike from underground!",
				"outro": "Dug right into defeat... You conquered the darkness of Rock Tunnel!",
				"team_pokemon_names": ["Digglet", "Dugtrio"]
			},
			{
				"stage_num": 8,
				"trainer_title": "Gym Leader Erika",
				"trainer_name": "Gym Leader Erika",
				"is_boss": true,
				"badge_name": "Rainbow Badge",
				"intro": "Hello... Welcome to Celadon Gym. I am Erika, a student of the delicate art of flower arranging. My nature Pokémon bloom with fierce grace. Shall we begin?",
				"outro": "Such magnificent elegance in battle... You have truly proven your bond. Please accept the Rainbow Badge!",
				"team_pokemon_names": ["Tangela", "Weepinbell", "Vileplume"]
			}
		]
	},
	5: {
		"id": 5,
		"title": "Episode V: Team Rocket, Pokémon Tower & Fuchsia Gym",
		"subtitle": "Infiltrate Team Rocket's Hideout, dispel spirits in Pokémon Tower, and challenge Gym Leader Koga!",
		"is_branching": true,
		"routes": {
			"rocket_hideout": {
				"id": "rocket_hideout",
				"name": "Team Rocket Hideout",
				"name_es": "Base Secreta del Team Rocket",
				"desc": "Infiltrate the underground Rocket Hideout beneath the Celadon Game Corner.",
				"reward_diamonds_first_clear": 20,
				"stages": [
					{
						"stage_num": 1,
						"trainer_title": "Rocket Grunt",
						"trainer_name": "Rocket Grunt",
						"intro": "Hey you! You're snooping around Team Rocket's secret hideout! Zubat, Rattata, Ekans, attack!",
						"outro": "Ugh... Don't think Boss Giovanni won't hear about this!",
						"team_pokemon_names": ["Zubat", "Rattata", "Ekans"]
					},
					{
						"stage_num": 2,
						"trainer_title": "Rocket Scientist",
						"trainer_name": "Rocket Scientist",
						"intro": "Our scientific experiments on Pokémon are top secret! Elekid, Magnemite, Electrode, overload!",
						"outro": "My scientific calculations failed... what tremendous energy!",
						"team_pokemon_names": ["Elekid", "Magnemite", "Electrode"]
					},
					{
						"stage_num": 3,
						"trainer_title": "Rocket Commander",
						"trainer_name": "Rocket Commander",
						"intro": "I am a Team Rocket Commander! Raticate's sharp fangs and Arbok's poison will finish you!",
						"outro": "Inconceivable! Beaten by an ordinary trainer?!",
						"team_pokemon_names": ["Raticate", "Arbok"]
					},
					{
						"stage_num": 4,
						"trainer_title": "Rocket Commander",
						"trainer_name": "Rocket Commander",
						"intro": "You won't reach the Boss! Golbat, screech from the darkness! Electabuzz, shock them to pieces!",
						"outro": "No... Boss Giovanni, forgive my failure!",
						"team_pokemon_names": ["Golbat", "Electabuzz"]
					},
					{
						"stage_num": 5,
						"trainer_title": "Líder Giovanni",
						"trainer_name": "Líder Giovanni",
						"is_boss": true,
						"has_super_potion": true,
						"intro": "So you've intruded into my private office. I am Giovanni, the leader of Team Rocket! Taste true overwhelming force!",
						"outro": "Ha! Remarkable strength! But mark my words, Team Rocket will conquer this world!",
						"team_pokemon_names": ["Rhyhorn", "Persian", "Kangaskhan"]
					}
				]
			},
			"pokemon_tower": {
				"id": "pokemon_tower",
				"name": "Pokémon Tower",
				"name_es": "Torre Pokémon",
				"desc": "Climb the haunted Pokémon Tower in Lavender Town and free the trapped souls.",
				"reward_diamonds_first_clear": 15,
				"reward_item": "poke_flute",
				"stages": [
					{
						"stage_num": 1,
						"trainer_title": "Exorcista Novato",
						"trainer_name": "Exorcista Novato",
						"intro": "Be gone, intruder! The spirits of Pokémon Tower are restless! Ghastly, emerge!",
						"outro": "The spirits have been calmed...",
						"team_pokemon_names": ["Ghastly", "Ghastly"]
					},
					{
						"stage_num": 2,
						"trainer_title": "Exorcista Veterano",
						"trainer_name": "Exorcista Veterano",
						"intro": "You cannot hide from the paranormal! Ghastly and Haunter, envelop them in spectral mist!",
						"outro": "Such fearless conviction!",
						"team_pokemon_names": ["Ghastly", "Haunter"]
					},
					{
						"stage_num": 3,
						"trainer_title": "Exorcista Chamán",
						"trainer_name": "Exorcista Chamán",
						"intro": "Hehehe... Two shadows approach from the spirit realm! Haunter, curse them!",
						"outro": "The spectral veil has lifted!",
						"team_pokemon_names": ["Haunter", "Haunter"]
					},
					{
						"stage_num": 4,
						"trainer_title": "Entrenador Poseído",
						"trainer_name": "Entrenador Poseído",
						"is_boss": true,
						"intro": "G-GIVE... US... PEACE... Sandshrew, Marowak and Gengar, claim this soul!",
						"outro": "Thank you... The fog in my mind has finally cleared! Take this sacred Poké Flute!",
						"team_pokemon_names": ["Sandshrew", "Marowak", "Gengar"]
					}
				]
			},
			"fuchsia_gym": {
				"id": "fuchsia_gym",
				"name": "Fuchsia City Gym",
				"name_es": "Gimnasio de Koga",
				"desc": "Navigate the invisible walls of Fuchsia Gym and challenge the Poisonous Ninja Master Koga!",
				"reward_diamonds_first_clear": 15,
				"badge_name": "Soul Badge",
				"stages": [
					{
						"stage_num": 1,
						"trainer_title": "Domador",
						"trainer_name": "Domador",
						"intro": "My beasts strike with blinding poison speed! Ekans, Venonat, Golbat, attack!",
						"outro": "My poisonous beasts were outmatched!",
						"team_pokemon_names": ["Ekans", "Venonat", "Golbat"]
					},
					{
						"stage_num": 2,
						"trainer_title": "Malabarista",
						"trainer_name": "Malabarista",
						"intro": "Step right up! Toxic gas and psychic tricks! Koffing, Drowzee, Hypno, confuse them!",
						"outro": "My juggling balls dropped! You saw right through our tricks!",
						"team_pokemon_names": ["Koffing", "Drowzee", "Hypno"]
					},
					{
						"stage_num": 3,
						"trainer_title": "Líder Koga",
						"trainer_name": "Líder Koga",
						"is_boss": true,
						"badge_name": "Soul Badge",
						"intro": "Fwahahaha! A mere child challenges me, Koga the poisonous ninja master? My Muk, Weezing, and Venomoth will suffocate you in toxins!",
						"outro": "Incredible ninjutsu! You have pierced through my lethal toxins. You have earned the Soul Badge!",
						"team_pokemon_names": ["Muk", "Weezing", "Venomoth"]
					}
				]
			}
		}
	},
	6: {
		"id": 6,
		"title": "Episode VI: Silph Co. & Saffron City Gym",
		"subtitle": "Liberate Silph Co. headquarters from Team Rocket and challenge Gym Leader Sabrina!",
		"is_branching": true,
		"routes": {
			"silph_co": {
				"id": "silph_co",
				"name": "Torre Silph S. A.",
				"name_es": "Torre Silph S. A.",
				"desc": "Infiltrate the 11-floor Silph Co. corporate skyscraper taken hostage by Team Rocket and defeat Boss Giovanni!",
				"reward_diamonds_first_clear": 20,
				"stages": [
					{
						"stage_num": 1,
						"trainer_title": "Rocket Grunt",
						"trainer_name": "Rocket Grunt",
						"intro": "The entire Silph Co. building is under Team Rocket's command! Ekans and Golbat, take down this trespasser!",
						"outro": "How did you push through our perimeter?!",
						"team_pokemon_names": ["Ekans", "Golbat"]
					},
					{
						"stage_num": 2,
						"trainer_title": "Rocket Grunt",
						"trainer_name": "Rocket Grunt",
						"intro": "You won't make it to the upper executive floors! Koffing, choke them with smoke! Arbok, strike!",
						"outro": "Our defensive barricade was shattered!",
						"team_pokemon_names": ["Koffing", "Arbok"]
					},
					{
						"stage_num": 3,
						"trainer_title": "Rocket Grunt",
						"trainer_name": "Rocket Grunt",
						"intro": "Sludge and hardened shells! Grimer and Kakuna, block this staircase!",
						"outro": "Even Kakuna's Iron Defense couldn't stop you...",
						"team_pokemon_names": ["Grimer", "Kakuna"]
					},
					{
						"stage_num": 4,
						"trainer_title": "Rocket Scientist",
						"trainer_name": "Rocket Scientist",
						"intro": "Silph Co.'s Master Ball technology belongs to us! Magmar's intense heat and Electivire's high voltage will fry you!",
						"outro": "My electrical calculations failed completely!",
						"team_pokemon_names": ["Magmar", "Electivire"]
					},
					{
						"stage_num": 5,
						"trainer_title": "Rocket Commander",
						"trainer_name": "Rocket Commander",
						"intro": "You've caused enough trouble in this corporate tower! Raticate, Arbok, and Weezing, wipe out this meddler!",
						"outro": "Impossible! To think our elite squad was overcome!",
						"team_pokemon_names": ["Raticate", "Arbok", "Weezing"]
					},
					{
						"stage_num": 6,
						"trainer_title": "Líder Giovanni",
						"trainer_name": "Líder Giovanni",
						"is_boss": true,
						"super_potions": 2,
						"intro": "So you have cornered me here in the president's office... Impressive. But I, Giovanni, will not abandon our ambition! Rhydon, Persian, Kangaskhan, crush them without mercy!",
						"outro": "Blast it all! To be bested by a child twice... Team Rocket shall withdraw from Silph Co., but our shadows will never fade!",
						"team_pokemon_names": ["Rhydon", "Persian", "Kangaskhan"]
					}
				]
			},
			"saffron_gym": {
				"id": "saffron_gym",
				"name": "Gimnasio de Sabrina",
				"name_es": "Gimnasio de Sabrina",
				"desc": "Step into the teleporter maze of Saffron Gym and challenge the Psychic Master Sabrina!",
				"reward_diamonds_first_clear": 20,
				"badge_name": "Marsh Badge",
				"stages": [
					{
						"stage_num": 1,
						"trainer_title": "Psíquico Novato",
						"trainer_name": "Psíquico Novato",
						"intro": "I sensed your thoughts as soon as you stepped through the warp panel! Abra, Slowpoke, Drowzee, confound them!",
						"outro": "My telepathic vision was blurred by your willpower!",
						"team_pokemon_names": ["Abra", "Slowpoke", "Drowzee"]
					},
					{
						"stage_num": 2,
						"trainer_title": "Psíquico Veterano",
						"trainer_name": "Psíquico Veterano",
						"intro": "Mime Jr. and Smoochum will enchant your senses, while Kadabra bends reality! Can you comprehend our psychic waves?",
						"outro": "Such clarity and sharp focus!",
						"team_pokemon_names": ["Mime Jr.", "Smoochum", "Kadabra"]
					},
					{
						"stage_num": 3,
						"trainer_title": "Psíquico Veterano",
						"trainer_name": "Psíquico Veterano",
						"intro": "Frosty psychic illusions and pendulum hypnoses! Jynx and Hypno, induce them into an endless trance!",
						"outro": "Your mental resolve snapped our hypnosis!",
						"team_pokemon_names": ["Jynx", "Hypno"]
					},
					{
						"stage_num": 4,
						"trainer_title": "Líder Sabrina",
						"trainer_name": "Líder Sabrina",
						"is_boss": true,
						"badge_name": "Marsh Badge",
						"intro": "I had a vision of your arrival. I dislike meaningless fighting, but my telekinetic powers will test your soul. Venomoth, Mr. Mime, Alakazam... show them true psychic mastery!",
						"outro": "Your power exceeds what my telepathy foresaw... I was defeated. You have earned the Marsh Badge!",
						"team_pokemon_names": ["Venomoth", "Mr. Mime", "Alakazam"]
					}
				]
			},
			"fighting_dojo": {
				"id": "fighting_dojo",
				"name": "PokéDojo",
				"name_es": "PokéDojo",
				"desc": "Challenge the masters of martial arts at the Saffron Fighting Dojo to claim their legendary prizes!",
				"reward_diamonds_first_clear": 20,
				"reward_pokemon": ["Hitmonlee", "Hitmonchan"],
				"stages": [
					{
						"stage_num": 1,
						"trainer_title": "Luchador",
						"trainer_name": "Luchador Ken",
						"intro": "Hiyah! We blend martial discipline with sheer power! Machop, Mankey, and Abra, engage!",
						"outro": "Your fighting spirit was truly remarkable!",
						"team_pokemon_names": ["Machop", "Mankey", "Abra"]
					},
					{
						"stage_num": 2,
						"trainer_title": "Luchador",
						"trainer_name": "Luchador Ryu",
						"intro": "Fists of iron and relentless rage! Machoke and Primeape, show them real muscle!",
						"outro": "Down for the count! What explosive impact!",
						"team_pokemon_names": ["Machoke", "Primeape"]
					},
					{
						"stage_num": 3,
						"trainer_title": "Luchador",
						"trainer_name": "Luchador Mike",
						"intro": "Legs as sharp as blades, punches as swift as lightning! Hitmonlee and Hitmonchan, strike with perfection!",
						"outro": "Our signature forms were countered with absolute precision!",
						"team_pokemon_names": ["Hitmonlee", "Hitmonchan"]
					},
					{
						"stage_num": 4,
						"trainer_title": "Campeón del Dojo",
						"trainer_name": "Campeón Koichi",
						"is_boss": true,
						"intro": "I am Koichi, Karate Master of this PokéDojo! Pinsir's crushing grip and Machamp's four-fisted barrage shall test your ultimate mastery! En garde!",
						"outro": "Magnificent! You have bested our Dojo! As tradition dictates, accept our rarest martial champions!",
						"team_pokemon_names": ["Pinsir", "Machamp"]
					}
				]
			}
		}
	},
	7: {
		"id": 7,
		"title": "Episode VII: Pokémon Mansion & Cinnabar Gym",
		"subtitle": "Explore the scorched Pokémon Mansion and conquer Gym Leader Blaine's volcanic Gym in Cinnabar Island!",
		"is_branching": true,
		"routes": {
			"pokemon_mansion": {
				"id": "pokemon_mansion",
				"name": "Pokémon Mansion",
				"name_es": "Mansión Pokémon",
				"desc": "Explore the ruined mansion on Cinnabar Island and battle researchers, Team Rocket infiltrators, and your Rival!",
				"reward_diamonds_first_clear": 35,
				"stages": [
					{
						"stage_num": 1,
						"trainer_title": "Domador",
						"trainer_name": "Domador Cole",
						"intro": "Watch your step in this burnt mansion! Ekans and Arbok, strike from the shadows!",
						"outro": "My serpents couldn't constrict your team!",
						"team_pokemon_names": ["Ekans", "Arbok"]
					},
					{
						"stage_num": 2,
						"trainer_title": "Pokénerd",
						"trainer_name": "Pokénerd Leo",
						"intro": "Electricity sparks in the rubble! Pikachu and Jolteon, discharge maximum voltage!",
						"outro": "Our circuits blew! Super high voltage!",
						"team_pokemon_names": ["Pikachu", "Jolteon"]
					},
					{
						"stage_num": 3,
						"trainer_title": "Grunt del Equipo Rocket",
						"trainer_name": "Grunt del Equipo Rocket",
						"intro": "Team Rocket searches for the secret cloning diary! Growlithe, burn them! Muk, swallow them in sludge!",
						"outro": "Boss Giovanni won't like this...",
						"team_pokemon_names": ["Growlithe", "Muk"]
					},
					{
						"stage_num": 4,
						"trainer_title": "Pokéfán",
						"trainer_name": "Pokéfán Nora",
						"intro": "Aren't fairy Pokémon so adorable yet fiercely strong? Wigglytuff and Clefable, show your charm!",
						"outro": "My darlings lost! You have immense fortitude!",
						"team_pokemon_names": ["Wigglytuff", "Clefable"]
					},
					{
						"stage_num": 5,
						"trainer_title": "Montañista",
						"trainer_name": "Montañista Bronson",
						"intro": "Heavy rocks and tough muscle! Machop, Nidorino, and Golem, roll right over them!",
						"outro": "My rock-hard wall was shattered!",
						"team_pokemon_names": ["Machop", "Nidorino", "Golem"]
					},
					{
						"stage_num": 6,
						"trainer_title": "Rival",
						"trainer_name": "Rival Blue",
						"is_boss": true,
						"intro": "Hey, you made it all the way out to Cinnabar? I was checking the mansion secrets! Kadabra, Charizard, and Pidgeot, let's crush them! Smell ya later!",
						"outro": "No way! You survived Charizard's flames?! Fine... but Blaine is way tougher than me! Don't get cocky!",
						"team_pokemon_names": ["Kadabra", "Charizard", "Pidgeot"]
					}
				]
			},
			"blaine_gym": {
				"id": "blaine_gym",
				"name": "Cinnabar Island Gym",
				"name_es": "Gimnasio de Blaine",
				"desc": "Answer the quiz questions and battle fire-type specialists to claim the Volcano Badge!",
				"reward_diamonds_first_clear": 35,
				"badge_name": "Volcano Badge",
				"stages": [
					{
						"stage_num": 1,
						"trainer_title": "Domador",
						"trainer_name": "Domador Vince",
						"intro": "Rapid ash and feral fangs! Rapidash, Ekans, and Raticate, rush in!",
						"outro": "Burned out in seconds!",
						"team_pokemon_names": ["Rapidash", "Ekans", "Raticate"]
					},
					{
						"stage_num": 2,
						"trainer_title": "Montañista",
						"trainer_name": "Montañista Dusty",
						"intro": "Volcanic magma creates the hardest minerals! Geodude, Nidorina, and Graveler, endure and strike!",
						"outro": "Cooled down and cracked open!",
						"team_pokemon_names": ["Geodude", "Nidorina", "Graveler"]
					},
					{
						"stage_num": 3,
						"trainer_title": "Pokéexperto",
						"trainer_name": "Pokéexperto Derek",
						"intro": "A single titan with colossal endurance and crushing power! Snorlax, awaken and dominate!",
						"outro": "Snorlax was toppled! Extraordinary tactics!",
						"team_pokemon_names": ["Snorlax"]
					},
					{
						"stage_num": 4,
						"trainer_title": "Luchador",
						"trainer_name": "Luchador Bruno",
						"intro": "Blazing fists and relentless aggression! Machoke and Primeape, unleash cross chops!",
						"outro": "Knocked out! Your strength is undisputed!",
						"team_pokemon_names": ["Machoke", "Primeape"]
					},
					{
						"stage_num": 5,
						"trainer_title": "Líder Blaine",
						"trainer_name": "Líder Blaine",
						"is_boss": true,
						"badge_name": "Volcano Badge",
						"intro": "Hah! I am Blaine, the hot-headed quiz master! You better have Burn Heal ready! Growlithe, Rapidash, and the scorching fire of Arcanine will reduce your chances to ashes!",
						"outro": "I have burned down to a crisp! You have truly extinguished my blazing spirit! Take the Volcano Badge!",
						"team_pokemon_names": ["Growlithe", "Rapidash", "Arcanine"]
					}
				]
			}
		}
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

var _loc_sync_accum: float = 0.0

# ==============================================================================
# GLOBAL DRAG-TO-SCROLL & TOUCH GESTURE SYSTEM
# ==============================================================================
var _drag_scroll_active: bool = false
var _drag_scroll_container: ScrollContainer = null
var _drag_inertia_container: ScrollContainer = null
var _drag_start_pos: Vector2 = Vector2.ZERO
var _drag_start_scroll_v: int = 0
var _drag_start_scroll_h: int = 0
var _drag_has_moved: bool = false
var _drag_just_finished_ticks: int = 0
var _drag_velocity: Vector2 = Vector2.ZERO
var _drag_last_pos: Vector2 = Vector2.ZERO
var _drag_last_time: int = 0
const DRAG_SCROLL_THRESHOLD: float = 8.0 # Pixels before initiating drag scroll

func is_drag_scrolling() -> bool:
	if _drag_has_moved:
		return true
	if _drag_just_finished_ticks > 0 and (Time.get_ticks_msec() - _drag_just_finished_ticks < 180):
		return true
	return false

func find_scroll_container_at_pos(pos: Vector2) -> ScrollContainer:
	var root = get_tree().root
	if not root:
		return null
	return _search_scroll_container_recursive(root, pos)

func _search_scroll_container_recursive(node: Node, pos: Vector2) -> ScrollContainer:
	if node is CanvasItem and not (node as CanvasItem).is_visible_in_tree():
		return null
	var child_count = node.get_child_count()
	for i in range(child_count - 1, -1, -1):
		var child = node.get_child(i)
		var res = _search_scroll_container_recursive(child, pos)
		if res != null:
			return res
	if node is ScrollContainer:
		var sc = node as ScrollContainer
		if sc.get_global_rect().has_point(pos):
			return sc
	return null

func _input(event: InputEvent) -> void:
	var is_down = false
	var is_up = false
	var pos = Vector2.ZERO
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		is_down = event.pressed
		is_up = not event.pressed
		pos = event.position
	elif event is InputEventScreenTouch:
		is_down = event.pressed
		is_up = not event.pressed
		pos = event.position
		
	if is_down:
		_drag_velocity = Vector2.ZERO
		var sc = find_scroll_container_at_pos(pos)
		if sc and sc.is_visible_in_tree():
			_drag_scroll_active = true
			_drag_scroll_container = sc
			_drag_start_pos = pos
			_drag_start_scroll_v = sc.scroll_vertical
			_drag_start_scroll_h = sc.scroll_horizontal
			_drag_has_moved = false
			_drag_last_pos = pos
			_drag_last_time = Time.get_ticks_msec()
	elif is_up:
		if _drag_scroll_active:
			if _drag_has_moved:
				_drag_just_finished_ticks = Time.get_ticks_msec()
				var elapsed = Time.get_ticks_msec() - _drag_last_time
				if elapsed < 120 and _drag_velocity.length() > 60.0:
					_drag_inertia_container = _drag_scroll_container
				else:
					_drag_velocity = Vector2.ZERO
				get_viewport().set_input_as_handled()
			_drag_scroll_active = false
			_drag_scroll_container = null
			_drag_has_moved = false

	elif event is InputEventMouseMotion or event is InputEventScreenDrag:
		var m_pos = event.position
		if _drag_scroll_active and is_instance_valid(_drag_scroll_container) and _drag_scroll_container.is_visible_in_tree():
			var diff = m_pos - _drag_start_pos
			if not _drag_has_moved:
				if diff.length() >= DRAG_SCROLL_THRESHOLD:
					_drag_has_moved = true
			if _drag_has_moved:
				var now = Time.get_ticks_msec()
				var dt = float(now - _drag_last_time) / 1000.0
				if dt > 0.005:
					_drag_velocity = (m_pos - _drag_last_pos) / dt
					_drag_last_pos = m_pos
					_drag_last_time = now
				
				if _drag_scroll_container.vertical_scroll_mode != ScrollContainer.SCROLL_MODE_DISABLED:
					_drag_scroll_container.scroll_vertical = _drag_start_scroll_v - int(diff.y)
				if _drag_scroll_container.horizontal_scroll_mode != ScrollContainer.SCROLL_MODE_DISABLED:
					_drag_scroll_container.scroll_horizontal = _drag_start_scroll_h - int(diff.x)
				get_viewport().set_input_as_handled()

func _ready() -> void:
	_setup_global_font_fallbacks()
	if OS.has_feature("mobile") or OS.has_feature("android") or OS.has_feature("ios"):
		DisplayServer.screen_set_orientation(DisplayServer.SCREEN_PORTRAIT)
	load_types_from_csv()
	load_moves_from_csv()
	load_pokemon_from_csv()
	load_profile()
	var tree = get_tree()
	if tree and not tree.node_added.is_connected(_on_scene_node_added):
		tree.node_added.connect(_on_scene_node_added)
	if settings_language == "es":
		call_deferred("apply_language_to_scene_tree")

func _process(delta: float) -> void:
	if settings_language == "es":
		_loc_sync_accum += delta
		if _loc_sync_accum >= 0.12:
			_loc_sync_accum = 0.0
			apply_language_to_scene_tree()

	# Inercia y deslizamiento cinetico suave al soltar el arrastre
	if not _drag_scroll_active and _drag_velocity.length_squared() > 100.0:
		if is_instance_valid(_drag_inertia_container) and _drag_inertia_container.is_visible_in_tree():
			if _drag_inertia_container.vertical_scroll_mode != ScrollContainer.SCROLL_MODE_DISABLED:
				_drag_inertia_container.scroll_vertical -= int(_drag_velocity.y * delta)
			if _drag_inertia_container.horizontal_scroll_mode != ScrollContainer.SCROLL_MODE_DISABLED:
				_drag_inertia_container.scroll_horizontal -= int(_drag_velocity.x * delta)
			_drag_velocity = _drag_velocity.move_toward(Vector2.ZERO, 3500.0 * delta)
		else:
			_drag_velocity = Vector2.ZERO
	else:
		_drag_velocity = Vector2.ZERO

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
		if m_boost_cost == 0:
			var desc_low = m_desc.to_lower()
			if "use 1 extra energy" in desc_low:
				m_boost_cost = 1
			elif "use 2 extra energy" in desc_low:
				m_boost_cost = 2
		
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
		var raw_m1_val = get_val.call("move1", "")
		# Omitir filas de plantilla (Gen 2-4) que aún no tienen estadísticas ni movimientos configurados
		if raw_hp_val == "" or raw_m1_val == "":
			continue
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
		var p_evolves_from = get_val.call("evolves_from", "").strip_edges()
		var p_evolves_to = get_val.call("evolves_to", "").strip_edges()
		var p_required_stone = get_val.call("required_stone", "").strip_edges()
		var raw_req_exp = get_val.call("required_exp", "")
		if raw_req_exp == "":
			raw_req_exp = get_val.call("required exp", "")
		if raw_req_exp == "":
			raw_req_exp = get_val.call("req_exp", "")
		var p_required_exp = int(raw_req_exp) if raw_req_exp != "" else 0

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

		var p_region = get_val.call("region", "Kanto").strip_edges()
		if p_region == "":
			p_region = "Kanto"

		var raw_dict = {
			"id": pkmn_id,
			"pokedex_num": p_num,
			"stage": p_stage,
			"csv_stage": p_stage,
			"rarity": p_rarity,
			"tier": p_tier,
			"region": p_region,
			"evolves_from": p_evolves_from,
			"evolves_to": p_evolves_to,
			"required_stone": p_required_stone,
			"required_exp": p_required_exp,
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
	# Si algún Pokémon tiene evolves_from hacia una pre-evolución aún no implementada en pokemon_catalog,
	# tratar su stage jugable como Basic hasta que su pre-evolución tenga estadísticas.
	for id in all_pokemon_ids:
		var entry = pokemon_catalog[id]
		var ef = str(entry.get("evolves_from", "")).strip_edges()
		if ef != "" and get_pokemon_id_by_name(ef) == -1 and str(entry.get("stage", "")).strip_edges().to_lower() == "stage 1":
			entry["stage"] = "Basic"
	# Resolver required_exp automático si algún Pokémon nuevo tiene evolves_to pero required_exp vacío/0
	for id in all_pokemon_ids:
		pokemon_catalog[id]["required_exp"] = get_pokemon_required_exp(id)
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
	if clean == "ryhorn":
		clean = "rhyhorn"
	if clean == "diglett":
		clean = "digglet"
	if clean == "electrivire":
		clean = "electivire"
	if clean == "mime jr":
		clean = "mime jr."
	if clean == "mr mime":
		clean = "mr. mime"
	for id in all_pokemon_ids:
		var d = pokemon_catalog.get(id, {})
		if str(d.get("name", "")).strip_edges().to_lower() == clean:
			return int(id)
	return -1

func normalize_stone_type(stone_raw: String) -> String:
	var c = stone_raw.strip_edges().to_lower()
	c = c.replace("stone_", "").replace("_stone", "").replace(" stone", "").strip_edges()
	for st in EVOLUTION_STONE_TYPES:
		if st.to_lower() == c:
			return st
	if c == "electric":
		return "Thunder"
	elif c == "grass":
		return "Leaf"
	elif c == "psychic":
		return "Psyche"
	elif c == "dark":
		return "Night"
	elif c == "fighting":
		return "Punch"
	elif c == "normal":
		return "Heart"
	return stone_raw.strip_edges().capitalize() if stone_raw.strip_edges() != "" else "Heart"

func get_stone_inventory_key(stone_type: String) -> String:
	return "stone_" + normalize_stone_type(stone_type).to_lower()

func get_stone_display_name(stone_type: String) -> String:
	var norm = normalize_stone_type(stone_type)
	return "%s Stone" % norm

func get_required_stone_count_for_stage(from_stage: String, to_stage: String = "") -> int:
	var fs = from_stage.strip_edges().to_lower()
	var ts = to_stage.strip_edges().to_lower()
	if fs == "stage 1" or ts == "stage 2":
		return 2
	return 1

func get_evolution_options(pkmn_id: int, only_implemented: bool = true) -> Array[Dictionary]:
	var options: Array[Dictionary] = []
	if not pokemon_catalog.has(pkmn_id):
		return options
	var d = pokemon_catalog[pkmn_id]
	var evo_raw = str(d.get("evolves_to", "")).strip_edges()
	if evo_raw == "":
		return options
	var stone_raw = str(d.get("required_stone", "")).strip_edges()
	var evo_parts = evo_raw.split(",")
	var stone_parts = stone_raw.split(",") if stone_raw != "" else PackedStringArray()
	var from_stage = str(d.get("stage", "Basic")).strip_edges()
	var req_exp = get_pokemon_required_exp(pkmn_id)

	for i in range(evo_parts.size()):
		var t_name = evo_parts[i].strip_edges()
		if t_name == "":
			continue
		var s_part = "Heart"
		if i < stone_parts.size() and stone_parts[i].strip_edges() != "":
			s_part = stone_parts[i].strip_edges()
		elif stone_parts.size() > 0 and stone_parts[0].strip_edges() != "":
			s_part = stone_parts[0].strip_edges()
		var s_type = normalize_stone_type(s_part)
		var t_id = get_pokemon_id_by_name(t_name)
		if only_implemented and t_id == -1:
			continue
		var t_data = pokemon_catalog.get(t_id, {}) if t_id != -1 else {}
		var to_stage = str(t_data.get("stage", "Stage 2" if from_stage.to_lower() == "stage 1" else "Stage 1"))
		var s_count = get_required_stone_count_for_stage(from_stage, to_stage)
		var s_key = get_stone_inventory_key(s_type)
		var unlocked = is_pokemon_unlocked(t_id) if t_id != -1 else false
		options.append({
			"from_id": pkmn_id,
			"from_name": str(d.get("name", "")),
			"from_stage": from_stage,
			"to_id": t_id,
			"to_name": str(t_data.get("name", t_name)),
			"to_stage": to_stage,
			"stone_type": s_type,
			"stone_key": s_key,
			"stone_name": get_stone_display_name(s_type),
			"stone_count": s_count,
			"required_exp": req_exp,
			"is_unlocked": unlocked,
			"is_implemented": (t_id != -1)
		})
	return options

func get_evolution_target_id(current_id: int) -> int:
	if not pokemon_catalog.has(current_id):
		return -1
	var d = pokemon_catalog[current_id]
	var evo_name = str(d.get("evolves_to", "")).strip_edges()
	if evo_name == "":
		return -1
	if "," in evo_name:
		var parts = evo_name.split(",")
		var first_valid = -1
		for part in parts:
			var tid = get_pokemon_id_by_name(part.strip_edges())
			if tid != -1:
				if first_valid == -1:
					first_valid = tid
				if is_pokemon_unlocked(tid):
					return tid
		return first_valid
	return get_pokemon_id_by_name(evo_name)

func get_pokemon_required_exp(pkmn_id: int) -> int:
	if not pokemon_catalog.has(pkmn_id):
		return 0
	var d = pokemon_catalog[pkmn_id]
	var evo_name = str(d.get("evolves_to", "")).strip_edges()
	if evo_name == "":
		return 0
	var csv_req = int(d.get("required_exp", 0))
	if csv_req > 0:
		return csv_req
	var st = str(d.get("stage", "Basic")).strip_edges().to_lower()
	if st == "basic":
		var target1_id = get_evolution_target_id(pkmn_id)
		var target2_id = get_evolution_target_id(target1_id) if target1_id != -1 else -1
		return 10 if target2_id != -1 else 20
	elif st == "stage 1":
		return 25
	return 0

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

const BOOSTER_PACKS: Dictionary = {
	"kanto": {
		"id": "kanto",
		"name": "Kanto Booster Pack",
		"region": "Kanto",
		"cost": 5,
		"accent_color": Color("#FFD700"),
		"texture_path": "res://assets/Kanto Booster Pack.PNG",
		"fallback_texture": "res://assets/kanto_booster_pack.png",
		"desc": "Discover the original 151 Pokémon from the Kanto region! Classic Starters, powerful Gym favorites, and the Legendary Birds."
	},
	"johto": {
		"id": "johto",
		"name": "Johto Booster Pack",
		"region": "Johto",
		"cost": 5,
		"accent_color": Color("#4FC3F7"),
		"texture_path": "res://assets/Johto Booster Pack.jpg",
		"fallback_texture": "res://assets/Johto Booster Pack.jpg",
		"desc": "Journey through the Johto region! Collect 100 new species, Baby Pokémon, and the Legendary Beasts."
	},
	"hoenn": {
		"id": "hoenn",
		"name": "Hoenn Booster Pack",
		"region": "Hoenn",
		"cost": 5,
		"accent_color": Color("#FF7043"),
		"texture_path": "res://assets/Hoenn Booster Pack.jpg",
		"fallback_texture": "res://assets/Hoenn Booster Pack.jpg",
		"desc": "Venture into the Hoenn region! Ancient weather legends, diverse environments, and heroic Pokémon."
	},
	"sinnoh": {
		"id": "sinnoh",
		"name": "Sinnoh Booster Pack",
		"region": "Sinnoh",
		"cost": 5,
		"accent_color": Color("#BA68C8"),
		"texture_path": "res://assets/Sinnoh Booster Pack.jpg",
		"fallback_texture": "res://assets/Sinnoh Booster Pack.jpg",
		"desc": "Explore the Sinnoh region! Master cross-generational evolutions and mythic space-time Pokémon."
	}
}

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

func recycle_all_copies_of_card(pkmn_id: int) -> Dictionary:
	var current = get_card_stock(pkmn_id)
	if current <= 1:
		return { "recycled_count": 0, "candies_earned": 0 }
	var excess = current - 1
	var cat = pokemon_catalog.get(pkmn_id, {})
	var val = get_recycle_candy_value(str(cat.get("rarity", "Common")))
	var total_candies = excess * val
	player_card_stocks[pkmn_id] = 1
	player_rare_candies += total_candies
	card_stocks_changed.emit()
	add_daily_mission_progress("recycle_cards", excess)
	save_profile()
	return {
		"recycled_count": excess,
		"candies_earned": total_candies
	}

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
		"title": "Campaign Victory",
		"desc": "Win 2 Battles in Campaign (Adventure or Tournament)",
		"type": "win_battles",
		"target": 2,
		"reward_diamonds": 6
	},
	{
		"id": "clear_stage",
		"icon": "🗺️",
		"title": "Frontier Explorer",
		"desc": "Clear 2 Stages in Campaign Adventure",
		"type": "clear_stage",
		"target": 2,
		"reward_diamonds": 7
	},
	{
		"id": "defeat_pokemon",
		"icon": "🥊",
		"title": "Rival Crusher",
		"desc": "Knock out 5 rival Pokémon in Campaign",
		"type": "defeat_pokemon",
		"target": 5,
		"reward_diamonds": 6
	},
	{
		"id": "defeat_gym",
		"icon": "🏆",
		"title": "Tournament Contender",
		"desc": "Defeat 2 Trainers in Campaign Tournament",
		"type": "defeat_gym",
		"target": 2,
		"reward_diamonds": 7
	},
	{
		"id": "super_effective",
		"icon": "💥",
		"title": "Type Mastery",
		"desc": "Land 4 Super Effective attacks in Campaign",
		"type": "super_effective",
		"target": 4,
		"reward_diamonds": 6
	},
	{
		"id": "play_moves",
		"icon": "🎯",
		"title": "Combat Tactics",
		"desc": "Execute 8 Moves in Campaign Battles",
		"type": "play_moves",
		"target": 8,
		"reward_diamonds": 5
	},
	{
		"id": "recharge_energy",
		"icon": "⚡",
		"title": "Energy Surge",
		"desc": "Recharge Energy 4 times in Campaign Battles",
		"type": "recharge_energy",
		"target": 4,
		"reward_diamonds": 5
	},
	{
		"id": "switch_pkmn",
		"icon": "🔄",
		"title": "Tactical Rotation",
		"desc": "Switch Pokémon from Bench 3 times in Campaign",
		"type": "switch_pkmn",
		"target": 3,
		"reward_diamonds": 5
	},
	{
		"id": "heal_hp",
		"icon": "🩹",
		"title": "Combat Recovery",
		"desc": "Recover HP 3 times in Campaign (Moves, Potions or Camp)",
		"type": "heal_hp",
		"target": 3,
		"reward_diamonds": 6
	},
	{
		"id": "use_camp_items",
		"icon": "🎒",
		"title": "Field Support",
		"desc": "Use 2 Items in Campaign (Bag or Camp)",
		"type": "use_camp_items",
		"target": 2,
		"reward_diamonds": 5
	},
	{
		"id": "buy_camp_shop",
		"icon": "🏪",
		"title": "Camp Provisioner",
		"desc": "Purchase 2 Items from the Camp Shop",
		"type": "buy_camp_shop",
		"target": 2,
		"reward_diamonds": 5
	},
	{
		"id": "earn_gold",
		"icon": "💰",
		"title": "Bounty Hunter",
		"desc": "Earn 150 Gold in Campaign Combat",
		"type": "earn_gold",
		"target": 150,
		"reward_diamonds": 6
	},
	{
		"id": "camp_evolution",
		"icon": "🌟",
		"title": "Camp Evolution",
		"desc": "Evolve 1 Pokémon in Camp during a Campaign run",
		"type": "camp_evolution",
		"target": 1,
		"reward_diamonds": 8
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
		
	# 2. Misiones Diarias (100% exclusivas de Campaña)
	var has_legacy_mission = false
	for m in daily_missions:
		var m_id = m.get("id", "")
		var found = false
		for p in DAILY_MISSION_POOL:
			if p["id"] == m_id:
				found = true
				break
		if not found:
			has_legacy_mission = true
			break
			
	if daily_missions_date != today or daily_missions.is_empty() or has_legacy_mission:
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
	elif r in ["showcase", "holo_common", "subtle"]:
		var mat = ShaderMaterial.new()
		mat.shader = s
		mat.set_shader_parameter("foil_style", 0) # Estilo plateado / prisma sutil
		mat.set_shader_parameter("foil_color_1", Color("#E0F7FA", 0.60))
		mat.set_shader_parameter("foil_color_2", Color("#FFFFFF", 0.45))
		mat.set_shader_parameter("sheen_width", 0.18)
		mat.set_shader_parameter("rainbow_mix", 0.20)
		mat.set_shader_parameter("sparkle_strength", 0.20)
		mat.set_shader_parameter("ambient_foil", 0.05)
		mat.set_shader_parameter("intensity", 0.70)
		mat.set_shader_parameter("shimmer_speed", 0.85)
		return mat
		
	return null

func apply_foil_overlay(target_node: Control, rarity_str: String, force_showcase_foil: bool = false) -> ColorRect:
	if not target_node:
		return null
		
	var existing: ColorRect = target_node.get_node_or_null("FoilOverlay") as ColorRect
	
	# Common and Uncommon cards NEVER have holographic foil
	var r_clean = rarity_str.strip_edges().to_lower()
	if r_clean in ["common", "uncommon"] and not force_showcase_foil:
		if existing:
			existing.visible = false
		return null
		
	var mat = create_card_foil_material(rarity_str)
	if not mat and force_showcase_foil:
		mat = create_card_foil_material("showcase")
	
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

var booster_pack_foil_shader: Shader = null

func get_booster_pack_foil_shader() -> Shader:
	if not booster_pack_foil_shader:
		if ResourceLoader.exists("res://assets/shaders/booster_pack_foil.gdshader"):
			booster_pack_foil_shader = load("res://assets/shaders/booster_pack_foil.gdshader")
	return booster_pack_foil_shader

func apply_booster_pack_foil_overlay(target_node: Control, region_color: Color) -> ColorRect:
	if not target_node:
		return null
	var s = get_booster_pack_foil_shader()
	if not s:
		return null
		
	var existing: ColorRect = target_node.get_node_or_null("PackFoilOverlay") as ColorRect
	var overlay: ColorRect = existing
	if not overlay:
		overlay = ColorRect.new()
		overlay.name = "PackFoilOverlay"
		overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
		overlay.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		overlay.size_flags_vertical = Control.SIZE_EXPAND_FILL
		overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		target_node.add_child(overlay)
		
	var mat = ShaderMaterial.new()
	mat.shader = s
	mat.set_shader_parameter("foil_tint", Color(region_color.r, region_color.g, region_color.b, 0.55))
	mat.set_shader_parameter("shimmer_speed", 0.85)
	mat.set_shader_parameter("holographic_intensity", 1.0)
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
	var candidates: Array[String] = []
	if clean_fn.ends_with(".mp3") or clean_fn.ends_with(".wav") or clean_fn.ends_with(".ogg"):
		candidates.append(clean_fn)
	else:
		candidates.append(clean_fn + ".mp3")
		candidates.append(clean_fn + ".wav")
		candidates.append(clean_fn + ".ogg")
		
	for c_fn in candidates:
		if sfx_audio_cache.has(c_fn):
			return sfx_audio_cache[c_fn]
			
		var paths = [
			"res://assets/sfx/" + c_fn,
			"res://assets/sfx/moves/" + c_fn,
			SFX_FOLDER_PATH + c_fn,
			"D:/Games/Pokemon Battle Frontier/SFX/" + c_fn
		]
		
		for p in paths:
			if p.begins_with("res://") and ResourceLoader.exists(p):
				var res_stream = load(p) as AudioStream
				if res_stream:
					sfx_audio_cache[c_fn] = res_stream
					return res_stream
			elif FileAccess.file_exists(p):
				if c_fn.ends_with(".mp3"):
					var f = FileAccess.open(p, FileAccess.READ)
					if f:
						var buf = f.get_buffer(f.get_length())
						f.close()
						var stream = AudioStreamMP3.new()
						stream.data = buf
						sfx_audio_cache[c_fn] = stream
						return stream
				elif c_fn.ends_with(".ogg"):
					var stream = AudioStreamOggVorbis.load_from_file(p)
					if stream:
						sfx_audio_cache[c_fn] = stream
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
		"power_up", "power up", "recharge": filename = "power up.wav"
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

func open_booster_pack(pack_type: String = "kanto", cost_diamonds: int = 0) -> Array[Dictionary]:
	if player_diamonds < cost_diamonds:
		return []
		
	player_diamonds -= cost_diamonds
	var result: Array[Dictionary] = []
	if all_pokemon_ids.is_empty():
		return result
		
	var target_region = ""
	var key = pack_type.to_lower().strip_edges()
	if BOOSTER_PACKS.has(key):
		target_region = BOOSTER_PACKS[key].get("region", "")
	else:
		for pid in BOOSTER_PACKS:
			if BOOSTER_PACKS[pid].get("region", "").to_lower() == key:
				target_region = BOOSTER_PACKS[pid].get("region", "")
				break
		if target_region == "":
			target_region = pack_type

	var candidate_ids: Array[int] = []
	if target_region != "":
		for id in all_pokemon_ids:
			var d = pokemon_catalog.get(id, {})
			if str(d.get("region", "")).to_lower() == target_region.to_lower():
				candidate_ids.append(id)
				
	if candidate_ids.size() < 3:
		candidate_ids = all_pokemon_ids.duplicate()
		
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
	p.region = d.get("region", "Kanto")
	p.evolves_from = d.get("evolves_from", "")
	p.evolves_to = d.get("evolves_to", "")
	p.required_stone = d.get("required_stone", "")
	p.required_exp = get_pokemon_required_exp(pkmn_id)
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
	var had_camp_flute = campaign_inventory.get("poke_flute", 0)
	campaign_inventory = DEFAULT_INVENTORY.duplicate()
	if had_camp_flute > 0:
		campaign_inventory["poke_flute"] = had_camp_flute
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
					"max_exp": inst.get_required_exp(),
					"burn_turns": 0,
					"is_poisoned": false,
					"is_flinched": false
				})
	campaign_match_number = 1
	var had_camp_flute_init = campaign_inventory.get("poke_flute", 0)
	campaign_inventory = DEFAULT_INVENTORY.duplicate()
	if had_camp_flute_init > 0:
		campaign_inventory["poke_flute"] = had_camp_flute_init
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
					"max_exp": inst.get_required_exp(),
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
	var had_adv_flute = adventure_inventory.get("poke_flute", 0)
	adventure_inventory = DEFAULT_INVENTORY.duplicate()
	if had_adv_flute > 0 or ("pokemon_tower" in adventure_ep5_cleared_routes):
		adventure_inventory["poke_flute"] = 1
	adventure_player_team_state.clear()

func init_adventure_team(episode_id: int, chosen_ids: Array) -> void:
	adventure_current_episode = episode_id
	adventure_current_stage = 1
	var had_adv_flute_init = adventure_inventory.get("poke_flute", 0)
	adventure_inventory = DEFAULT_INVENTORY.duplicate()
	if had_adv_flute_init > 0 or ("pokemon_tower" in adventure_ep5_cleared_routes):
		adventure_inventory["poke_flute"] = 1
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
					"max_exp": inst.get_required_exp(),
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
					"max_exp": inst.get_required_exp(),
					"burn_turns": burn_val,
					"is_poisoned": poison_val,
					"is_flinched": flinch_val
				})

func get_adventure_episode_info(episode_id: int) -> Dictionary:
	return ADVENTURE_EPISODES.get(episode_id, {})

func get_adventure_route_info(episode_id: int, route_id: String) -> Dictionary:
	var ep = ADVENTURE_EPISODES.get(episode_id, {})
	if ep.get("is_branching", false):
		var routes = ep.get("routes", {})
		return routes.get(route_id, {})
	return {}

func is_adventure_ep5_route_unlocked(route_id: String) -> bool:
	if not is_adventure_episode_unlocked(5):
		return false
	if route_id == "rocket_hideout":
		return true
	if route_id in ["pokemon_tower", "fuchsia_gym"]:
		return "rocket_hideout" in adventure_ep5_cleared_routes
	return false

func is_adventure_ep5_route_completed(route_id: String) -> bool:
	return route_id in adventure_ep5_cleared_routes

func is_adventure_ep6_route_unlocked(route_id: String) -> bool:
	if not is_adventure_episode_unlocked(6):
		return false
	if route_id == "silph_co":
		return true
	if route_id in ["saffron_gym", "fighting_dojo"]:
		return "silph_co" in adventure_ep6_cleared_routes
	return false

func is_adventure_ep6_route_completed(route_id: String) -> bool:
	return route_id in adventure_ep6_cleared_routes

func is_adventure_ep7_route_unlocked(route_id: String) -> bool:
	if not is_adventure_episode_unlocked(7):
		return false
	if route_id == "pokemon_mansion":
		return true
	if route_id == "blaine_gym":
		return "pokemon_mansion" in adventure_ep7_cleared_routes
	return false

func is_adventure_ep7_route_completed(route_id: String) -> bool:
	return route_id in adventure_ep7_cleared_routes

func get_adventure_selected_route(episode_id: int) -> String:
	if episode_id == 5:
		return adventure_ep5_selected_route
	elif episode_id == 6:
		return adventure_ep6_selected_route
	elif episode_id == 7:
		return adventure_ep7_selected_route
	return ""

func get_adventure_total_stages(episode_id: int) -> int:
	var ep = ADVENTURE_EPISODES.get(episode_id, {})
	if ep.get("is_branching", false):
		var routes = ep.get("routes", {})
		var r_id = get_adventure_selected_route(episode_id)
		var r_data = routes.get(r_id, {})
		var stages = r_data.get("stages", [])
		return stages.size()
	var stages = ep.get("stages", [])
	return stages.size()

func get_adventure_stage_info(episode_id: int, stage_num: int) -> Dictionary:
	var ep = ADVENTURE_EPISODES.get(episode_id, {})
	var stages = []
	if ep.get("is_branching", false):
		var routes = ep.get("routes", {})
		var r_id = get_adventure_selected_route(episode_id)
		var r_data = routes.get(r_id, {})
		stages = r_data.get("stages", [])
	else:
		stages = ep.get("stages", [])
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

func is_tutorial_completed() -> bool:
	return tutorial_completed

func is_adventure_episode_unlocked(episode_id: int) -> bool:
	if episode_id == 1:
		return tutorial_completed
	return (episode_id in adventure_unlocked_episodes) and tutorial_completed

func is_adventure_episode_completed(episode_id: int) -> bool:
	return episode_id in adventure_completed_episodes

func complete_adventure_episode(episode_id: int) -> int:
	# Returns diamonds awarded
	var bonus = 0
	if episode_id == 5:
		var cur_route = adventure_ep5_selected_route
		if not (cur_route in adventure_ep5_cleared_routes):
			adventure_ep5_cleared_routes.append(cur_route)
			if cur_route == "rocket_hideout":
				bonus = 20
				player_diamonds += bonus
			elif cur_route == "pokemon_tower":
				bonus = 15
				player_diamonds += bonus
				adventure_inventory["poke_flute"] = 1
			elif cur_route == "fuchsia_gym":
				bonus = 15
				player_diamonds += bonus
				if not (6 in adventure_unlocked_episodes):
					adventure_unlocked_episodes.append(6)
				if not (5 in adventure_completed_episodes):
					adventure_completed_episodes.append(5)
		save_profile()
		return bonus

	if episode_id == 6:
		var cur_route = adventure_ep6_selected_route
		if not (cur_route in adventure_ep6_cleared_routes):
			adventure_ep6_cleared_routes.append(cur_route)
			if cur_route == "silph_co":
				bonus = 20
				player_diamonds += bonus
			elif cur_route == "fighting_dojo":
				bonus = 20
				player_diamonds += bonus
				add_card_copy(111) # Hitmonlee
				add_card_copy(112) # Hitmonchan
			elif cur_route == "saffron_gym":
				bonus = 20
				player_diamonds += bonus
				if not (7 in adventure_unlocked_episodes):
					adventure_unlocked_episodes.append(7)
				if not (6 in adventure_completed_episodes):
					adventure_completed_episodes.append(6)
		save_profile()
		return bonus

	if episode_id == 7:
		var cur_route = adventure_ep7_selected_route
		if not (cur_route in adventure_ep7_cleared_routes):
			adventure_ep7_cleared_routes.append(cur_route)
			if cur_route == "pokemon_mansion":
				bonus = 35
				player_diamonds += bonus
			elif cur_route == "blaine_gym":
				bonus = 35
				player_diamonds += bonus
				if not (7 in adventure_completed_episodes):
					adventure_completed_episodes.append(7)
		save_profile()
		return bonus

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
		var cur_hp = int(p.get("current_hp", 0))
		# Si está KO (current_hp <= 0), no evoluciona hasta que se le use un Revive!
		if cur_hp <= 0:
			continue
			
		var current_id = int(p["id"])
		var req_exp = get_pokemon_required_exp(current_id)
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
					p["current_hp"] = new_max # Evolucionar en el campamento cura por completo al Pokémon
					p["current_exp"] = 0 # El siguiente stage llega con 0 EXP
					p["max_exp"] = target_inst.get_required_exp()
					p["burn_turns"] = 0
					p["is_poisoned"] = false
					p["is_flinched"] = false
					
					evolutions_occurred.append({
						"index": i,
						"from_name": from_name,
						"to_name": to_name,
						"from_id": current_id,
						"to_id": target_id,
						"from_texture": p.get("texture_path", ""),
						"to_texture": target_inst.texture_path,
						"old_hp": cur_hp,
						"new_max_hp": new_max,
						"hp_healed": max(1, new_max - cur_hp),
						"new_stage": target_inst.stage
					})
			else:
				# No evoluciona porque falta tener la carta conseguida
				p["current_exp"] = min(cur_exp, req_exp)
	if not evolutions_occurred.is_empty():
		save_profile()
	return evolutions_occurred

func get_pending_campaign_evolutions() -> Array[Dictionary]:
	var pending: Array[Dictionary] = []
	var team_state = get_active_campaign_team_state()
	for i in range(team_state.size()):
		var p = team_state[i]
		var cur_hp = int(p.get("current_hp", 0))
		# Si está KO (current_hp <= 0), no evoluciona hasta que se le use un Revive!
		if cur_hp <= 0:
			continue
		var current_id = int(p["id"])
		var req_exp = get_pokemon_required_exp(current_id)
		var cur_exp = int(p.get("current_exp", 0))
		if req_exp > 0 and cur_exp >= req_exp:
			var target_id = get_evolution_target_id(current_id)
			if target_id != -1 and is_pokemon_unlocked(target_id):
				var target_inst = create_pokemon_instance(target_id)
				if target_inst:
					pending.append({
						"index": i,
						"from_name": p["name"],
						"to_name": target_inst.name,
						"from_id": current_id,
						"to_id": target_id,
						"from_texture": p.get("texture_path", ""),
						"to_texture": target_inst.texture_path,
						"old_hp": cur_hp,
						"new_max_hp": target_inst.max_hp,
						"hp_healed": max(1, target_inst.max_hp - cur_hp),
						"new_stage": target_inst.stage
					})
	return pending

func apply_single_campaign_evolution(evo: Dictionary) -> void:
	var team_state = get_active_campaign_team_state()
	var idx = int(evo.get("index", -1))
	if idx < 0 or idx >= team_state.size():
		return
	var p = team_state[idx]
	var target_id = int(evo.get("to_id", -1))
	if target_id == -1:
		return
	var target_inst = create_pokemon_instance(target_id)
	if not target_inst:
		return
	p["id"] = target_id
	p["name"] = target_inst.name
	p["stage"] = target_inst.stage
	p["type"] = target_inst.type
	p["speed"] = target_inst.speed
	p["texture_path"] = target_inst.texture_path
	p["max_hp"] = target_inst.max_hp
	p["current_hp"] = target_inst.max_hp
	p["current_exp"] = 0
	p["max_exp"] = target_inst.get_required_exp()
	p["burn_turns"] = 0
	p["is_poisoned"] = false
	p["is_flinched"] = false
	save_profile()

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
	if cur_gold >= ITEM_COST_POTION:
		set_active_campaign_gold(cur_gold - ITEM_COST_POTION)
		inv["potion"] = inv.get("potion", 0) + 1
		return true
	return false

func buy_campaign_revive() -> bool:
	var cur_gold = get_active_campaign_gold()
	var inv = get_active_campaign_inventory()
	if cur_gold >= ITEM_COST_REVIVE:
		set_active_campaign_gold(cur_gold - ITEM_COST_REVIVE)
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
	if cur_gold >= ITEM_COST_REMEDY:
		set_active_campaign_gold(cur_gold - ITEM_COST_REMEDY)
		inv["remedy"] = inv.get("remedy", 0) + 1
		return true
	return false

func buy_campaign_ether() -> bool:
	var cur_gold = get_active_campaign_gold()
	var inv = get_active_campaign_inventory()
	if cur_gold >= ITEM_COST_ETHER:
		set_active_campaign_gold(cur_gold - ITEM_COST_ETHER)
		inv["ether"] = inv.get("ether", 0) + 1
		return true
	return false

func use_super_potion_on_campaign_pkmn(index: int) -> bool:
	var inv = get_active_campaign_inventory()
	var team_state = get_active_campaign_team_state()
	if inv.get("super_potion", 0) <= 0:
		return false
	if index < 0 or index >= team_state.size():
		return false
	var p_data = team_state[index]
	if p_data["current_hp"] <= 0:
		return false # No cura si está KO, requiere Revive
	if p_data["current_hp"] >= p_data["max_hp"]:
		return false # Ya está al máximo
	p_data["current_hp"] = min(p_data["max_hp"], p_data["current_hp"] + 25)
	inv["super_potion"] -= 1
	save_profile()
	return true

func buy_campaign_super_potion() -> bool:
	var cur_gold = get_active_campaign_gold()
	var inv = get_active_campaign_inventory()
	if cur_gold >= ITEM_COST_SUPER_POTION:
		set_active_campaign_gold(cur_gold - ITEM_COST_SUPER_POTION)
		inv["super_potion"] = inv.get("super_potion", 0) + 1
		save_profile()
		return true
	return false

func use_hyper_potion_on_campaign_pkmn(index: int) -> bool:
	var inv = get_active_campaign_inventory()
	var team_state = get_active_campaign_team_state()
	if inv.get("hyper_potion", 0) <= 0:
		return false
	if index < 0 or index >= team_state.size():
		return false
	var p_data = team_state[index]
	if p_data["current_hp"] <= 0:
		return false # No cura si está KO, requiere Revive
	if p_data["current_hp"] >= p_data["max_hp"]:
		return false # Ya está al máximo
	p_data["current_hp"] = p_data["max_hp"]
	inv["hyper_potion"] -= 1
	save_profile()
	return true

func buy_campaign_hyper_potion() -> bool:
	var cur_gold = get_active_campaign_gold()
	var inv = get_active_campaign_inventory()
	if cur_gold >= ITEM_COST_HYPER_POTION:
		set_active_campaign_gold(cur_gold - ITEM_COST_HYPER_POTION)
		inv["hyper_potion"] = inv.get("hyper_potion", 0) + 1
		save_profile()
		return true
	return false

func use_poke_flute_on_campaign_pkmn(index: int) -> bool:
	var inv = get_active_campaign_inventory()
	var team_state = get_active_campaign_team_state()
	if inv.get("poke_flute", 0) <= 0:
		return false
	if index < 0 or index >= team_state.size():
		return false
	var p_data = team_state[index]
	if p_data["current_hp"] <= 0:
		return false
	if int(p_data.get("is_asleep_turns", 0)) <= 0:
		return false # No está dormido
	p_data["is_asleep_turns"] = 0
	# La Poké Flauta no se consume, permanece en la mochila
	save_profile()
	return true

func buy_campaign_poke_flute() -> bool:
	var cur_gold = get_active_campaign_gold()
	var inv = get_active_campaign_inventory()
	if inv.get("poke_flute", 0) > 0:
		return false # Ya se tiene en posesión (objeto permanente)
	if cur_gold >= ITEM_COST_POKE_FLUTE:
		set_active_campaign_gold(cur_gold - ITEM_COST_POKE_FLUTE)
		inv["poke_flute"] = 1
		save_profile()
		return true
	return false

# --- EVOLUTION STONES & INTERACTIVE CAMP EVOLUTION (VARIANT 1) ---
func get_campaign_stone_count(stone_type: String) -> int:
	var inv = get_active_campaign_inventory()
	var k = get_stone_inventory_key(stone_type)
	return int(inv.get(k, 0))

func add_campaign_stone(stone_type: String, amount: int = 1) -> void:
	var inv = get_active_campaign_inventory()
	var k = get_stone_inventory_key(stone_type)
	inv[k] = max(0, int(inv.get(k, 0)) + amount)

func buy_campaign_stone(stone_type: String) -> bool:
	var cur_gold = get_active_campaign_gold()
	if cur_gold >= ITEM_COST_STONE:
		set_active_campaign_gold(cur_gold - ITEM_COST_STONE)
		add_campaign_stone(stone_type, 1)
		save_profile()
		return true
	return false

func get_team_needed_stones() -> Array[String]:
	var needed: Array[String] = []
	var team = get_active_campaign_team_state()
	for p in team:
		var cid = int(p.get("id", -1))
		var opts = get_evolution_options(cid, true)
		for opt in opts:
			var st = str(opt.get("stone_type", ""))
			if st != "" and not (st in needed):
				needed.append(st)
			var tid = int(opt.get("to_id", -1))
			if tid != -1:
				var next_opts = get_evolution_options(tid, true)
				for nopt in next_opts:
					var nst = str(nopt.get("stone_type", ""))
					if nst != "" and not (nst in needed):
						needed.append(nst)
	return needed

func can_evolve_campaign_pokemon_with_option(team_idx: int, to_id: int = -1) -> Dictionary:
	var team = get_active_campaign_team_state()
	if team_idx < 0 or team_idx >= team.size():
		return {"can_evolve": false, "reason": "Invalid team slot."}
	var p = team[team_idx]
	var cur_hp = int(p.get("current_hp", 0))
	if cur_hp <= 0:
		return {"can_evolve": false, "reason": "Pokémon is KO! Use a Revive first."}
	var cid = int(p.get("id", -1))
	var req_exp = get_pokemon_required_exp(cid)
	var cur_exp = int(p.get("current_exp", 0))
	if req_exp <= 0:
		return {"can_evolve": false, "reason": "This Pokémon is at its final stage."}
	if cur_exp < req_exp:
		return {"can_evolve": false, "reason": "Needs %d/%d EXP to evolve." % [cur_exp, req_exp]}
	var opts = get_evolution_options(cid, true)
	if opts.is_empty():
		return {"can_evolve": false, "reason": "No evolution available."}
	for opt in opts:
		if to_id != -1 and int(opt.get("to_id", -1)) != to_id:
			continue
		if not bool(opt.get("is_unlocked", false)):
			if to_id != -1:
				return {"can_evolve": false, "reason": "Requires %s card unlocked in your collection." % str(opt.get("to_name", "target")), "option": opt}
			continue
		var s_type = str(opt.get("stone_type", "Heart"))
		var s_req = int(opt.get("stone_count", 1))
		var s_owned = get_campaign_stone_count(s_type)
		if s_owned < s_req:
			if to_id != -1:
				return {"can_evolve": false, "reason": "Requires %dx %s (Owned: %d)." % [s_req, str(opt.get("stone_name", "Stone")), s_owned], "option": opt}
			continue
		return {"can_evolve": true, "reason": "Ready to evolve!", "option": opt}
	var first_opt = opts[0]
	if not bool(first_opt.get("is_unlocked", false)):
		return {"can_evolve": false, "reason": "Requires %s card unlocked." % str(first_opt.get("to_name", "target")), "option": first_opt}
	return {"can_evolve": false, "reason": "Requires %dx %s." % [int(first_opt.get("stone_count", 1)), str(first_opt.get("stone_name", "Stone"))], "option": first_opt}

func prepare_campaign_pokemon_evolution_with_option(team_idx: int, to_id: int) -> Dictionary:
	var check = can_evolve_campaign_pokemon_with_option(team_idx, to_id)
	if not bool(check.get("can_evolve", false)):
		return {"success": false, "reason": str(check.get("reason", "Cannot evolve."))}
	var opt: Dictionary = check.get("option", {})
	var team = get_active_campaign_team_state()
	var p = team[team_idx]
	var target_inst = create_pokemon_instance(to_id)
	if not target_inst:
		return {"success": false, "reason": "Target Pokémon not found."}
	var s_type = str(opt.get("stone_type", "Heart"))
	var s_count = int(opt.get("stone_count", 1))
	add_campaign_stone(s_type, -s_count)
	var cur_hp = int(p.get("current_hp", 0))
	var evo_info = {
		"success": true,
		"index": team_idx,
		"from_name": str(p.get("name", "")),
		"to_name": target_inst.name,
		"from_id": int(p.get("id", -1)),
		"to_id": to_id,
		"from_texture": str(p.get("texture_path", "")),
		"to_texture": target_inst.texture_path,
		"old_hp": cur_hp,
		"new_max_hp": target_inst.max_hp,
		"hp_healed": max(1, target_inst.max_hp - cur_hp),
		"new_stage": target_inst.stage,
		"stone_type": s_type,
		"stone_name": str(opt.get("stone_name", "")),
		"stone_count": s_count
	}
	save_profile()
	return evo_info

func evolve_campaign_pokemon_with_option(team_idx: int, to_id: int) -> Dictionary:
	var evo_info = prepare_campaign_pokemon_evolution_with_option(team_idx, to_id)
	if not bool(evo_info.get("success", false)):
		return evo_info
	apply_single_campaign_evolution(evo_info)
	return evo_info

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
	elif clean in ["super_potion", "superpotion", "super potion"]:
		file_name = "Superpotion.png"
	elif clean in ["hyper_potion", "hyperpotion", "hyper potion"]:
		file_name = "Hyperpotion.png"
	elif clean in ["poke_flute", "pokeflute", "poke flute", "poke_flauta", "pokeflauta", "poke flauta"]:
		file_name = "poke_flute.png"
	else:
		var stone_clean = clean.replace("stone_", "").replace("_stone", "").replace(" stone", "").strip_edges()
		if stone_clean in ["fire", "water", "leaf", "thunder", "ground", "heart", "night", "psyche", "punch", "scale"]:
			file_name = "%s stone.png" % stone_clean
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

var booster_textures_cache: Dictionary = {}

func get_booster_pack_texture(pack_id_or_region: String = "kanto") -> Texture2D:
	var key = pack_id_or_region.strip_edges().to_lower()
	if booster_textures_cache.has(key):
		return booster_textures_cache[key]
		
	var pack_info = BOOSTER_PACKS.get(key, {})
	var candidates: Array[String] = []
	if not pack_info.is_empty():
		candidates.append(str(pack_info.get("texture_path", "")))
		candidates.append(str(pack_info.get("fallback_texture", "")))
	else:
		for pid in BOOSTER_PACKS:
			var p = BOOSTER_PACKS[pid]
			if p.get("region", "").to_lower() == key:
				candidates.append(str(p.get("texture_path", "")))
				candidates.append(str(p.get("fallback_texture", "")))
				break
				
	if candidates.is_empty():
		candidates.append("res://assets/Kanto Booster Pack.PNG")
		candidates.append("res://assets/kanto_booster_pack.png")
		
	for res_path in candidates:
		if res_path.is_empty():
			continue
		if ResourceLoader.exists(res_path):
			var tex = load(res_path)
			if tex:
				booster_textures_cache[key] = tex
				return tex
		var abs_p = ProjectSettings.globalize_path(res_path)
		if FileAccess.file_exists(abs_p):
			var img = Image.load_from_file(abs_p)
			if img:
				var itex = ImageTexture.create_from_image(img)
				booster_textures_cache[key] = itex
				return itex
				
	return null

func get_booster_pack_border_texture() -> Texture2D:
	var path = "res://assets/ui/borderstextures.png"
	if ResourceLoader.exists(path):
		return load(path)
	var abs_p = ProjectSettings.globalize_path(path)
	if FileAccess.file_exists(abs_p):
		var img = Image.load_from_file(abs_p)
		if img:
			return ImageTexture.create_from_image(img)
	return null

func get_booster_rarity_rates(region: String = "") -> Array[Dictionary]:
	var counts = {}
	var weighted = {}
	var total_w = 0.0
	var target_ids: Array[int] = []
	if region.strip_edges() != "":
		for id in all_pokemon_ids:
			var d = pokemon_catalog.get(id, {})
			if str(d.get("region", "")).to_lower() == region.strip_edges().to_lower():
				target_ids.append(id)
	if target_ids.is_empty():
		target_ids = all_pokemon_ids
		
	for id in target_ids:
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
	is_tutorial_mode = false
	tutorial_completed = false
	tutorial_reward_claimed = false
	just_completed_tutorial = false
	adventure_current_episode = 1
	adventure_current_stage = 1
	adventure_gold = 0
	adventure_inventory = DEFAULT_INVENTORY.duplicate()
	adventure_player_team_state.clear()
	adventure_completed_episodes.clear()
	adventure_unlocked_episodes = [1]
	adventure_ep5_selected_route = "rocket_hideout"
	adventure_ep5_cleared_routes.clear()
	adventure_ep6_selected_route = "silph_co"
	adventure_ep6_cleared_routes.clear()
	adventure_ep7_selected_route = "pokemon_mansion"
	adventure_ep7_cleared_routes.clear()
	
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
				
	player_favorites.clear()
	profile_showcase_ids.clear()
	for id in player_unlocked_ids:
		if profile_showcase_ids.size() < 3:
			profile_showcase_ids.append(id)
				
	save_profile(auto_sync_cloud)
	diamonds_changed.emit(player_diamonds)
	rare_candies_changed.emit(player_rare_candies)
	print("Profile created for Trainer '%s' (Email: '%s'). Welcome gift pending claim!" % [profile_name, profile_email])

func create_or_update_profile(p_name: String, provider: String = "Local", p_email: String = "", auto_sync_cloud: bool = false) -> void:
	var clean = p_name.strip_edges()
	if clean != "" and clean != "Trainer":
		profile_name = clean
	elif profile_name.is_empty() or profile_name == "Trainer":
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
			"welcome_gift_claimed": profile_welcome_claimed,
			"favorite_showcase": profile_showcase_ids.duplicate()
		},
		"favorites": player_favorites.duplicate(),
		"favorite_showcase": profile_showcase_ids.duplicate(),
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
			"team_state": campaign_player_team_state,
			"tutorial_completed": tutorial_completed,
			"tutorial_reward_claimed": tutorial_reward_claimed
		},
		"adventure": {
			"current_episode": adventure_current_episode,
			"current_stage": adventure_current_stage,
			"gold": adventure_gold,
			"inventory": adventure_inventory.duplicate(true),
			"team_state": adventure_player_team_state.duplicate(true),
			"completed_episodes": adventure_completed_episodes.duplicate(),
			"unlocked_episodes": adventure_unlocked_episodes.duplicate(),
			"ep5_selected_route": adventure_ep5_selected_route,
			"ep5_cleared_routes": adventure_ep5_cleared_routes.duplicate(),
			"ep6_selected_route": adventure_ep6_selected_route,
			"ep6_cleared_routes": adventure_ep6_cleared_routes.duplicate(),
			"ep7_selected_route": adventure_ep7_selected_route,
			"ep7_cleared_routes": adventure_ep7_cleared_routes.duplicate()
		},
		"settings": {
			"language": settings_language,
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
	var incoming_name = str(prof.get("trainer_alias", prof.get("name", ""))).strip_edges()
	if incoming_name != "" and incoming_name != "Trainer":
		profile_name = incoming_name
	elif profile_name.is_empty() or profile_name == "Trainer":
		if incoming_name != "":
			profile_name = incoming_name
		else:
			profile_name = "Trainer"
	
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
				
	# Cargar favoritos
	player_favorites.clear()
	var raw_favs = data.get("favorites", prof.get("favorites", []))
	if typeof(raw_favs) == TYPE_ARRAY:
		for fid in raw_favs:
			var int_fid = int(fid)
			if int_fid not in player_favorites:
				player_favorites.append(int_fid)

	# Cargar showcase de 3 favoritos
	profile_showcase_ids.clear()
	var raw_showcase = data.get("favorite_showcase", prof.get("favorite_showcase", []))
	if typeof(raw_showcase) == TYPE_ARRAY:
		for sid in raw_showcase:
			var int_sid = int(sid)
			if int_sid not in profile_showcase_ids and profile_showcase_ids.size() < 3:
				profile_showcase_ids.append(int_sid)
				
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
	campaign_inventory = camp.get("inventory", DEFAULT_INVENTORY.duplicate())
	for k in DEFAULT_INVENTORY.keys():
		if not campaign_inventory.has(k):
			campaign_inventory[k] = 0
	campaign_player_team_state = camp.get("team_state", [])
	tutorial_completed = bool(camp.get("tutorial_completed", false))
	tutorial_reward_claimed = bool(camp.get("tutorial_reward_claimed", false))
	
	# Cargar aventura
	var adv = data.get("adventure", {})
	adventure_current_episode = int(adv.get("current_episode", 1))
	adventure_current_stage = int(adv.get("current_stage", 1))
	var legacy_adv_gold = int(adv.get("gold", 0))
	if legacy_adv_gold > 0 and campaign_gold == 0:
		campaign_gold = legacy_adv_gold
	adventure_gold = campaign_gold
	adventure_inventory = adv.get("inventory", DEFAULT_INVENTORY.duplicate())
	for k in DEFAULT_INVENTORY.keys():
		if not adventure_inventory.has(k):
			adventure_inventory[k] = 0
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
	adventure_ep5_selected_route = str(adv.get("ep5_selected_route", "rocket_hideout"))
	var raw_ep5_cleared = adv.get("ep5_cleared_routes", [])
	adventure_ep5_cleared_routes.clear()
	for r in raw_ep5_cleared:
		adventure_ep5_cleared_routes.append(str(r))
	adventure_ep6_selected_route = str(adv.get("ep6_selected_route", "silph_co"))
	var raw_ep6_cleared = adv.get("ep6_cleared_routes", [])
	adventure_ep6_cleared_routes.clear()
	for r in raw_ep6_cleared:
		adventure_ep6_cleared_routes.append(str(r))
	adventure_ep7_selected_route = str(adv.get("ep7_selected_route", "pokemon_mansion"))
	var raw_ep7_cleared = adv.get("ep7_cleared_routes", [])
	adventure_ep7_cleared_routes.clear()
	for r in raw_ep7_cleared:
		adventure_ep7_cleared_routes.append(str(r))
		
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
	settings_language = normalize_language_code(str(sett.get("language", settings_language)))
	settings_music_volume = float(sett.get("music_volume", 0.8))
	settings_music_muted = bool(sett.get("music_muted", false))
	settings_sfx_volume = float(sett.get("sfx_volume", 0.9))
	settings_sfx_muted = bool(sett.get("sfx_muted", false))
	apply_language_to_scene_tree()
	
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
	is_tutorial_mode = false
	tutorial_completed = false
	tutorial_reward_claimed = false
	just_completed_tutorial = false
	adventure_current_episode = 1
	adventure_current_stage = 1
	adventure_gold = 0
	adventure_inventory = DEFAULT_INVENTORY.duplicate()
	adventure_player_team_state.clear()
	adventure_completed_episodes.clear()
	adventure_unlocked_episodes = [1]
	adventure_ep5_selected_route = "rocket_hideout"
	adventure_ep5_cleared_routes.clear()
	adventure_ep6_selected_route = "silph_co"
	adventure_ep6_cleared_routes.clear()
	adventure_ep7_selected_route = "pokemon_mansion"
	adventure_ep7_cleared_routes.clear()
	
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
	settings_language = "en"
	settings_music_volume = 0.8
	settings_music_muted = false
	settings_sfx_volume = 0.9
	settings_sfx_muted = false
	apply_language_to_scene_tree()
	print("Profile erased. Starting fresh!")
