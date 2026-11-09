extends Node

func _ready() -> void:
	print("=== INICIANDO TEST: BOSS SHADER & MOVE FLAIL ===")
	test_flail_move_data()
	test_flail_combat_effect()
	test_boss_shader_material()
	test_crystal_onix_card_shader_integration()
	print("=== TODOS LOS TESTS DE BOSS SHADER Y FLAIL COMPLETADOS EXITOSAMENTE ===")
	get_tree().quit(0)

func test_flail_move_data() -> void:
	print("[TEST] Verificando datos del movimiento Flail en catálogo...")
	if GameData.moves_catalog.is_empty():
		GameData.load_moves_catalog()
		
	var flail_entry = GameData.moves_catalog.get("flail")
	assert(flail_entry != null, "Flail debe existir en moves_catalog")
	assert(int(flail_entry["dmg"]) == 6, "Flail debe tener 6 DMG base (actual: %d)" % int(flail_entry["dmg"]))
	assert(flail_entry["desc"] == "Si este PKMN tiene menos del 50% de su HP, aumenta +2 DMG.", "Descripción de Flail debe coincidir exactamente")
	print("✓ Datos de Flail verificados: 6 DMG y efecto correcto")

func test_flail_combat_effect() -> void:
	print("[TEST] Verificando lógica de combate y predicción de daño de Flail...")
	if GameData.pokemon_catalog.is_empty():
		GameData.load_pokemon_catalog()
	
	# Usar battle script / node
	var battle_scene = load("res://scenes/battle.tscn").instantiate()
	add_child(battle_scene)
	
	# Goldeen tiene Flail
	var goldeen_id = GameData.get_pokemon_id_by_name("Goldeen")
	assert(goldeen_id >= 0, "Goldeen debe existir")
	var attacker = GameData.create_pokemon_instance(goldeen_id)
	assert(attacker != null, "Attacker instance creada")
	
	# Defender neutral a tipo NORMAL (ej. Bulbasaur)
	var bulba_id = GameData.get_pokemon_id_by_name("Bulbasaur")
	var defender = GameData.create_pokemon_instance(bulba_id)
	assert(defender != null, "Defender instance creada")
	
	# Buscar el movimiento Flail en el atacante
	var flail_move = null
	for m in attacker.moves:
		if m.name == "Flail":
			flail_move = m
			break
	assert(flail_move != null, "Goldeen debe tener el movimiento Flail")
	assert(flail_move.base_damage == 6, "Flail base_damage debe ser 6")
	
	# Caso 1: HP al 100% (14 / 14 HP) -> Daño debe ser 6 (sin bono)
	attacker.current_hp = attacker.max_hp
	var pred_full = battle_scene.calculate_predicted_damage(attacker, defender, flail_move, flail_move.cost, false)
	assert(pred_full == 6, "A HP completo (> 50%%), Flail debe predecir 6 DMG (actual: %d)" % pred_full)
	
	# Caso 2: HP exacto al 50% (7 / 14 HP) -> Menos del 50% es estrictamente < 50%, daño es 6
	attacker.current_hp = int(attacker.max_hp * 0.5)
	var pred_half = battle_scene.calculate_predicted_damage(attacker, defender, flail_move, flail_move.cost, false)
	assert(pred_half == 6, "Al 50%% exacto, daño predicho debe ser 6 (actual: %d)" % pred_half)
	
	# Caso 3: HP menor al 50% (por ejemplo 5 / 14 HP) -> Daño debe ser 6 + 2 = 8 DMG!
	attacker.current_hp = int(attacker.max_hp * 0.35)
	var pred_low = battle_scene.calculate_predicted_damage(attacker, defender, flail_move, flail_move.cost, false)
	assert(pred_low == 8, "Con HP < 50%%, Flail debe aumentar +2 DMG y dar 8 DMG (actual: %d)" % pred_low)
	
	remove_child(battle_scene)
	battle_scene.queue_free()
	print("✓ Efecto de daño de Flail (+2 DMG con HP < 50%) verificado correctamente")

func test_boss_shader_material() -> void:
	print("[TEST] Verificando compilación y creación del shader de Boss...")
	var s = GameData.get_boss_card_foil_shader()
	assert(s != null, "boss_card_foil.gdshader debe cargarse sin errores")
	assert(s is Shader, "Debe ser un objeto Shader válido")
	
	var mat = GameData.create_card_foil_material("Boss")
	assert(mat != null, "create_card_foil_material('Boss') debe retornar un ShaderMaterial")
	assert(mat is ShaderMaterial, "Debe ser instancia de ShaderMaterial")
	assert(mat.shader == s, "El shader asignado debe ser boss_card_foil_shader")
	assert(mat.get_shader_parameter("star_scale") == 16.0, "Parámetro star_scale debe estar configurado")
	assert(mat.get_shader_parameter("star_intensity") == 1.45, "Parámetro star_intensity debe estar configurado")
	
	print("✓ Shader de Boss con patrón de estrellas instanciado y verificado con éxito")

func test_crystal_onix_card_shader_integration() -> void:
	print("[TEST] Verificando integración del Boss shader en cartas de Crystal Onix...")
	# 1. En CombatCardMiniature
	var mini_script = load("res://scripts/combat_card_miniature.gd")
	var mini = mini_script.new()
	add_child(mini)
	var onix_inst = GameData.create_pokemon_instance(GameData.CRYSTAL_ONIX_ID)
	assert(onix_inst != null, "Crystal Onix instance debe crearse")
	assert(onix_inst.rarity == "Boss", "La rareza de Crystal Onix debe ser Boss")
	
	mini.setup(onix_inst, true)
	var foil_node = mini.get_node_or_null("FoilOverlay") as ColorRect
	assert(foil_node != null, "FoilOverlay debe existir en la miniatura de Crystal Onix")
	assert(foil_node.material != null, "FoilOverlay debe tener material")
	assert((foil_node.material as ShaderMaterial).shader == GameData.get_boss_card_foil_shader(), "FoilOverlay debe tener el boss_card_foil_shader")
	
	remove_child(mini)
	mini.queue_free()
	
	# 2. En AssembledCard
	var card_assembled = load("res://scenes/assembled_card.tscn").instantiate()
	add_child(card_assembled)
	card_assembled.setup(GameData.pokemon_catalog[GameData.CRYSTAL_ONIX_ID])
	var card_foil = card_assembled.get_node_or_null("FoilOverlay") as ColorRect
	assert(card_foil != null, "FoilOverlay debe existir en la carta armada de Crystal Onix")
	assert(card_foil.material != null, "FoilOverlay debe tener material")
	assert((card_foil.material as ShaderMaterial).shader == GameData.get_boss_card_foil_shader(), "FoilOverlay debe usar el boss_card_foil_shader")
	
	remove_child(card_assembled)
	card_assembled.queue_free()
	
	print("✓ Miniaturas y cartas armadas de Crystal Onix aplican automáticamente el Boss shader con estrellas")
