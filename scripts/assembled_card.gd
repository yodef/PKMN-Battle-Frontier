extends Control
class_name AssembledCard

# Paleta de temas elementales para el ensamble dinámico de cartas
const TYPE_THEMES = {
	"GRASS": {
		"bg": Color("#1b4332"),
		"border": Color("#52b788"),
		"art_bg": Color("#0b2219"),
		"header_bg": Color("#2d6a4f"),
		"name": "GRASS"
	},
	"FIRE": {
		"bg": Color("#5c1d1d"),
		"border": Color("#ff6b4a"),
		"art_bg": Color("#2b0b0b"),
		"header_bg": Color("#8a2626"),
		"name": "FIRE"
	},
	"WATER": {
		"bg": Color("#16325c"),
		"border": Color("#48cae4"),
		"art_bg": Color("#0a192f"),
		"header_bg": Color("#1d4e89"),
		"name": "WATER"
	},
	"THUNDER": {
		"bg": Color("#4d3e09"),
		"border": Color("#ffd166"),
		"art_bg": Color("#241c03"),
		"header_bg": Color("#80660c"),
		"name": "ELECTRIC"
	},
	"ELECTRIC": {
		"bg": Color("#4d3e09"),
		"border": Color("#ffd166"),
		"art_bg": Color("#241c03"),
		"header_bg": Color("#80660c"),
		"name": "ELECTRIC"
	},
	"ROCK": {
		"bg": Color("#3d321d"),
		"border": Color("#b89758"),
		"art_bg": Color("#1c160c"),
		"header_bg": Color("#614f2e"),
		"name": "ROCK"
	},
	"STEEL": {
		"bg": Color("#242d38"),
		"border": Color("#a0aec0"),
		"art_bg": Color("#10141a"),
		"header_bg": Color("#404d5e"),
		"name": "STEEL"
	},
	"ICE": {
		"bg": Color("#14324a"),
		"border": Color("#76e4f7"),
		"art_bg": Color("#091a26"),
		"header_bg": Color("#235b80"),
		"name": "ICE"
	},
	"DRAGON": {
		"bg": Color("#241445"),
		"border": Color("#9d4edd"),
		"art_bg": Color("#100821"),
		"header_bg": Color("#4c1d85"),
		"name": "DRAGON"
	},
	"FAIRY": {
		"bg": Color("#42182d"),
		"border": Color("#f72585"),
		"art_bg": Color("#1f0a15"),
		"header_bg": Color("#6e1a44"),
		"name": "FAIRY"
	},
	"GHOST": {
		"bg": Color("#221538"),
		"border": Color("#7b2cbf"),
		"art_bg": Color("#0f091c"),
		"header_bg": Color("#3c185c"),
		"name": "GHOST"
	},
	"NORMAL": {
		"bg": Color("#2f3640"),
		"border": Color("#95a5a6"),
		"art_bg": Color("#181b20"),
		"header_bg": Color("#4b5768"),
		"name": "NORMAL"
	},
	"DARK": {
		"bg": Color("#2b1e3a"),
		"border": Color("#a288e3"),
		"art_bg": Color("#130a1c"),
		"header_bg": Color("#493563"),
		"name": "DARK"
	},
	"POISON": {
		"bg": Color("#3a1d47"),
		"border": Color("#b388ff"),
		"art_bg": Color("#190821"),
		"header_bg": Color("#5c2b73"),
		"name": "POISON"
	},
	"BUG": {
		"bg": Color("#283618"),
		"border": Color("#a3b18a"),
		"art_bg": Color("#141b0b"),
		"header_bg": Color("#415a27"),
		"name": "BUG"
	},
	"FLYING": {
		"bg": Color("#203a4c"),
		"border": Color("#81d4fa"),
		"art_bg": Color("#0c1b26"),
		"header_bg": Color("#2e5772"),
		"name": "FLYING"
	},
	"PSYCHIC": {
		"bg": Color("#4a154b"),
		"border": Color("#f06292"),
		"art_bg": Color("#1c061d"),
		"header_bg": Color("#742377"),
		"name": "PSYCHIC"
	},
	"FIGHTING": {
		"bg": Color("#4e2016"),
		"border": Color("#e07a5f"),
		"art_bg": Color("#1f0a05"),
		"header_bg": Color("#7d3324"),
		"name": "FIGHTING"
	},
	"GROUND": {
		"bg": Color("#4a3525"),
		"border": Color("#dda15e"),
		"art_bg": Color("#1c140d"),
		"header_bg": Color("#6e4f37"),
		"name": "GROUND"
	}
}

