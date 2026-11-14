extends Node

func _ready() -> void:
	print("--- INICIANDO TEST: DIFERENCIACIÓN DE MOVIMIENTOS CLÓNICOS ---")
	test_clonic_moves()
	print("--- TODOS LOS TESTS PASARON EXITOSAMENTE ---")
	get_tree().quit(0)

func get_test_move(move_name: String) -> GameData.MoveData:
	var d = GameData.get_move_data(move_name)
	var m = GameData.MoveData.new(
		d["name"], d["type"], d["dmg"], d["cost"], d["req"],
		d["boost_cost"] > 0, d["boost_cost"], d["boost_dmg"],
		d["effect_type"] == "BURN", d["desc"]
	)
	m.effect_type = d["effect_type"]
	m.reduces_foe_speed = (m.effect_type == "SLOW_FOE")
	m.is_pichu_shock = (m.effect_type == "PICHU_SHOCK")
	m.causes_poison = (m.effect_type == "POISON_IF_FASTER" or m.effect_type == "POISON")
	return m

func test_clonic_moves() -> void:
	var battle_scene = load("res://scenes/battle.tscn")
	var battle = battle_scene.instantiate()
	add_child(battle)
	
	# Instanciar Pokémon de prueba
	# 1. Test Surf (BENCH_DAMAGE)
	var blastoise = GameData.create_pokemon_instance(9) # Blastoise
	var rattata = GameData.create_pokemon_instance(19)  # Active defender
	var pidgey = GameData.create_pokemon_instance(16)   # Bench 1
	var caterpie = GameData.create_pokemon_instance(10) # Bench 2
	
	battle.player_team = [blastoise]
	battle.enemy_team = [rattata, pidgey, caterpie]
	rattata.current_hp = 30
	rattata.max_hp = 30
	pidgey.current_hp = 20
	pidgey.max_hp = 20
	caterpie.current_hp = 15
	caterpie.max_hp = 15
	
	var surf_move = get_test_move("Surf")
	assert(surf_move != null, "Surf move should exist in catalog")
	assert(surf_move.effect_type == "BENCH_DAMAGE", "Surf should have BENCH_DAMAGE effect")
	assert(surf_move.base_damage == 12, "Surf base damage should be 12")
	
	blastoise.current_energy = 5
	var dummy_v1 = Control.new()
	var dummy_v2 = Control.new()
	add_child(dummy_v1)
	add_child(dummy_v2)
	
	battle.perform_attack(blastoise, rattata, surf_move, false, 3, dummy_v1, dummy_v2)
	assert(rattata.current_hp == 18, "Rattata active HP should be 30 - 12 = 18")
	assert(pidgey.current_hp == 17, "Pidgey bench HP should take 3 splash DMG (20 - 3 = 17)")
	assert(caterpie.current_hp == 12, "Caterpie bench HP should take 3 splash DMG (15 - 3 = 12)")
	print("✓ Test Surf (BENCH_DAMAGE) passed: 12 active + 3 bench splash")
	
	# 2. Test Hydro Pump (raw 18 DMG)
	var hp_move = get_test_move("Hydro Pump")
	assert(hp_move != null, "Hydro Pump should exist")
	assert(hp_move.base_damage == 18, "Hydro Pump base damage should be 18")
	assert(hp_move.cost == 4, "Hydro Pump cost should be 4")
	assert(hp_move.effect_type == "NONE", "Hydro Pump should be raw cannon")
	print("✓ Test Hydro Pump (18 raw DMG cannon) passed")

	# 3. Test Aqua Jet (BOOST_IF_FASTER: 4 + 3 = 7 DMG)
	var aqua_jet = get_test_move("Aqua Jet")
	assert(aqua_jet != null, "Aqua Jet should exist")
	assert(aqua_jet.effect_type == "BOOST_IF_FASTER", "Aqua Jet should be BOOST_IF_FASTER")
	blastoise.speed = 10
	rattata.speed = 5
	rattata.current_hp = 20
	battle.perform_attack(blastoise, rattata, aqua_jet, false, 1, dummy_v1, dummy_v2)
	assert(rattata.current_hp == 13, "Aqua Jet should deal 4 base + 3 faster = 7 DMG (20 - 7 = 13)")
	print("✓ Test Aqua Jet (BOOST_IF_FASTER) passed: 7 DMG when faster")

	# 4. Test Water Spout & Eruption (FULL_HP_POWER)
	var spout = get_test_move("Water Spout")
	assert(spout != null, "Water Spout should exist")
	assert(spout.effect_type == "FULL_HP_POWER", "Water Spout should be FULL_HP_POWER")
	# Case A: User HP >= 80% (16 + 4 = 20 DMG)
	blastoise.current_hp = 30
	blastoise.max_hp = 30
	rattata.current_hp = 30
	battle.perform_attack(blastoise, rattata, spout, false, 3, dummy_v1, dummy_v2)
	assert(rattata.current_hp == 10, "Water Spout at 100% HP should deal 16 + 4 = 20 DMG (30 - 20 = 10)")
	
	# Case B: User HP < 50% (16 - 4 = 12 DMG)
	blastoise.current_hp = 10
	rattata.current_hp = 30
	battle.perform_attack(blastoise, rattata, spout, false, 3, dummy_v1, dummy_v2)
	assert(rattata.current_hp == 18, "Water Spout at <50% HP should deal 16 - 4 = 12 DMG (30 - 12 = 18)")
	print("✓ Test Water Spout / Eruption (FULL_HP_POWER) passed: +4 at high HP, -4 at low HP")

	# 5. Test Shell Smash (SHELL_SMASH: -2 HP, +4 permanent DMG, +2 Speed)
	var shell_smash = get_test_move("Shell Smash")
	assert(shell_smash != null, "Shell Smash should exist")
	assert(shell_smash.effect_type == "SHELL_SMASH", "Shell Smash should be SHELL_SMASH")
	blastoise.current_hp = 25
	blastoise.speed = 4
	blastoise.damage_buff = 0
	battle.perform_attack(blastoise, rattata, shell_smash, false, 1, dummy_v1, dummy_v2)
	assert(blastoise.current_hp == 23, "Shell Smash should cost 2 self-HP (25 - 2 = 23)")
	assert(blastoise.damage_buff == 4, "Shell Smash should grant +4 permanent damage buff")
	assert(blastoise.speed == 7, "Shell Smash should grant +3 permanent Speed (4 + 3 = 7)")
	print("✓ Test Shell Smash (SHELL_SMASH) passed: -2 recoil, +4 buff, +3 speed")

	# 6. Test Payback (REVENGE: 6 base + 6 moving second = 12 DMG)
	var payback = get_test_move("Payback")
	assert(payback != null, "Payback should exist")
	assert(payback.effect_type == "REVENGE", "Payback should have REVENGE effect")
	blastoise.damage_buff = 0 # reset
	blastoise.speed = 2
	rattata.speed = 10 # foe is faster -> blastoise acts second
	blastoise.took_damage_last_turn = false
	rattata.current_hp = 30
	battle.perform_attack(blastoise, rattata, payback, false, 2, dummy_v1, dummy_v2)
	assert(rattata.current_hp == 18, "Payback should deal 6 + 6 = 12 DMG when acting second (30 - 12 = 18)")
	print("✓ Test Payback (REVENGE acting second) passed: 12 DMG")

	# 7. Test Knock Off (BUFF_PURGE: strips shields and damage buffs)
	var knock_off = get_test_move("Knock Off")
	assert(knock_off != null, "Knock Off should exist")
	assert(knock_off.effect_type == "BUFF_PURGE", "Knock Off should have BUFF_PURGE effect")
	rattata.current_hp = 30
	rattata.shield_reduction = 3
	rattata.shield_turns = 2
	rattata.damage_buff = 5
	battle.perform_attack(blastoise, rattata, knock_off, false, 2, dummy_v1, dummy_v2)
	assert(rattata.damage_buff == 0, "Knock Off should purge foe's damage buff")
	assert(rattata.shield_reduction == 0, "Knock Off should purge foe's shield")
	print("✓ Test Knock Off (BUFF_PURGE) passed: purged shields and buffs")

	# 8. Test Earthquake vs Dig (2x DMG)
	var eq = get_test_move("Earthquake")
	assert(eq != null, "Earthquake should exist")
	rattata.current_hp = 40
	rattata.is_digging = true
	battle.perform_attack(blastoise, rattata, eq, false, 4, dummy_v1, dummy_v2)
	assert(rattata.is_digging == false, "Earthquake should hit and cancel Dig")
	assert(rattata.current_hp == 8, "Earthquake should deal 16 * 2 = 32 DMG to digging foe (40 - 32 = 8)")
	print("✓ Test Earthquake vs Dig passed: 32 DMG (x2)")

	# 9. Test CANNOT_MISS (Shock Wave bypassing evasion)
	var shock_wave = get_test_move("Shock Wave")
	assert(shock_wave != null, "Shock Wave should exist")
	assert(shock_wave.effect_type == "CANNOT_MISS", "Shock Wave should be CANNOT_MISS")
	rattata.current_hp = 20
	rattata.is_evasive = true
	battle.perform_attack(blastoise, rattata, shock_wave, false, 2, dummy_v1, dummy_v2)
	assert(rattata.current_hp == 12, "Shock Wave should pierce evasion dealing 8 DMG (20 - 8 = 12)")
	print("✓ Test Shock Wave (CANNOT_MISS) passed: pierced evasion")

	# 10. Test Weather Ball in Sandstorm (+6 DMG and Ground element)
	var wb = get_test_move("Weather Ball")
	assert(wb != null, "Weather Ball should exist")
	assert(wb.effect_type == "WEATHER_BALL", "Weather Ball should be WEATHER_BALL")
	battle.sandstorm_turns = 2
	var pikachu = GameData.create_pokemon_instance(25) # Electric type (weak to Ground)
	pikachu.current_hp = 30
	# 8 base + 6 sandstorm = 14 GROUND dmg. Ground vs Electric is weakness (+2 WEAKNESS_BONUS) = 16 DMG!
	battle.perform_attack(blastoise, pikachu, wb, false, 2, dummy_v1, dummy_v2)
	assert(pikachu.current_hp == 14, "Weather Ball in sandstorm should deal 8 + 6 + 2 (weakness) = 16 DMG (30 - 16 = 14)")
	print("✓ Test Weather Ball in Sandstorm passed: +6 DMG and adopted Ground element hitting Electric weakness")
