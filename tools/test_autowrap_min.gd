extends SceneTree

func _init() -> void:
	var lbl = Label.new()
	lbl.add_theme_font_size_override("font_size", 12)
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.text = "Choose 1 to 3 BASIC Pokémon (Legendaries banned). ⬆️ icons show evolutions ready in your collection!"
	print("Before custom_minimum_size: ", lbl.get_combined_minimum_size())
	
	lbl.custom_minimum_size = Vector2(1, 0)
	print("With custom_minimum_size = Vector2(1, 0): ", lbl.get_combined_minimum_size())

	quit()
