@tool
extends SceneTree

func _init():
	print("--- AUDITING POKEMON CARD TEXTURES ---")
	var file = FileAccess.open("res://data/poke_stats.csv", FileAccess.READ)
	if not file:
		print("ERROR: could not open res://data/poke_stats.csv")
		quit(1)
		return

	var header = file.get_csv_line()
	var col_map = {}
	for i in range(header.size()):
		col_map[header[i].strip_edges().to_lower()] = i

	var missing_count = 0
	var total_count = 0

	while not file.eof_reached():
		var row = file.get_csv_line()
		if row.size() < 4 or row[0].strip_edges() == "":
			continue

		var get_val = func(col_name: String, default_val: String = "") -> String:
			var key = col_name.to_lower()
			if col_map.has(key):
				var idx = col_map[key]
				if idx < row.size():
					var v = row[idx].strip_edges()
					if v != "":
						return v
			return default_val

		var raw_name = get_val.call("name", "")
		if raw_name == "":
			continue

		total_count += 1
		var pkmn_id = get_val.call("id", "0")
		var p_num = get_val.call("pokedex_num", "1")
		var p_tex = get_val.call("texture_file", "")
		if p_tex == "":
			p_tex = "%s.png" % str(p_num).pad_zeros(3)

		var res_path = "res://assets/cards/" + p_tex
		var exists = ResourceLoader.exists(res_path) or FileAccess.file_exists(res_path)

		if not exists:
			missing_count += 1
			print("MISSING [%s] #%s %s -> '%s'" % [pkmn_id, p_num, raw_name, p_tex])
			# Check if alternative exists (like dex.png or stripping prefix)
			var alt1 = "res://assets/cards/%s.png" % str(p_num).pad_zeros(3)
			var alt2 = "res://assets/cards/%s.png" % str(int(p_num))
			var alt1_exists = ResourceLoader.exists(alt1) or FileAccess.file_exists(alt1)
			var alt2_exists = ResourceLoader.exists(alt2) or FileAccess.file_exists(alt2)
			print("   Candidates: alt1(%s)=%s, alt2(%s)=%s" % [alt1, alt1_exists, alt2, alt2_exists])

	print("--- AUDIT COMPLETE: %d missing out of %d Pokemon ---" % [missing_count, total_count])
	quit(0)
