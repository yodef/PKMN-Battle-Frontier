extends SceneTree

func _init():
	print("--- Running Ground Translation Regression Test ---")
	var loc = load("res://scripts/localization.gd")
	var test_cases = [
		{"input": "GROUND", "expected": "TIERRA"},
		{"input": "Ground", "expected": "Tierra"},
		{"input": "GROUND Type", "expected": "Tipo TIERRA"},
		{"input": "GROUND type", "expected": "tipo TIERRA"},
		{"input": "Ground Type", "expected": "Tipo Tierra"},
		{"input": "No. 095 • GROUND Type", "expected": "No. 095 • Tipo TIERRA"},
		{"input": "#095 • GROUND", "expected": "#095 • TIERRA"},
		{"input": "Immune to GROUND type attacks.", "expected": "Inmune a ataques de tipo TIERRA."},
		{"input": "Non-GROUND type PKMN will take 2 DMG at the start of each round for 3 rounds.", "expected": "PKMN que no sean tipo TIERRA will take 2 DMG at the start de each round for 3 rounds."},
		{"input": "During the next 2 rounds, if this PKMN uses a GROUND move, it deals +4 extra DMG.", "expected": "During the next 2 rounds, if this PKMN uses a movimiento TIERRA, it causa +4 extra DMG."},
		{"input": "Boosts FIRE & GROUND moves by 2 DMG.", "expected": "Aumenta movimientos FUEGO y TIERRA en +2 DMG."},
		{"input": "ROUND 1", "expected": "RONDA 1"},
		{"input": "ROUND 5 (Pikachu starts)", "expected": "RONDA 5 (Pikachu starts)"},
		{"input": "[b]━━━ ROUND 3 ━━━[/b]", "expected": "[b]━━━ RONDA 3 ━━━[/b]"}
	]

	var all_passed = true
	for tc in test_cases:
		var res = loc.translate_en_to_es(tc["input"])
		if "gronda" in res.to_lower():
			print("❌ FAILED: Detected 'gronda' in '%s' -> '%s'" % [tc["input"], res])
			all_passed = false
		if res != tc["expected"]:
			print("❌ Mismatch: '%s' expected '%s', got '%s'" % [tc["input"], tc["expected"], res])
			all_passed = false

	if all_passed:
		print("✅ ALL GROUND TRANSLATION REGRESSION TESTS PASSED (0 'GRONDA' OCCURRENCES)!")
		quit(0)
	else:
		print("❌ REGRESSION DETECTED!")
		quit(1)
