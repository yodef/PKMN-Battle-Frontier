extends Control

func _ready():
	print("--- TESTING BOOSTER PACKS SYSTEM ---")
	
	# Verify textures
	for p_id in ["kanto", "johto", "hoenn", "sinnoh"]:
		var tex = GameData.get_booster_pack_texture(p_id)
		print("Pack: ", p_id, " texture loaded? ", (tex != null))
		assert(tex != null, "Booster pack texture must exist for " + p_id)
		
	var border_tex = GameData.get_booster_pack_border_texture()
	print("Border texture loaded? ", (border_tex != null))
	assert(border_tex != null, "Border texture must exist")
	
	# Verify drop rates per region
	for reg in ["Kanto", "Johto", "Hoenn", "Sinnoh"]:
		var rates = GameData.get_booster_rarity_rates(reg)
		print("Rates for region ", reg, ": ", rates.size(), " rarities")
		assert(rates.size() == 5, "Should have 5 rarity tiers")
		
	# Verify opening packs
	GameData.player_diamonds = 100
	var opened_kanto = GameData.open_booster_pack("kanto", 5)
	print("Opened Kanto: ", opened_kanto.size(), " cards")
	assert(opened_kanto.size() == 3, "Must return 3 cards")
	for c in opened_kanto:
		print("  - Kanto card: ", c.get("name"), " [", c.get("region"), "]")
		assert(str(c.get("region", "")).to_lower() == "kanto", "Card must be from Kanto")
		
	var opened_johto = GameData.open_booster_pack("johto", 5)
	print("Opened Johto: ", opened_johto.size(), " cards")
	assert(opened_johto.size() == 3, "Must return 3 cards")
	for c in opened_johto:
		print("  - Johto card: ", c.get("name"), " [", c.get("region"), "]")
		assert(str(c.get("region", "")).to_lower() == "johto", "Card must be from Johto")
		
	print("All logic tests passed! Capturing visual preview...")
	
	# Build preview UI
	var bg = ColorRect.new()
	bg.color = Color("#0B0E14")
	bg.set_anchors_preset(PRESET_FULL_RECT)
	add_child(bg)
	
	var scroll = ScrollContainer.new()
	scroll.set_anchors_preset(PRESET_FULL_RECT)
	add_child(scroll)
	
	var main_vbox = VBoxContainer.new()
	main_vbox.size_flags_horizontal = SIZE_EXPAND_FILL
	main_vbox.add_theme_constant_override("separation", 16)
	scroll.add_child(main_vbox)
	
	var title = Label.new()
	title.text = "📦 REGIONAL BOOSTER PACKS PREVIEW"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", Color("#FFD700"))
	main_vbox.add_child(title)
	
	var row = HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 16)
	main_vbox.add_child(row)
	
	for p_id in ["kanto", "johto", "hoenn", "sinnoh"]:
		var p_info = GameData.BOOSTER_PACKS[p_id]
		var pack_card = _create_preview_pack(p_id, p_info)
		row.add_child(pack_card)
		
	await get_tree().create_timer(0.1).timeout
	print("✅ All tests passed successfully!")
	get_tree().quit()

func _create_preview_pack(p_id: String, p_info: Dictionary) -> Control:
	var w = 150
	var h = 230
	var crimp_h = 14
	var accent: Color = p_info.get("accent_color", Color("#FFD700"))
	
	var outer = VBoxContainer.new()
	outer.add_theme_constant_override("separation", 6)
	outer.alignment = BoxContainer.ALIGNMENT_CENTER
	
	var pack_card = PanelContainer.new()
	pack_card.custom_minimum_size = Vector2(w, h)
	pack_card.clip_contents = true
	
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.04, 0.05, 0.08, 0.98)
	sb.border_color = accent
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(8)
	sb.content_margin_left = 3
	sb.content_margin_right = 3
	sb.content_margin_top = 3
	sb.content_margin_bottom = 3
	pack_card.add_theme_stylebox_override("panel", sb)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)
	vbox.size_flags_horizontal = SIZE_EXPAND_FILL
	vbox.size_flags_vertical = SIZE_EXPAND_FILL
	pack_card.add_child(vbox)
	
	var top_crimp = TextureRect.new()
	top_crimp.custom_minimum_size = Vector2(w - 6, crimp_h)
	top_crimp.texture = GameData.get_booster_pack_border_texture()
	top_crimp.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	top_crimp.stretch_mode = TextureRect.STRETCH_TILE
	top_crimp.modulate = accent.lerp(Color.WHITE, 0.35)
	vbox.add_child(top_crimp)
	
	var art_container = PanelContainer.new()
	art_container.size_flags_horizontal = SIZE_EXPAND_FILL
	art_container.size_flags_vertical = SIZE_EXPAND_FILL
	art_container.clip_contents = true
	
	var art_rect = TextureRect.new()
	art_rect.texture = GameData.get_booster_pack_texture(p_id)
	art_rect.size_flags_horizontal = SIZE_EXPAND_FILL
	art_rect.size_flags_vertical = SIZE_EXPAND_FILL
	art_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	art_container.add_child(art_rect)
	
	vbox.add_child(art_container)
	
	var bot_crimp = TextureRect.new()
	bot_crimp.custom_minimum_size = Vector2(w - 6, crimp_h)
	bot_crimp.texture = GameData.get_booster_pack_border_texture()
	bot_crimp.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bot_crimp.stretch_mode = TextureRect.STRETCH_TILE
	bot_crimp.modulate = accent.lerp(Color.WHITE, 0.35)
	vbox.add_child(bot_crimp)
	
	outer.add_child(pack_card)
	
	var lbl = Label.new()
	lbl.text = p_info["name"]
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 12)
	lbl.add_theme_color_override("font_color", accent)
	outer.add_child(lbl)
	
	var reg_lbl = Label.new()
	reg_lbl.text = "📍 " + p_info["region"]
	reg_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	reg_lbl.add_theme_font_size_override("font_size", 10)
	reg_lbl.add_theme_color_override("font_color", Color("#90A4AE"))
	outer.add_child(reg_lbl)
	
	var btn = Button.new()
	btn.text = "Cost: %d 💎" % p_info["cost"]
	btn.custom_minimum_size = Vector2(100, 28)
	btn.size_flags_horizontal = SIZE_SHRINK_CENTER
	btn.add_theme_font_size_override("font_size", 11)
	btn.add_theme_color_override("font_color", Color("#2ecc71"))
	outer.add_child(btn)
	
	return outer
