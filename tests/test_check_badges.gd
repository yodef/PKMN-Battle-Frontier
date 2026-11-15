extends Node

func _ready() -> void:
	print("--- TESTING BADGE TEXTURES ---")
	var regions = {
		"kanto": ["boulder", "cascade", "thunder", "rainbow", "soul", "marsh", "volcano", "earth"],
		"johto": ["zephyr", "hive", "plain", "fog", "storm", "mineral", "glacier", "rising"],
		"hoenn": ["stone", "knuckle", "dynamo", "heat", "balance", "feather", "mind", "rain"],
		"sinnoh": ["coal", "forest", "cobble", "fen", "relic", "mine", "icicle", "beacon"]
	}
	var missing = 0
	for reg in regions:
		for b in regions[reg]:
			var tex = GameData.get_badge_texture(reg, b)
			if tex == null:
				print("MISSING: ", reg, " - ", b)
				missing += 1
			else:
				print("FOUND: ", reg, " - ", b, " -> ", tex.get_size())
	print("TOTAL MISSING: ", missing)
	get_tree().quit(0 if missing == 0 else 1)
