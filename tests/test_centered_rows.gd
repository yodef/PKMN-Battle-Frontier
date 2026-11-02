extends Node

const AssembledCardScript = preload("res://scripts/assembled_card.gd")

func _ready() -> void:
	var menu_packed = load("res://scenes/main_menu.tscn")
	var menu = menu_packed.instantiate()
	add_child(menu)
	
	# Unlock ONLY the 7 Pokémon from user's screenshot (NO Pidgey)
	GameData.player_unlocked_ids = [0, 1, 2] # start
	for p_id in GameData.pokemon_catalog.keys():
		var p = GameData.pokemon_catalog[p_id]
		var name = str(p.get("name", ""))
		if name in ["Bulbasaur", "Charmander", "Squirtle", "Nidoran♀", "Nidoran F", "Mankey", "Drowzee", "Pichu"]:
			GameData.unlock_pokemon(p_id)
		elif name == "Pidgey":
			GameData.player_unlocked_ids.erase(p_id)
			
	menu._on_login_play_pressed()
	menu.open_team_select_for_campaign()
	
	# Replace GridContainer with VBoxContainer
	var old_grid = menu.team_grid_cards
	var parent_margin = old_grid.get_parent()
	var vbox_container = VBoxContainer.new()
	vbox_container.name = "GridCardsVBox"
	vbox_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox_container.add_theme_constant_override("separation", 12)
	parent_margin.add_child(vbox_container)
	old_grid.visible = false
	
	# Build centered rows of 4 cards
	var current_pool = menu.current_sorted_team_pool
	var row_hbox: HBoxContainer = null
	for i in range(current_pool.size()):
		if i % 4 == 0:
			row_hbox = HBoxContainer.new()
			row_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
			row_hbox.add_theme_constant_override("separation", 10)
			row_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			vbox_container.add_child(row_hbox)
			
		var card = current_pool[i]
		var cid = int(card["id"])
		var p_num = str(card.get("pokedex_num", "1")).pad_zeros(3)
		var type_key = str(card.get("type", "NORMAL")).to_upper()
		var theme = AssembledCardScript.TYPE_THEMES.get(type_key, AssembledCardScript.TYPE_THEMES["NORMAL"])
		
		var cell_vbox = VBoxContainer.new()
		cell_vbox.custom_minimum_size = Vector2(106, 208)
		cell_vbox.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		cell_vbox.add_theme_constant_override("separation", 2)
		cell_vbox.alignment = BoxContainer.ALIGNMENT_BEGIN
		
		var thumb_btn = Button.new()
		thumb_btn.custom_minimum_size = Vector2(106, 136)
		thumb_btn.focus_mode = Control.FOCUS_NONE
		var tex_file = str(card.get("texture_path", card.get("texture_file", "")))
		var pkmn_tex = GameData.get_pokemon_texture(tex_file)
		thumb_btn.icon = pkmn_tex
		thumb_btn.expand_icon = true
		thumb_btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		thumb_btn.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
		
		var badge_panel = PanelContainer.new()
		badge_panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
		badge_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		badge_panel.visible = false
		var badge_lbl = Label.new()
		badge_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		badge_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		badge_lbl.add_theme_font_size_override("font_size", 10)
		badge_panel.add_child(badge_lbl)
		thumb_btn.add_child(badge_panel)
		
		thumb_btn.pressed.connect(func(): menu.toggle_pokemon_selection(cid))
		cell_vbox.add_child(thumb_btn)
		
		var name_lbl = Label.new()
		name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_lbl.add_theme_font_size_override("font_size", 10)
		name_lbl.text = "#%s %s" % [p_num, card.get("short_name", "PKMN")]
		name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		cell_vbox.add_child(name_lbl)
		
		var stats_lbl = Label.new()
		stats_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		stats_lbl.add_theme_font_size_override("font_size", 9)
		stats_lbl.text = "❤️%d HP  👟%d SPD" % [int(card.get("hp", 10)), int(card.get("speed", 1))]
		stats_lbl.add_theme_color_override("font_color", Color(0.75, 0.85, 0.95))
		cell_vbox.add_child(stats_lbl)
		
		var evo_info = GameData.get_pokemon_evolution_chain_status(cid)
		var evo_color = Color(evo_info.get("color_hex", "#78909C"))
		
		var evo_panel = PanelContainer.new()
		evo_panel.mouse_filter = Control.MOUSE_FILTER_PASS
		var evo_sb = StyleBoxFlat.new()
		evo_sb.set_corner_radius_all(3)
		evo_sb.bg_color = evo_color.darkened(0.85)
		evo_sb.border_color = evo_color.darkened(0.4)
		evo_sb.set_border_width_all(1)
		evo_panel.add_theme_stylebox_override("panel", evo_sb)
		
		var evo_lbl = Label.new()
		evo_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		evo_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		evo_lbl.add_theme_font_size_override("font_size", 9)
		evo_lbl.add_theme_color_override("font_color", evo_color)
		evo_lbl.text = evo_info.get("text_badge", "")
		evo_panel.add_child(evo_lbl)
		cell_vbox.add_child(evo_panel)
		
		row_hbox.add_child(cell_vbox)
		
		menu.card_buttons_map[cid] = thumb_btn
		menu.team_card_views_map[cid] = {
			"card": card,
			"btn": thumb_btn,
			"theme": theme,
			"badge_panel": badge_panel,
			"badge_lbl": badge_lbl,
			"name_lbl": name_lbl,
			"stats_lbl": stats_lbl
		}
	
	menu.update_team_select_ui()
	
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.2).timeout
	
	var img = get_viewport().get_texture().get_image()
	img.save_png("C:/Users/rafag/.gemini/antigravity/brain/dca5182f-4733-4c52-8dfc-ccfff3b26dd9/centered_7_cards_screen.png")
	print("Saved centered_7_cards_screen.png successfully! Total cards: ", current_pool.size())
	get_tree().quit(0)
