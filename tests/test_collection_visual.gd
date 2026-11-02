extends Node

func _ready() -> void:
	print("=== DEBUG VISUAL COLECCIÓN ===")
	var menu = load("res://scenes/main_menu.tscn").instantiate()
	add_child(menu)
	
	print("GameData.all_pokemon_ids: ", GameData.all_pokemon_ids)
	print("GameData.player_unlocked_ids: ", GameData.player_unlocked_ids)
	
	menu._on_collection_pressed()
	
	var grid_view = menu.get_node("CollectionModal/GridView")
	var detail_view = menu.get_node("CollectionModal/DetailView")
	var grid_cards = menu.get_node("CollectionModal/GridView/GridScroll/GridMargin/GridCards")
	
	print("GridView visible: ", grid_view.visible)
	print("DetailView visible: ", detail_view.visible)
	print("Total cards en grid: ", grid_cards.get_child_count())
	
	for i in range(grid_cards.get_child_count()):
		var cell = grid_cards.get_child(i)
		var btn = cell.get_child(0) as Button
		var lbl = cell.get_child(1) as Label
		print("Card %d: btn_text='%s' | btn_icon=%s | lbl_text='%s'" % [i, btn.text, "SI" if btn.icon else "NO", lbl.text.replace("\n", " ")])
		
	# Ahora probamos abrir el detalle de la carta 0
	print("\n--- Abriendo Detalle de Carta 0 (Bulbasaur) ---")
	menu.open_collection_detail(0)
	print("GridView visible: ", grid_view.visible)
	print("DetailView visible: ", detail_view.visible)
	
	var assembled_card = menu.get_node("CollectionModal/DetailView/MainHBox/AssembledCard")
	var name_lbl = assembled_card.get_node("CardPanel/Margin/VBox/HeaderHBox/NameLabel")
	var sprite_rect = assembled_card.get_node("CardPanel/Margin/VBox/ArtFrame/SpriteRect")
	print("AssembledCard Name: ", name_lbl.text)
	print("AssembledCard Sprite texture: ", sprite_rect.texture)
	
	get_tree().quit(0)
