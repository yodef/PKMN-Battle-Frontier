extends SceneTree

func _init():
	print("--- Running Comprehensive Localization Test Suite ---")
	var loc = load("res://scripts/localization.gd")

	# Test 1: Ground / Gronda Regression
	print("\n[Test 1] Ground / Gronda Regression...")
	var ground_tests = ["GROUND", "Ground", "• GROUND Type", "Immune to GROUND type attacks.", "GROUND moves"]
	for gt in ground_tests:
		var es = loc.translate_en_to_es(gt)
		if "gronda" in es.to_lower():
			printerr("❌ FAIL: Gronda detected in '%s' -> '%s'" % [gt, es])
			quit(1)
			return
		print("  ✔ '%s' -> '%s'" % [gt, es])

	# Test 2: Combat Log & Move Descriptions ("increase 3 daño", etc.)
	print("\n[Test 2] Combat Log & Move Descriptions Translation...")
	var combat_and_move_samples = [
		{"en": "Use 1 extra energy to increase +3 DMG to this Move.", "expected": "Usa 1 energía extra para aumentar +3 DMG a este movimiento."},
		{"en": "If this PKMN is faster than its foe, increase +3 DMG to this Move.", "expected": "Si este PKMN es más rápido que su rival, aumenta +3 DMG a este movimiento."},
		{"en": "If foes PKMN has BURN, increase +3 DMG to this Move.", "expected": "Si el PKMN rival está QUEMADO, aumenta +3 DMG a este movimiento."},
		{"en": "In the next round, increase +2 Speed to this PKMN.", "expected": "En la siguiente ronda, aumenta +2 de Velocidad a este PKMN."},
		{"en": "This PKMN recovers HP equal to 50% of the DMG dealt by this Move.", "expected": "Este PKMN recupera HP igual al 50% del daño causado por este movimiento."},
		{"en": "Boost increases damage by +4.", "expected": "Boost aumenta el daño en +4."},
		{"en": "Light Screen shattered and dealt 4 counter DMG!", "expected": "¡Pantalla de Luz se rompió y causó 4 DMG de contraataque!"},
		{"en": "Reflect evaded attack and dealt 3 counter DMG!", "expected": "¡Reflejo evadió el ataque y causó 3 DMG de contraataque!"},
		{"en": "Charm reduces 1 Normal DMG!", "expected": "¡Encanto reduce 1 DMG Normal!"},
		{"en": "Focus Energy (+1 DMG for higher SPD)!", "expected": "¡Foco Energía (+1 DMG por mayor VEL)!"},
		{"en": "Inflicted BURN (2 rounds, 2 DMG per round)!", "expected": "¡Provocó QUEMADURA (2 rondas, 2 DMG por ronda)!"},
		{"en": "Inflicted FREEZE (foe cannot move, max 2 rounds or thaw on Fire)!", "expected": "¡Provocó CONGELAMIENTO (el rival no puede moverse, máx 2 rondas o fuego)!"},
		{"en": "Inflicted PARALYZE (25% chance cannot act, 2 rounds)!", "expected": "¡Provocó PARÁLISIS (25% prob. de no actuar, 2 rondas)!"},
		{"en": "Rival [b]Squirtle[/b] triggered passive [color=cyan]Turtle Shell[/color] dealing [b]4[/b] damage and gaining [b]+2 Speed[/b] for next round!", "expected": "Rival [b]Squirtle[/b] activó la pasiva [color=cyan]Caparazón Tortuga[/color] causando [b]4[/b] de daño y ganando [b]+2 de Velocidad[/b] para la próxima ronda!"},
		{"en": "[b]Pikachu[/b] used [color=cyan]Thunder Shock[/color], but it [color=red]missed completely![/color] (Refunded 1 Energy⚡)", "expected": "[b]Pikachu[/b] usó [color=cyan]Thunder Shock[/color], ¡pero [color=red]falló por completo![/color] (1 Energía⚡ reembolsada)"}
	]

	for item in combat_and_move_samples:
		var es = loc.translate_en_to_es(item["en"])
		if es != item["expected"]:
			printerr("❌ FAIL: Translation mismatch:\n  EN: '%s'\n  GOT: '%s'\n  EXPECTED: '%s'" % [item["en"], es, item["expected"]])
			quit(1)
			return
		print("  ✔ '%s'\n     -> '%s'" % [item["en"], es])

	# Test 3: Bidirectional Translation (ES -> EN)
	print("\n[Test 3] Bidirectional Translation (ES -> EN)...")
	var reverse_samples = [
		{"es": "Resistencia:", "expected": "Resistance:"},
		{"es": "Siguiente ▶", "expected": "Next ▶"},
		{"es": "◀ Anterior", "expected": "◀ Previous"},
		{"es": "Buscar por Alias, Google Email o ID...", "expected": "Search by Alias, Google Email or ID..."},
		{"es": "⏳ Se reinicia diariamente a las 00:00", "expected": "⏳ Resets daily at 00:00"},
		{"es": "⚔️ Esperando a que el rival esté LISTO...", "expected": "⚔️ Waiting for rival to be READY..."},
		{"es": "✨ Rareza", "expected": "✨ Rarity"},
		{"es": "⭐ Obtenidas", "expected": "⭐ Owned"},
		{"es": "🎒 Editar Equipo", "expected": "🎒 Edit Team"},
		{"es": "🎒 Tu Equipo:", "expected": "🎒 Your Team:"},
		{"es": "🎯 Misiones de Hoy", "expected": "🎯 Today's Missions"},
		{"es": "TIERRA", "expected": "GROUND"},
		{"es": "FUEGO", "expected": "FIRE"},
		{"es": "AGUA", "expected": "WATER"},
		{"es": "PLANTA", "expected": "GRASS"},
		{"es": "ELÉCTRICO", "expected": "ELECTRIC"}
	]

	for r in reverse_samples:
		var en = loc.translate_es_to_en(r["es"])
		if en != r["expected"]:
			printerr("❌ FAIL: Bidirectional mismatch: '%s' expected '%s', got '%s'" % [r["es"], r["expected"], en])
			quit(1)
			return
		print("  ✔ '%s' -> '%s'" % [r["es"], en])

	print("\n🎉 ALL LOCALIZATION TESTS PASSED PERFECTLY WITH ZERO MISMATCHES!")
	quit(0)
