extends SceneTree

func _init() -> void:
	var menu_packed = load("res://scenes/main_menu.tscn")
	var menu = menu_packed.instantiate()
	root.add_child(menu)
	
	menu._on_login_play_pressed()
	menu.open_team_select_for_campaign()
	
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
					if sub.get_child_count() > 0:
						for sub2 in sub.get_children():
							if sub2 is Control:
								print("      -> Sub2 [", sub2.name, "] visible=", sub2.visible, " min_size=", sub2.get_combined_minimum_size(), " size=", sub2.size, " pos=", sub2.position)

	quit()
