extends Node

func _ready() -> void:
	print("--- INICIANDO TEST: FRIENDS CARD LAYOUT & CENTERING ---")
	
	var main_menu_scene = load("res://scenes/main_menu.tscn")
	assert(main_menu_scene != null, "scenes/main_menu.tscn no pudo cargarse")
	
	var main_menu = main_menu_scene.instantiate()
	add_child(main_menu)
	
	# Simular datos de búsqueda
	var mock_res1 = {
		"alias": "AmikoRed",
		"email": "amikored@test.com",
		"id": "PKMN-283073",
		"last_activity_at": "2026-11-02T12:00:00Z",
		"is_self": false
	}
	var mock_res_self = {
		"alias": "Tester",
		"email": "tester@test.com",
		"id": "PKMN-000001",
		"last_activity_at": "2026-11-08T22:00:00Z",
		"is_self": true
	}
	
	# Simular datos de amigo
	var mock_friend1 = {
		"alias": "Rafiki",
		"email": "rafiki@test.com",
		"id": "PKMN-123456",
		"last_activity_at": "2026-11-08T16:00:00Z"
	}
	
	var search_card = main_menu._create_search_result_card(mock_res1)
	assert(search_card != null, "search_card no se creo")
	var self_card = main_menu._create_search_result_card(mock_res_self)
	assert(self_card != null, "self_card no se creo")
	var friend_card = main_menu._create_friend_card(mock_friend1)
	assert(friend_card != null, "friend_card no se creo")
	
	main_menu.search_results_vbox.add_child(search_card)
	main_menu.search_results_vbox.add_child(self_card)
	main_menu.friends_list_vbox.add_child(friend_card)
	
	# Forzar actualización de layout
	main_menu.friends_modal.visible = true
	main_menu._show_search_results_tab()
	
	# Verificar min size de las tarjetas
	var search_min_size = search_card.get_combined_minimum_size()
	var self_min_size = self_card.get_combined_minimum_size()
	var friend_min_size = friend_card.get_combined_minimum_size()
	
	print("[LAYOUT] Search Card Min Size: ", search_min_size)
	print("[LAYOUT] Self Card Min Size: ", self_min_size)
	print("[LAYOUT] Friend Card Min Size: ", friend_min_size)
	
	# La anchura utilizable dentro de FriendsBox es 504px (540 - 18 - 18)
	# Cada tarjeta debe tener un min_size.x <= 500px para no desbordar
	assert(search_min_size.x <= 504, "Search card min width excede el ancho utilizable: %f" % search_min_size.x)
	assert(self_min_size.x <= 504, "Self card min width excede el ancho utilizable: %f" % self_min_size.x)
	assert(friend_min_size.x <= 504, "Friend card min width excede el ancho utilizable: %f" % friend_min_size.x)
	
	print("✓ Todas las tarjetas caben holgadamente dentro de los 504px de pantalla!")
	
	# Verificar scroll containers configurados correctamente
	assert(main_menu.friends_content_scroll.horizontal_scroll_mode == ScrollContainer.SCROLL_MODE_DISABLED, "friends_content_scroll no tiene horizontal_scroll_mode disabled")
	assert(main_menu.search_results_scroll.horizontal_scroll_mode == ScrollContainer.SCROLL_MODE_DISABLED, "search_results_scroll no tiene horizontal_scroll_mode disabled")
	print("✓ ScrollContainers correctamente configurados sin scroll horizontal parásito!")
	
	print("--- TEST COMPLETADO EXITOSAMENTE ---")
	get_tree().quit(0)
