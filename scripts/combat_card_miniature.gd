extends PanelContainer
class_name CombatCardMiniature

signal inspect_requested

const AssembledCardScript = preload("res://scripts/assembled_card.gd")

var current_pokemon = null
var is_enemy_card: bool = false

# Nodos internos
var margin_container: MarginContainer
var content_vbox: VBoxContainer
var header_hbox: HBoxContainer
var stage_badge: PanelContainer
var stage_label: Label
var name_label: Label
var hp_label: Label
var art_frame: PanelContainer
var art_sprite: TextureRect
var footer_hbox: HBoxContainer
var dex_label: Label
var rarity_badge: Label
var btn_inspect: Button

# Compatibilidad con código que acceda a .texture directamente
var texture: Texture2D:
	get:
		return art_sprite.texture if is_instance_valid(art_sprite) else null
	set(val):
		if is_instance_valid(art_sprite):
			art_sprite.texture = val

func _init() -> void:
	custom_minimum_size = Vector2(130, 180)
	size = Vector2(130, 180)
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_build_card_ui()

func _ready() -> void:
	_build_card_ui()

func _build_card_ui() -> void:
	if margin_container != null:
		return
		
	# 1. Contenedor con márgenes internos de carta ajustados
	margin_container = MarginContainer.new()
	margin_container.add_theme_constant_override("margin_left", 4)
	margin_container.add_theme_constant_override("margin_right", 4)
	margin_container.add_theme_constant_override("margin_top", 4)
	margin_container.add_theme_constant_override("margin_bottom", 4)
	margin_container.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(margin_container)
	
	content_vbox = VBoxContainer.new()
	content_vbox.add_theme_constant_override("separation", 2)
	content_vbox.mouse_filter = Control.MOUSE_FILTER_PASS
	margin_container.add_child(content_vbox)
	
	# 2. Fila Superior (Header): Badge de fase + Nombre + Botón Lupa
	header_hbox = HBoxContainer.new()
	header_hbox.custom_minimum_size = Vector2(0, 20)
	header_hbox.add_theme_constant_override("separation", 2)
	header_hbox.alignment = BoxContainer.ALIGNMENT_BEGIN
	header_hbox.mouse_filter = Control.MOUSE_FILTER_PASS
	content_vbox.add_child(header_hbox)
	
	stage_badge = PanelContainer.new()
	stage_badge.mouse_filter = Control.MOUSE_FILTER_PASS
	stage_badge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	header_hbox.add_child(stage_badge)
	
	stage_label = Label.new()
	stage_label.add_theme_font_size_override("font_size", 7)
	stage_label.add_theme_color_override("font_color", Color.WHITE)
	stage_label.text = "BASIC"
	stage_badge.add_child(stage_label)
	
	name_label = Label.new()
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	name_label.clip_text = true
	name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	name_label.add_theme_font_size_override("font_size", 9)
	name_label.add_theme_color_override("font_color", Color.WHITE)
	name_label.text = "Pokémon"
	header_hbox.add_child(name_label)
	
	# Botón de Lupa (🔍) integrado en la cabecera - Indicador visual sin texto
	btn_inspect = Button.new()
	btn_inspect.name = "BtnInspect"
	btn_inspect.text = "🔍"
	btn_inspect.custom_minimum_size = Vector2(20, 20)
	btn_inspect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	btn_inspect.add_theme_font_size_override("font_size", 10)
	btn_inspect.focus_mode = Control.FOCUS_NONE
	btn_inspect.mouse_filter = Control.MOUSE_FILTER_STOP
	btn_inspect.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_inspect.tooltip_text = "Inspeccionar detalles del Pokémon"
	btn_inspect.z_as_relative = true
	btn_inspect.z_index = 2
	
	var b_norm = StyleBoxFlat.new()
	b_norm.bg_color = Color(0.08, 0.14, 0.22, 0.85)
	b_norm.border_color = Color(0.45, 0.80, 1.0, 0.80)
	b_norm.set_border_width_all(1)
	b_norm.set_corner_radius_all(10)
	
	var b_hov = StyleBoxFlat.new()
	b_hov.bg_color = Color(0.18, 0.30, 0.48, 0.95)
	b_hov.border_color = Color(1.0, 0.85, 0.30, 1.0)
	b_hov.set_border_width_all(2)
	b_hov.set_corner_radius_all(10)
	
	var b_press = StyleBoxFlat.new()
	b_press.bg_color = Color(0.04, 0.08, 0.14, 0.95)
	b_press.border_color = Color(0.25, 0.60, 0.90, 1.0)
	b_press.set_border_width_all(1)
	b_press.set_corner_radius_all(10)
	
	btn_inspect.add_theme_stylebox_override("normal", b_norm)
	btn_inspect.add_theme_stylebox_override("hover", b_hov)
	btn_inspect.add_theme_stylebox_override("pressed", b_press)
	btn_inspect.pressed.connect(_on_inspect_pressed)
	header_hbox.add_child(btn_inspect)
	
	# 3. Marco de Ilustración (ArtFrame con Sprite del Pokémon)
	art_frame = PanelContainer.new()
	art_frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	art_frame.custom_minimum_size = Vector2(0, 120)
	art_frame.mouse_filter = Control.MOUSE_FILTER_PASS
	art_frame.clip_contents = true
	content_vbox.add_child(art_frame)
	
	art_sprite = TextureRect.new()
	art_sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	art_sprite.set_anchors_preset(Control.PRESET_FULL_RECT)
	art_sprite.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	art_sprite.size_flags_vertical = Control.SIZE_EXPAND_FILL
	art_sprite.mouse_filter = Control.MOUSE_FILTER_PASS
	art_frame.add_child(art_sprite)
	
	# 4. Fila Inferior (Footer): Nº Pokédex / Tipo + Rareza / HP Base
	footer_hbox = HBoxContainer.new()
	footer_hbox.custom_minimum_size = Vector2(0, 16)
	footer_hbox.add_theme_constant_override("separation", 2)
	footer_hbox.mouse_filter = Control.MOUSE_FILTER_PASS
	content_vbox.add_child(footer_hbox)
	
	dex_label = Label.new()
	dex_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dex_label.add_theme_font_size_override("font_size", 8)
	dex_label.add_theme_color_override("font_color", Color(0.85, 0.90, 0.95, 0.85))
	dex_label.text = "#001 • NORMAL"
	footer_hbox.add_child(dex_label)
	
	hp_label = Label.new()
	hp_label.add_theme_font_size_override("font_size", 8)
	hp_label.add_theme_color_override("font_color", Color("#ffd166"))
	hp_label.text = "10 HP"
	footer_hbox.add_child(hp_label)
	
	rarity_badge = Label.new()
	rarity_badge.add_theme_font_size_override("font_size", 8)
	rarity_badge.add_theme_color_override("font_color", Color("#ffd700"))
	rarity_badge.text = "★"
	footer_hbox.add_child(rarity_badge)

