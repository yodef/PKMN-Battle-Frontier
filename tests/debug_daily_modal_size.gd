extends Node

func _ready() -> void:
	print("\n=== VERIFYING DAILY MODAL RESPONSIVE BOUNDARIES ===")
	var menu_scene = load("res://scenes/main_menu.tscn").instantiate()
	add_child(menu_scene)
	await get_tree().process_frame
	
	menu_scene._on_daily_missions_pressed()
	await get_tree().process_frame
	
	var dm = menu_scene.find_child("DailyModal", true, false) as Control
	var db = menu_scene.find_child("DailyBox", true, false) as Control
	
	print("--- TEST 1: Default Viewport (540 x 960) ---")
	print("DailyModal size: ", dm.size)
	print("DailyBox position: ", db.position, " size: ", db.size, " right edge: ", db.position.x + db.size.x)
	assert(db.position.x >= 0, "DailyBox left edge must not be negative!")
	assert(db.position.x + db.size.x <= 540, "DailyBox right edge must NOT exceed 540px! Right edge: %f" % (db.position.x + db.size.x))
	print("✅ Test 1 PASSED: DailyBox is perfectly bounded inside 540px width (left=%f, right=%f)!" % [db.position.x, db.position.x + db.size.x])
	
	print("\n--- TEST 2: Wide Control Container (1280 x 720) ---")
	dm.size = Vector2(1280, 720)
	await get_tree().process_frame
	print("DailyModal size: ", dm.size)
	print("DailyBox position: ", db.position, " size: ", db.size, " right edge: ", db.position.x + db.size.x)
	assert(db.size.x <= 500, "DailyBox on wide screen must NOT stretch infinitely! Size.x: %f" % db.size.x)
	var center_x = db.position.x + (db.size.x * 0.5)
	print("DailyBox center_x: ", center_x, " (Expected 640.0)")
	assert(abs(center_x - 640.0) < 2.0, "DailyBox must remain centered horizontally at 640!")
	print("✅ Test 2 PASSED: DailyBox maintains fixed width 490px and perfect horizontal centering on wide screens!")
	
	menu_scene.queue_free()
	print("\n=== ALL RESPONSIVE TESTS PASSED SUCCESSFULLY! ===")
	get_tree().quit(0)