@onready var card_panel: PanelContainer = $CardPanel
@onready var stage_label: Label = $CardPanel/Margin/VBox/HeaderHBox/StageBadge/StageLabel
@onready var stage_badge: PanelContainer = $CardPanel/Margin/VBox/HeaderHBox/StageBadge
@onready var name_label: Label = $CardPanel/Margin/VBox/HeaderHBox/NameLabel
@onready var hp_label: Label = $CardPanel/Margin/VBox/HeaderHBox/HpBox/HpLabel
@onready var type_icon: TextureRect = $CardPanel/Margin/VBox/HeaderHBox/HpBox/TypeIcon
@onready var art_frame: PanelContainer = $CardPanel/Margin/VBox/ArtFrame
@onready var sprite_rect: TextureRect = $CardPanel/Margin/VBox/ArtFrame/SpriteRect
@onready var pokedex_label: Label = $CardPanel/Margin/VBox/SubHeader/SubHBox/PokedexLabel
@onready var tier_badge: PanelContainer = $CardPanel/Margin/VBox/SubHeader/SubHBox/TierBadge
@onready var tier_label: Label = $CardPanel/Margin/VBox/SubHeader/SubHBox/TierBadge/TierLabel
@onready var m1_type_icon: TextureRect = $CardPanel/Margin/VBox/MovesBox/Move1Row/M1TypeIcon
@onready var m1_cost: Label = $CardPanel/Margin/VBox/MovesBox/Move1Row/M1Cost
@onready var m1_name: Label = $CardPanel/Margin/VBox/MovesBox/Move1Row/M1Name
@onready var m1_dmg: Label = $CardPanel/Margin/VBox/MovesBox/Move1Row/M1Dmg
@onready var m2_type_icon: TextureRect = $CardPanel/Margin/VBox/MovesBox/Move2Row/M2TypeIcon
@onready var m2_cost: Label = $CardPanel/Margin/VBox/MovesBox/Move2Row/M2Cost
@onready var m2_name: Label = $CardPanel/Margin/VBox/MovesBox/Move2Row/M2Name
@onready var m2_dmg: Label = $CardPanel/Margin/VBox/MovesBox/Move2Row/M2Dmg
@onready var weak_icon: TextureRect = $CardPanel/Margin/VBox/FooterHBox/WeakBox/WeakIcon
@onready var weak_val: Label = $CardPanel/Margin/VBox/FooterHBox/WeakBox/WeakVal
@onready var res_icon: TextureRect = $CardPanel/Margin/VBox/FooterHBox/ResBox/ResIcon
@onready var res_val: Label = $CardPanel/Margin/VBox/FooterHBox/ResBox/ResVal
@onready var speed_label: Label = $CardPanel/Margin/VBox/FooterHBox/SpeedLabel

func _ensure_nodes() -> void:
	if card_panel == null:
		card_panel = $CardPanel
		stage_label = $CardPanel/Margin/VBox/HeaderHBox/StageBadge/StageLabel
		stage_badge = $CardPanel/Margin/VBox/HeaderHBox/StageBadge
		name_label = $CardPanel/Margin/VBox/HeaderHBox/NameLabel
		hp_label = $CardPanel/Margin/VBox/HeaderHBox/HpBox/HpLabel
		type_icon = $CardPanel/Margin/VBox/HeaderHBox/HpBox/TypeIcon
		art_frame = $CardPanel/Margin/VBox/ArtFrame
		sprite_rect = $CardPanel/Margin/VBox/ArtFrame/SpriteRect
		pokedex_label = find_child("PokedexLabel", true, false)
		tier_badge = find_child("TierBadge", true, false)
		tier_label = find_child("TierLabel", true, false)
		m1_type_icon = $CardPanel/Margin/VBox/MovesBox/Move1Row/M1TypeIcon
		m1_cost = $CardPanel/Margin/VBox/MovesBox/Move1Row/M1Cost
		m1_name = $CardPanel/Margin/VBox/MovesBox/Move1Row/M1Name
		m1_dmg = $CardPanel/Margin/VBox/MovesBox/Move1Row/M1Dmg
		m2_type_icon = $CardPanel/Margin/VBox/MovesBox/Move2Row/M2TypeIcon
		m2_cost = $CardPanel/Margin/VBox/MovesBox/Move2Row/M2Cost
		m2_name = $CardPanel/Margin/VBox/MovesBox/Move2Row/M2Name
		m2_dmg = $CardPanel/Margin/VBox/MovesBox/Move2Row/M2Dmg
		weak_icon = $CardPanel/Margin/VBox/FooterHBox/WeakBox/WeakIcon
		weak_val = $CardPanel/Margin/VBox/FooterHBox/WeakBox/WeakVal
		res_icon = $CardPanel/Margin/VBox/FooterHBox/ResBox/ResIcon
		res_val = $CardPanel/Margin/VBox/FooterHBox/ResBox/ResVal
		speed_label = $CardPanel/Margin/VBox/FooterHBox/SpeedLabel

