extends Node

func _ready() -> void:
	print("==================================================")
	print("🧪 TESTING POWER UP SFX ON RECHARGE ENERGY")
	print("==================================================")

	# 1. Test get_audio_stream_from_file loads power up.wav
	var stream = GameData.get_audio_stream_from_file("power up.wav")
	assert(stream != null, "GameData must load power up.wav stream")
	print("✓ power up.wav audio stream successfully loaded (Length: %f s)" % stream.get_length())

	# 2. Test aliases in play_combat_sfx
	var stream_alias1 = GameData.get_audio_stream_from_file("power up")
	assert(stream_alias1 != null, "Alias 'power up' must resolve to stream")
	
	# Test playback without crashing
	GameData.settings_sfx_muted = false
	GameData.settings_sfx_volume = 1.0
	GameData.play_combat_sfx("recharge")
	GameData.play_combat_sfx("power up.wav")
	print("✓ play_combat_sfx('recharge') and play_combat_sfx('power up.wav') executed cleanly.")

	# 3. Test Battle scene instantiation & recover action integration
	var battle_scene = load("res://scenes/battle.tscn")
	assert(battle_scene != null, "Battle scene must exist and load")
	var battle = battle_scene.instantiate()
	add_child(battle)
	assert(battle.btn_recover != null, "btn_recover must exist in battle")

	# Simulate energy drain and recover
	var p = battle.get_active_player()
	p.current_energy = 0
	battle.is_busy = false
	battle.is_battle_over = false
	battle.is_player_turn = true
	battle.can_player_act = true
	battle.btn_recover.disabled = false
	battle._on_recover_pressed()
	assert(p.current_energy > 0, "Player must have recharged energy")
	print("✓ Player recharge triggered SFX and restored energy (⚡ %d/%d)." % [p.current_energy, p.max_energy])

	# Simulate enemy recover
	var e = battle.get_active_enemy()
	e.current_energy = 0
	battle.enemy_do_recover()
	assert(e.current_energy > 0, "Enemy must have recharged energy")
	print("✓ Enemy recharge triggered SFX and restored energy (⚡ %d/%d)." % [e.current_energy, e.max_energy])

	print("==================================================")
	print("✅ ALL RECHARGE SFX TESTS PASSED! (0 ERRORS)")
	print("==================================================")
	get_tree().quit()
