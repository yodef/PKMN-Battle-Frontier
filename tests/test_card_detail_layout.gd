extends Node

func _ready() -> void:
	call_deferred("_run_tests")

func _run_tests() -> void:
	print("=======================================================")
	print("🧪 TEST: CARD DETAIL VIEW LAYOUT & HORIZONTAL SIZING")
	print("=======================================================")

	var main_scene_res = load("res://scenes/main_menu.tscn")
	if not main_scene_res:
		print("❌ FAILED to load res://scenes/main_menu.tscn")
		get_tree().quit(1)
		return

	var main_menu = main_scene_res.instantiate()
	add_child(main_menu)
	await get_tree().process_frame
	await get_tree().process_frame

	GameData.unlock_pokemon(8) # Wartortle
	GameData.set_active_campaign_gold(1500)

	# 1. Abrir Colección y Detalle de Carta
	main_menu._on_collection_pressed()
	await get_tree().process_frame

	main_menu.open_collection_detail(7) # Wartortle
	await get_tree().process_frame
	await get_tree().process_frame

	var dv = main_menu.collection_detail_view
	if not dv:
		print("❌ FAILED: collection_detail_view is null!")
		get_tree().quit(1)
		return

	var vp_size = dv.get_viewport_rect().size
	print("Viewport size: ", vp_size)
	print("DetailView size: ", dv.size)
	print("DetailView global_pos: ", dv.global_position)

	# El ancho de DetailView no debe exceder 440px en 540 viewport (debe estar entre 410px y 435px)
	if dv.size.x > 440.0:
		print("❌ FAILED: DetailView width is too wide! Size: ", dv.size)
		get_tree().quit(1)
		return
	print("✅ DetailView width correctly constrained: ", dv.size.x, " px")

	# Debe estar centrado
	var expected_x = (vp_size.x - dv.size.x) * 0.5
	if abs(dv.global_position.x - expected_x) > 3.0:
		print("❌ FAILED: DetailView is not centered! Position x=", dv.global_position.x, " expected=", expected_x)
		get_tree().quit(1)
		return
	print("✅ DetailView is horizontally centered at x=", dv.global_position.x)

	# 2. Verificar que los paneles internos se ajusten correctamente al ancho
	var db = dv.get_node("DetailsScroll/DetailsBox")
	print("DetailsBox size: ", db.size)
	for child in db.get_children():
		if child is Control and child.visible:
			var min_s = child.get_combined_minimum_size()
			print(" - Panel: ", child.name, " size: ", child.size, " min_size: ", min_s)
			if min_s.x > 430.0:
				print("❌ FAILED: Panel ", child.name, " min_size.x exceeds 430px! min_s=", min_s)
				get_tree().quit(1)
				return
	print("✅ All detail panels respect the constrained width without stretching!")

	# 3. Test desde Selección de Equipo
	dv.visible = false
	main_menu.collection_modal.visible = false
	main_menu.open_card_detail_from_team_select(8) # Wartortle ID
	await get_tree().process_frame
	await get_tree().process_frame

	if not dv.visible:
		print("❌ FAILED: DetailView did not open from team select!")
		get_tree().quit(1)
		return
	if dv.size.x > 440.0:
		print("❌ FAILED: DetailView from team select is too wide! Size: ", dv.size)
		get_tree().quit(1)
		return
	print("✅ Team Select card inspection correctly constrained to width: ", dv.size.x)

	# Regresar a selección de equipo
	main_menu._on_back_to_grid_pressed()
	await get_tree().process_frame
	if not main_menu.team_select_modal.visible:
		print("❌ FAILED: Did not return to team select modal!")
		get_tree().quit(1)
		return
	print("✅ Returned to team select modal cleanly!")

	print("=======================================================")
	print("🎉 ALL CARD DETAIL LAYOUT TESTS PASSED!")
	print("=======================================================")
	get_tree().quit(0)