static func get_type_theme(type_name: String) -> Dictionary:
	var key = type_name.to_upper()
	return TYPE_THEMES.get(key, TYPE_THEMES["NORMAL"])

static func get_tier_color(tier_str: String) -> Color:
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

func setup(d: Dictionary, is_unlocked: bool = true) -> void:
	_ensure_nodes()

	var p_num = str(d.get("pokedex_num", "1")).pad_zeros(3)

	if not is_unlocked:
		# Carta Desconocida / Bloqueada
		var card_sb = StyleBoxFlat.new()
		card_sb.bg_color = Color("#151820")
		card_sb.set_border_width_all(3)
		card_sb.border_color = Color("#2d3748")
		card_sb.set_corner_radius_all(10)
		card_panel.add_theme_stylebox_override("panel", card_sb)

		var art_sb = StyleBoxFlat.new()
		art_sb.bg_color = Color("#0c0e13")
		art_sb.set_border_width_all(2)
		art_sb.border_color = Color("#1f2735")
		art_sb.set_corner_radius_all(6)
		art_frame.add_theme_stylebox_override("panel", art_sb)

		stage_label.text = "???"
		var badge_sb = StyleBoxFlat.new()
		badge_sb.bg_color = Color("#1f2735")
		badge_sb.set_corner_radius_all(4)
		badge_sb.content_margin_left = 4
		badge_sb.content_margin_right = 4
		badge_sb.content_margin_top = 1
		badge_sb.content_margin_bottom = 1
		stage_badge.add_theme_stylebox_override("panel", badge_sb)

		name_label.text = "???"
		name_label.modulate = Color(0.6, 0.65, 0.72)
		hp_label.text = "?? HP"
		hp_label.modulate = Color(0.6, 0.65, 0.72)
		type_icon.visible = false
		type_icon.texture = null

		sprite_rect.texture = null
		sprite_rect.modulate = Color(0.3, 0.3, 0.3, 0.5)

		pokedex_label.text = "No. %s • ???" % p_num

		m1_type_icon.visible = false
		m1_type_icon.texture = null
		m1_cost.text = "—"
		m1_name.text = "???"
		m1_dmg.text = "— DMG"

		m2_type_icon.visible = false
		m2_type_icon.texture = null
		m2_cost.text = "—"
		m2_name.text = "???"
		m2_dmg.text = "— DMG"

		weak_icon.visible = false
		weak_val.text = "?"
		res_icon.visible = false
		res_val.text = "?"
		speed_label.text = "👟 ? SPD"
		if tier_badge:
			tier_badge.visible = false
		GameData.apply_foil_overlay(self, "")
		return

	# Si está desbloqueada: restaurar modulación normal y mostrar todos los datos
	name_label.modulate = Color.WHITE
	hp_label.modulate = Color(1.0, 0.9, 0.3)
	type_icon.visible = true
	sprite_rect.modulate = Color.WHITE

	var type_key = str(d.get("type", "NORMAL")).to_upper()
	var theme = TYPE_THEMES.get(type_key, TYPE_THEMES["NORMAL"])

	# 1. Estilo del marco exterior de la carta con fondo del Tipo
	var card_sb = StyleBoxFlat.new()
	card_sb.bg_color = theme["bg"]
	card_sb.set_border_width_all(3)
	card_sb.border_color = theme["border"]
	card_sb.set_corner_radius_all(10)
	card_panel.add_theme_stylebox_override("panel", card_sb)

	# 2. Estilo del marco del arte (receptáculo del sprite limpio)
	var art_sb = StyleBoxFlat.new()
	art_sb.bg_color = theme["art_bg"]
	art_sb.set_border_width_all(2)
	art_sb.border_color = theme["border"].lerp(Color.WHITE, 0.25)
	art_sb.set_corner_radius_all(6)
	art_frame.add_theme_stylebox_override("panel", art_sb)

	# 3. Badge de Fase (BASIC / STAGE 1 / STAGE 2 / LEGENDARY)
	var stage_raw = str(d.get("stage", "Basic"))
	var stage_text = "BASIC"
	if stage_raw.to_lower().contains("1") or stage_raw.to_lower().contains("fase 1"):
		stage_text = "STAGE 1"
	elif stage_raw.to_lower().contains("2") or stage_raw.to_lower().contains("fase 2"):
		stage_text = "STAGE 2"
	elif stage_raw.to_lower().contains("legendary") or stage_raw.to_lower().contains("legend"):
		stage_text = "LEGENDARY"
	stage_label.text = stage_text

	var badge_sb = StyleBoxFlat.new()
	badge_sb.bg_color = theme["header_bg"]
	badge_sb.set_corner_radius_all(4)
	badge_sb.content_margin_left = 4
	badge_sb.content_margin_right = 4
	badge_sb.content_margin_top = 1
	badge_sb.content_margin_bottom = 1
	stage_badge.add_theme_stylebox_override("panel", badge_sb)

	# 4. Nombre y Estadísticas Superiores con Icono Oficial
	name_label.text = str(d.get("short_name", d.get("name", "PKMN")))
	hp_label.text = "%d HP" % int(d.get("hp", 10))
	type_icon.texture = GameData.get_type_icon_texture(type_key)

	# 5. Cargar Sprite Limpio
	var tex_file = str(d.get("texture_path", d.get("texture_file", "")))
	var tex = GameData.get_pokemon_texture(tex_file)
	sprite_rect.texture = tex

	# 6. Tira de Información Pokédex y Rango en Tier List
	pokedex_label.text = "No. %s • %s Type" % [p_num, theme.get("name", type_key)]
	if tier_badge and tier_label:
		var tier_val = str(d.get("tier", "C")).strip_edges().to_upper()
		if tier_val == "":
			tier_val = "C"
		var t_col = get_tier_color(tier_val)
		tier_label.text = "TIER %s" % tier_val
		tier_label.add_theme_color_override("font_color", t_col)
		tier_label.add_theme_font_size_override("font_size", 8)
		
		var tb_sb = StyleBoxFlat.new()
		tb_sb.bg_color = Color(0.04, 0.07, 0.12, 0.90)
		tb_sb.border_color = t_col
		tb_sb.set_border_width_all(1)
		tb_sb.set_corner_radius_all(3)
		tb_sb.content_margin_left = 5
		tb_sb.content_margin_right = 5
		tb_sb.content_margin_top = 1
		tb_sb.content_margin_bottom = 1
		tier_badge.add_theme_stylebox_override("panel", tb_sb)
		tier_badge.visible = true

	# 7. Resumen de Movimientos en la carta con Icono Oficial de Tipo
	var m1_type = str(d.get("m1_type", "NORMAL")).to_upper()
	m1_type_icon.visible = true
	m1_type_icon.texture = GameData.get_type_icon_texture(m1_type)
	var c1 = int(d.get("m1_cost", 1))
	m1_cost.text = "⚡ %d" % c1 if c1 > 0 else "—"
	m1_name.text = str(d.get("m1_name", "Attack 1"))
	m1_dmg.text = "%d DMG" % int(d.get("m1_dmg", 0))

	var m2_type = str(d.get("m2_type", "NORMAL")).to_upper()
	m2_type_icon.visible = true
	m2_type_icon.texture = GameData.get_type_icon_texture(m2_type)
	var c2 = int(d.get("m2_cost", 1))
	m2_cost.text = "⚡ %d" % c2 if c2 > 0 else "—"
	m2_name.text = str(d.get("m2_name", "Attack 2"))
	m2_dmg.text = "%d DMG" % int(d.get("m2_dmg", 0))

	# 8. Pie de Carta (Debilidad, Resistencia, Velocidad) con Iconos Oficiales
	var weak_key = str(d.get("weakness", "NONE")).to_upper()
	if weak_key != "NONE" and GameData.TYPE_ICON_FILES.has(weak_key):
		weak_icon.visible = true
		weak_icon.texture = GameData.get_type_icon_texture(weak_key)
		weak_val.text = "+2"
	else:
		weak_icon.visible = false
		weak_val.text = "—"

	var res_key = str(d.get("resistant", "NONE")).to_upper()
	if res_key != "NONE" and GameData.TYPE_ICON_FILES.has(res_key):
		res_icon.visible = true
		res_icon.texture = GameData.get_type_icon_texture(res_key)
		res_val.text = "-2"
	else:
		res_icon.visible = false
		res_val.text = "—"

	speed_label.text = "👟 %d SPD" % int(d.get("speed", 1))
	
	# 9. Efecto Foil Holográfico según Rareza (Rare, Epic, Legendary, Boss, Gym Leader Ace, Elite Four Ace)
	var card_rarity = str(d.get("rarity", "Common"))
	if int(d.get("id", -1)) == GameData.CRYSTAL_ONIX_ID or str(d.get("name", "")) == "Crystal Onix" or str(d.get("stage", "")).to_lower() == "boss":
		card_rarity = "Boss"
	elif d.get("foil_type", "") != "":
		card_rarity = d.get("foil_type")
	elif GameData.is_elite_four_ace(d):
		card_rarity = "elite_four_ace"
	elif GameData.is_gym_leader_ace(d):
		card_rarity = "gym_leader_ace"
	GameData.apply_foil_overlay(self, card_rarity)
