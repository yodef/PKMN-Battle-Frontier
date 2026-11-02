extends SceneTree

func _init() -> void:
	var btn = Button.new()
	btn.add_theme_font_size_override("font_size", 15)
	btn.text = "Choose 1 to 3 BASIC Pokémon for Tournament"
	print("Btn min size with 'Choose 1 to 3...': ", btn.get_combined_minimum_size())
	
	btn.text = "✅ CONFIRM TOURNAMENT TEAM (3 PKMN)"
	print("Btn min size with 'CONFIRM...': ", btn.get_combined_minimum_size())
	
	btn.text = "⚔️ START 2-PLAYER BATTLE (3 vs 3)!"
	print("Btn min size with 'START 2-PLAYER...': ", btn.get_combined_minimum_size())
	
	# What about Subtitle without newline?
	var lbl = Label.new()
	lbl.add_theme_font_size_override("font_size", 12)
	lbl.text = "Choose 1 to 3 BASIC Pokémon (Legendaries banned). ⬆️ icons show evolutions ready in your collection!"
	print("Subtitle min size (no autowrap): ", lbl.get_combined_minimum_size())
	
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	print("Subtitle min size (autowrap SMART, no custom min): ", lbl.get_combined_minimum_size())

	quit()
