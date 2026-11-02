extends SceneTree

func _init() -> void:
	print("--- Running Paralyze FX Test ---")
	
	# 1. Verify textures exist and are loaded
	var frames = StatusFXOverlay.PARALYZE_FRAMES
	assert(frames.size() == 4, "Expected 4 paralyze frames")
	for i in range(frames.size()):
		var tex = frames[i]
		assert(tex != null, "Texture frame %d should not be null" % i)
		print("Frame %d size: %s" % [i, tex.get_size()])
		assert(tex.get_width() == 36 and tex.get_height() == 26, "Expected 36x26 frame")
	print("SUCCESS: All 4 paralyze frames loaded correctly with dimensions 36x26.")

	# 2. Test StatusFXOverlay behavior
	var overlay = StatusFXOverlay.new()
	root.add_child(overlay)
	overlay._ready()
	
	# Mock Pokemon with paralyze
	var GameDataClass = preload("res://scripts/game_data.gd")
	var p = GameDataClass.PokemonData.new()
	p.name = "Pikachu"
	p.current_hp = 30
	p.max_hp = 30
	p.is_paralyzed = true
	p.paralyze_turns = 2
	
	# Update statuses on idle
	overlay.update_statuses(p)
	assert(overlay.paralyze_rect.visible == false, "Paralyze overlay should NOT be visible during idle/passive turn")
	print("SUCCESS: Paralyze overlay remains invisible when idle.")

	# Simulate 1 second of idle process
	for i in range(10):
		overlay._process(0.1)
	assert(overlay.paralyze_rect.visible == false, "Paralyze overlay should remain invisible during idle processing")
	print("SUCCESS: Idle processing does not show paralyze animation.")

	# 3. Trigger Paralyze Effect
	overlay.trigger_paralyze_effect(1.0)
	assert(overlay.paralyze_rect.visible == true, "Paralyze rect should become visible on trigger")
	assert(overlay.paralyze_active_timer == 1.0, "Paralyze timer should be initialized to 1.0")
	print("SUCCESS: Paralyze effect triggered successfully.")

	# Advance 0.08s -> next frame
	overlay._process(0.08)
	assert(overlay.paralyze_frame_idx == 1, "Expected frame 1 after 0.08s, got %d" % overlay.paralyze_frame_idx)
	assert(overlay.paralyze_rect.texture == frames[1], "Texture should match frame 1")
	print("SUCCESS: Paralyze frame transitioned to frame 1.")

	# Advance until end of effect
	overlay._process(1.0)
	assert(overlay.paralyze_rect.visible == false, "Paralyze rect should become invisible after timer expires")
	print("SUCCESS: Paralyze effect automatically hidden after duration.")

	overlay.queue_free()
	print("--- All Paralyze Unit Checks Passed! ---")
	quit(0)
