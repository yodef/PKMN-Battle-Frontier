extends Node

func _ready() -> void:
	print("==================================================")
	print("🧪 RUNNING DRAG-TO-SCROLL & GESTURE TEST SUITE")
	print("==================================================")

	# 1. Test GameData API presence
	assert(GameData.has_method("is_drag_scrolling"), "GameData must have is_drag_scrolling()")
	assert(GameData.has_method("find_scroll_container_at_pos"), "GameData must have find_scroll_container_at_pos()")
	print("✓ GameData drag scroll methods verified.")

	# 2. Build mock UI with ScrollContainer and Buttons
	var root = Control.new()
	root.name = "TestRoot"
	root.size = Vector2(540, 960)
	add_child(root)

	var scroll = ScrollContainer.new()
	scroll.name = "MockScroll"
	scroll.position = Vector2(50, 50)
	scroll.size = Vector2(400, 500)
	root.add_child(scroll)

	var vbox = VBoxContainer.new()
	scroll.add_child(vbox)

	var click_box = [0]
	var card_btn = Button.new()
	card_btn.name = "MockCardBtn"
	card_btn.custom_minimum_size = Vector2(300, 100)
	card_btn.pressed.connect(func():
		if GameData.is_drag_scrolling():
			return
		click_box[0] += 1
	)
	vbox.add_child(card_btn)

	for i in range(20):
		var item = Button.new()
		item.custom_minimum_size = Vector2(300, 50)
		vbox.add_child(item)

	await get_tree().process_frame
	await get_tree().process_frame

	# 3. Test ScrollContainer lookup at point
	var found = GameData.find_scroll_container_at_pos(Vector2(100, 100))
	assert(found == scroll, "find_scroll_container_at_pos must find MockScroll under (100, 100)")
	print("✓ ScrollContainer lookup under cursor passed.")

	# 4. Test Clean Click (No Drag)
	# Down event
	var ev_down = InputEventMouseButton.new()
	ev_down.button_index = MOUSE_BUTTON_LEFT
	ev_down.pressed = true
	ev_down.position = Vector2(100, 100)
	GameData._input(ev_down)
	assert(not GameData.is_drag_scrolling(), "Drag scrolling must not be active immediately on down")

	# Up event without motion
	var ev_up = InputEventMouseButton.new()
	ev_up.button_index = MOUSE_BUTTON_LEFT
	ev_up.pressed = false
	ev_up.position = Vector2(100, 100)
	GameData._input(ev_up)
	assert(not GameData.is_drag_scrolling(), "Drag scrolling must not be active on clean tap")

	card_btn.pressed.emit()
	assert(click_box[0] == 1, "Clean tap must trigger button click")
	print("✓ Clean tap without drag triggers selection normally.")

	# 5. Test Drag Gesture (Down, Motion > Threshold, Up)
	GameData._input(ev_down)

	var ev_motion = InputEventMouseMotion.new()
	ev_motion.position = Vector2(100, 50) # Moved 50px up
	GameData._input(ev_motion)

	assert(GameData.is_drag_scrolling(), "Drag scrolling must be active after moving past threshold")
	assert(scroll.scroll_vertical == 50, "ScrollContainer must have slid 50px vertically")
	print("✓ Real-time screen sliding during drag verified. scroll_vertical =", scroll.scroll_vertical)

	GameData._input(ev_up)
	assert(GameData.is_drag_scrolling(), "Cooldown window must keep is_drag_scrolling() active right after release")

	# Button should NOT fire click
	card_btn.pressed.emit()
	assert(click_box[0] == 1, "Button click must be suppressed after drag")
	print("✓ Accidental selection suppressed on drag release.")

	# 6. Test Cooldown expiration
	await get_tree().create_timer(0.22).timeout
	assert(not GameData.is_drag_scrolling(), "Cooldown must expire after 180ms")
	card_btn.pressed.emit()
	assert(click_box[0] == 2, "Normal click allowed again after cooldown")
	print("✓ Normal click restored after cooldown.")

	print("==================================================")
	print("✅ ALL DRAG-TO-SCROLL TESTS PASSED! (0 ERRORS)")
	print("==================================================")
	get_tree().quit()
