extends Node

func _ready() -> void:
	var menu = load("res://scenes/main_menu.tscn").instantiate()
	add_child(menu)
	menu._on_collection_pressed()
	
	var grid_cards = menu.get_node("CollectionModal/GridView/GridScroll/GridMargin/GridCards")
	var cell0 = grid_cards.get_child(0)
	var btn0 = cell0.get_child(0) as Button
	
	print("btn0 mouse_filter: ", btn0.mouse_filter)
	print("btn0 is_disabled: ", btn0.disabled)
	print("btn0 visible: ", btn0.is_visible_in_tree())
	
	var grid_view = menu.get_node("CollectionModal/GridView")
	var detail_view = menu.get_node("CollectionModal/DetailView")
	
	# Simular click
	btn0.emit_signal("pressed")
	print("After pressed:")
	print("GridView visible: ", grid_view.visible)
	print("DetailView visible: ", detail_view.visible)
	
	get_tree().quit(0)
