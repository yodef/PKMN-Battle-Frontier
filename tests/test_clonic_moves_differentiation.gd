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
	blastoise.attack = 10
	blastoise.defense = 10
	rattata.attack = 10
	rattata.defense = 10
	pidgey.attack = 10
	pidgey.defense = 10
	caterpie.attack = 10
	caterpie.defense = 10
	rattata.current_hp = 50
	rattata.max_hp = 50
	pidgey.current_hp = 30
	pidgey.max_hp = 30
	caterpie.current_hp = 30
	caterpie.max_hp = 30
	
	var surf_move = get_test_move("Surf")
	assert(surf_move != null, "Surf move should exist in catalog")
	assert(surf_move.effect_type == "BENCH_DAMAGE", "Surf should have BENCH_DAMAGE effect")
	assert(surf_move.base_damage == 32, "Surf base damage should be 32")
	
	blastoise.current_energy = 5
	var dummy_v1 = Control.new()
	var dummy_v2 = Control.new()
	add_child(dummy_v1)
	add_child(dummy_v2)
	
	battle.perform_attack(blastoise, rattata, surf_move, false, 3, dummy_v1, dummy_v2)
	assert(rattata.current_hp == 18, "Rattata active HP should be 50 - 32 = 18")
	assert(pidgey.current_hp == 24, "Pidgey bench HP should take 6 splash DMG (30 - 6 = 24)")
	assert(caterpie.current_hp == 24, "Caterpie bench HP should take 6 splash DMG (30 - 6 = 24)")
	print("✓ Test Surf (BENCH_DAMAGE) passed: 32 active + 6 bench splash")
	
	# 2. Test Hydro Pump (raw 52 DMG)
	var hp_move = get_test_move("Hydro Pump")
	assert(hp_move != null, "Hydro Pump should exist")
	assert(hp_move.base_damage == 52, "Hydro Pump base damage should be 52")
	assert(hp_move.cost == 4, "Hydro Pump cost should be 4")
	assert(hp_move.effect_type == "NONE", "Hydro Pump should be raw cannon")
	print("✓ Test Hydro Pump (52 raw DMG cannon) passed")

	# 3. Test Aqua Jet (BOOST_IF_FASTER: 4 + 3 = 7 DMG)
	var aqua_jet = get_test_move("Aqua Jet")
	assert(aqua_jet != null, "Aqua Jet should exist")
	assert(aqua_jet.effect_type == "BOOST_IF_FASTER", "Aqua Jet should be BOOST_IF_FASTER")
	blastoise.speed = 10
	rattata.speed = 5
	rattata.current_hp = 30
	battle.perform_attack(blastoise, rattata, aqua_jet, false, 1, dummy_v1, dummy_v2)
	assert(rattata.current_hp == 15, "Aqua Jet should deal 12 base + 3 faster = 15 DMG (30 - 15 = 15)")
	print("✓ Test Aqua Jet (BOOST_IF_FASTER) passed: 15 DMG when faster")

	# 4. Test Water Spout & Eruption (FULL_HP_POWER)
	var spout = get_test_move("Water Spout")
	assert(spout != null, "Water Spout should exist")
	assert(spout.effect_type == "FULL_HP_POWER", "Water Spout should be FULL_HP_POWER")
	# Case A: User HP >= 80% (48 + 4 = 52 DMG)
	blastoise.current_hp = 30
	blastoise.max_hp = 30
	rattata.current_hp = 60
	battle.perform_attack(blastoise, rattata, spout, false, spout.cost, dummy_v1, dummy_v2)
	assert(rattata.current_hp == 8, "Water Spout at 100% HP should deal 48 + 4 = 52 DMG (60 - 52 = 8)")
	
	# Case B: User HP < 50% (48 - 4 = 44 DMG)
	blastoise.current_hp = 10
	rattata.current_hp = 60
	battle.perform_attack(blastoise, rattata, spout, false, spout.cost, dummy_v1, dummy_v2)
	assert(rattata.current_hp == 16, "Water Spout at <50% HP should deal 48 - 4 = 44 DMG (60 - 44 = 16)")
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
	rattata.current_hp = 40
	battle.perform_attack(blastoise, rattata, payback, false, 2, dummy_v1, dummy_v2)
	assert(rattata.current_hp == 16, "Payback should deal 18 + 6 = 24 DMG when acting second (40 - 24 = 16)")
	print("✓ Test Payback (REVENGE acting second) passed: 24 DMG")

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
	rattata.current_hp = 120
	rattata.is_digging = true
	battle.perform_attack(blastoise, rattata, eq, false, 4, dummy_v1, dummy_v2)
	assert(rattata.is_digging == false, "Earthquake should hit and cancel Dig")
	assert(rattata.current_hp == 24, "Earthquake should deal 48 * 2 = 96 DMG to digging foe (120 - 96 = 24)")
	print("✓ Test Earthquake vs Dig passed: 96 DMG (x2)")

	# 9. Test CANNOT_MISS (Shock Wave bypassing evasion)
	var shock_wave = get_test_move("Shock Wave")
	assert(shock_wave != null, "Shock Wave should exist")
	assert(shock_wave.effect_type == "CANNOT_MISS", "Shock Wave should be CANNOT_MISS")
	rattata.current_hp = 40
	rattata.is_evasive = true
	battle.perform_attack(blastoise, rattata, shock_wave, false, 2, dummy_v1, dummy_v2)
	assert(rattata.current_hp == 18, "Shock Wave should pierce evasion dealing 22 DMG (40 - 22 = 18)")
	print("✓ Test Shock Wave (CANNOT_MISS) passed: pierced evasion")

	# 10. Test Weather Ball in Sandstorm (+6 DMG and Ground element with x2 Weakness Multiplier)
	var wb = get_test_move("Weather Ball")
	assert(wb != null, "Weather Ball should exist")
	assert(wb.effect_type == "WEATHER_BALL", "Weather Ball should be WEATHER_BALL")
	battle.sandstorm_turns = 2
	var pikachu = GameData.create_pokemon_instance(25) # Electric type (weak to Ground)
	pikachu.attack = 10
	pikachu.defense = 10
	pikachu.current_hp = 80
	pikachu.max_hp = 80
	# 22 base + 6 sandstorm = 28 GROUND dmg. Ground vs Electric weakness (x2 multiplier) = 56 DMG! (80 - 56 = 24)
	battle.perform_attack(blastoise, pikachu, wb, false, 2, dummy_v1, dummy_v2)
	assert(pikachu.current_hp == 24, "Weather Ball in sandstorm should deal 28 * 2 = 56 DMG (80 - 56 = 24). Actual: %d" % pikachu.current_hp)
	print("✓ Test Weather Ball in Sandstorm passed: +6 DMG and adopted Ground element hitting Electric weakness with x2 multiplier")