func _on_inspect_pressed() -> void:
	inspect_requested.emit()

func setup(pkmn, is_enemy: bool = false) -> void:
	current_pokemon = pkmn
	is_enemy_card = is_enemy
	
	if not pkmn:
		visible = false
		return
	visible = true
	
	# Extraer datos de PokemonData o Diccionario
	var p_name = str(pkmn.name if "name" in pkmn else pkmn.get("name", "PKMN"))
	var p_type = str(pkmn.type if "type" in pkmn else pkmn.get("type", "NORMAL")).to_upper()
	var p_stage = str(pkmn.stage if "stage" in pkmn else pkmn.get("stage", "Basic"))
	var p_rarity = str(pkmn.rarity if "rarity" in pkmn else pkmn.get("rarity", "Common"))
	var p_tier = str(pkmn.tier if "tier" in pkmn else pkmn.get("tier", "C")).to_upper()
	var p_hp = int(pkmn.max_hp if "max_hp" in pkmn else pkmn.get("hp", 10))
	var p_dex = str(pkmn.pokedex_num if "pokedex_num" in pkmn else pkmn.get("pokedex_num", "1")).pad_zeros(3)
	var p_tex_path = str(pkmn.texture_path if "texture_path" in pkmn else pkmn.get("texture_path", ""))
	
	# 1. Paleta temática elemental
	var theme = AssembledCardScript.TYPE_THEMES.get(p_type, AssembledCardScript.TYPE_THEMES["NORMAL"])
	
	# 2. Marco exterior y fondo de la carta
	var card_sb = StyleBoxFlat.new()
	card_sb.bg_color = theme["bg"]
	card_sb.border_color = theme["border"]
	card_sb.set_border_width_all(2)
	card_sb.set_corner_radius_all(6)
	card_sb.content_margin_left = 4
	card_sb.content_margin_right = 4
	card_sb.content_margin_top = 4
	card_sb.content_margin_bottom = 4
	add_theme_stylebox_override("panel", card_sb)
	
	# 3. Badge de Fase
	var stage_text = "BASIC"
	var st_low = p_stage.to_lower()
	if st_low.contains("1") or st_low.contains("fase 1"):
		stage_text = "ST.1"
	elif st_low.contains("2") or st_low.contains("fase 2"):
		stage_text = "ST.2"
	elif st_low.contains("legendary") or st_low.contains("legend"):
		stage_text = "LEGEND"
	stage_label.text = stage_text
	
	var badge_sb = StyleBoxFlat.new()
	badge_sb.bg_color = theme["header_bg"]
	badge_sb.set_corner_radius_all(3)
	badge_sb.content_margin_left = 3
	badge_sb.content_margin_right = 3
	badge_sb.content_margin_top = 1
	badge_sb.content_margin_bottom = 1
	stage_badge.add_theme_stylebox_override("panel", badge_sb)
	
	# 4. Nombre
	name_label.text = p_name
	
	# 5. Marco interior de la ilustración (ArtFrame)
	var art_sb = StyleBoxFlat.new()
	art_sb.bg_color = theme["art_bg"]
	art_sb.border_color = theme["border"].lerp(Color.WHITE, 0.25)
	art_sb.set_border_width_all(1)
	art_sb.set_corner_radius_all(4)
	art_frame.add_theme_stylebox_override("panel", art_sb)
	
	# Sprite del Pokémon
	art_sprite.texture = GameData.get_pokemon_texture(p_tex_path)
	
	# 6. Fila inferior (Dex / Tipo, HP y Rareza)
	dex_label.text = "#%s • %s" % [p_dex, theme.get("name", p_type)]
	hp_label.text = "%d HP" % p_hp
	
	var r_info = GameData.get_rarity_display_info(p_rarity)
	var stars = str(r_info.get("stars", "★"))
	rarity_badge.text = stars
	rarity_badge.add_theme_color_override("font_color", r_info.get("color", Color("#ffd700")))
	
	# 7. Efecto Foil Holográfico según rareza (Rare, Epic, Legendary)
	var foil_node = GameData.apply_foil_overlay(self, p_rarity)
	if foil_node:
		move_child(foil_node, get_child_count() - 1)
