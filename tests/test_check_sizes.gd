extends Node

func _ready() -> void:
	var menu_packed = load("res://scenes/main_menu.tscn")
	var menu = menu_packed.instantiate()
	add_child(menu)
	
	menu._on_login_play_pressed()
	menu.open_team_select_for_campaign()
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	var modal = menu.team_select_modal
	var box = modal.get_node("Box")
	
	print("\n=== MINIMUM SIZES IN TEAM SELECT MODAL ===")
	print("Modal min size: ", modal.get_combined_minimum_size())
	print("Box min size: ", box.get_combined_minimum_size())
	print("Box rect: ", box.get_rect())
	
	for child in box.get_children():
		print("Child [", child.name, "] visible=", child.visible, " min_size=", child.get_combined_minimum_size(), " size=", child.size, " pos=", child.position)
		if child.get_child_count() > 0:
			for sub in child.get_children():
				if sub is Control:
					print("   -> Sub [", sub.name, "] visible=", sub.visible, " min_size=", sub.get_combined_minimum_size(), " size=", sub.size, " pos=", sub.position)

	get_tree().quit(0)
