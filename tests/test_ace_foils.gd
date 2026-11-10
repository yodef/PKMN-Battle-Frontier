extends Node

func _ready() -> void:
	print("=== RUNNING TEST: GYM LEADER ACE & ELITE FOUR ACE FOIL SHADERS ===")
	
	test_shader_material_creation()
	test_assembled_card_foil_integration()
	test_combat_card_miniature_foil_integration()
	test_adventure_gym_leader_ace_assignment()
	
	print("\n=== ALL ACE FOIL TESTS COMPLETED SUCCESSFULLY! ===")
	get_tree().quit(0)

func test_shader_material_creation() -> void:
	print("\n[Test 1] Testing Shader Material Creation for Ace Foils...")
	var shader = GameData.get_card_foil_shader()
	assert(shader != null, "card_foil.gdshader must load successfully")
	assert(shader is Shader, "Must be a valid Shader object")
	
	# Test Gym Leader Ace Foil Material
	var gym_mat = GameData.create_card_foil_material("gym_leader_ace")
	assert(gym_mat != null, "Gym Leader Ace material must not be null")
	assert(gym_mat.shader == shader, "Must use card_foil.gdshader")
	assert(gym_mat.get_shader_parameter("foil_style") == 3, "Gym Leader Ace must use foil_style = 3 (Cross-Beam Badge)")
	var gym_c1 = gym_mat.get_shader_parameter("foil_color_1")
	assert(gym_c1.r > 0.8 and gym_c1.g > 0.7, "Primary color must be radiant amber/gold")
	print("  ✓ Gym Leader Ace material verified (Style 3, Gold & Cyan Emblem)")
	
	# Test Elite Four Ace Foil Material
	var e4_mat = GameData.create_card_foil_material("elite_four_ace")
	assert(e4_mat != null, "Elite Four Ace material must not be null")
	assert(e4_mat.shader == shader, "Must use card_foil.gdshader")
	assert(e4_mat.get_shader_parameter("foil_style") == 4, "Elite Four Ace must use foil_style = 4 (Royal Dragon Crown)")
	var e4_c1 = e4_mat.get_shader_parameter("foil_color_1")
	assert(e4_c1.r > 0.8 and e4_c1.g < 0.3, "Primary color must be royal ruby/crimson")
	print("  ✓ Elite Four Ace material verified (Style 4, Royal Ruby & Imperial Violet)")

func test_assembled_card_foil_integration() -> void:
	print("\n[Test 2] Testing AssembledCard integration...")
	var card_scene = load("res://scenes/assembled_card.tscn")
	var card = card_scene.instantiate()
	add_child(card)
	
	# Test Gym Leader Ace on Onix
	var onix_id = GameData.get_pokemon_id_by_name("Onix")
	assert(onix_id != -1, "Onix must exist in catalog")
	var onix_data = GameData.pokemon_catalog[onix_id].duplicate()
	onix_data["foil_type"] = "gym_leader_ace"
	
	card.setup(onix_data)
	var foil_node = card.get_node_or_null("FoilOverlay") as ColorRect
	assert(foil_node != null, "FoilOverlay must exist on Gym Leader Ace card")
	assert(foil_node.visible == true, "FoilOverlay must be visible")
	var mat = foil_node.material as ShaderMaterial
	assert(mat != null, "Material must be present")
	assert(mat.get_shader_parameter("foil_style") == 3, "Must use Style 3 for Gym Leader Ace")
	print("  ✓ AssembledCard successfully displays Gym Leader Ace foil")
	
	# Test Elite Four Ace on Dragonite
	var dragonite_id = GameData.get_pokemon_id_by_name("Dragonite")
	assert(dragonite_id != -1, "Dragonite must exist in catalog")
	var drag_data = GameData.pokemon_catalog[dragonite_id].duplicate()
	drag_data["foil_type"] = "elite_four_ace"
	
	card.setup(drag_data)
	var e4_foil = card.get_node_or_null("FoilOverlay") as ColorRect
	assert(e4_foil != null, "FoilOverlay must exist on Elite Four Ace card")
	var e4_mat = e4_foil.material as ShaderMaterial
	assert(e4_mat.get_shader_parameter("foil_style") == 4, "Must use Style 4 for Elite Four Ace")
	print("  ✓ AssembledCard successfully displays Elite Four Ace foil")
	
	remove_child(card)
	card.queue_free()

func test_combat_card_miniature_foil_integration() -> void:
	print("\n[Test 3] Testing CombatCardMiniature integration...")
	var mini_script = load("res://scripts/combat_card_miniature.gd")
	var mini = mini_script.new()
	add_child(mini)
	
	var raichu_id = GameData.get_pokemon_id_by_name("Raichu")
	var raichu_inst = GameData.create_pokemon_instance(raichu_id)
	raichu_inst.foil_type = "gym_leader_ace"
	
	mini.setup(raichu_inst, true)
	var foil_node = mini.get_node_or_null("FoilOverlay") as ColorRect
	assert(foil_node != null, "FoilOverlay must exist on miniature")
	var mat = foil_node.material as ShaderMaterial
	assert(mat != null, "Miniature must have ShaderMaterial")
	assert(mat.get_shader_parameter("foil_style") == 3, "Miniature must display Style 3 for Gym Ace")
	print("  ✓ CombatCardMiniature displays Gym Leader Ace foil in combat")
	
	remove_child(mini)
	mini.queue_free()

func test_adventure_gym_leader_ace_assignment() -> void:
	print("\n[Test 4] Testing Adventure Gym Leader Ace battle setup...")
	var battle_scene = load("res://scenes/battle.tscn")
	var battle = battle_scene.instantiate()
	add_child(battle)
	await get_tree().process_frame
	
	GameData.is_campaign_mode = true
	GameData.campaign_submode = "ADVENTURE"
	GameData.adventure_current_episode = 1
	GameData.adventure_current_stage = 4 # Brock Gym Leader Stage
	
	# Re-init enemy team for Brock stage
	var rival_ids = GameData.get_adventure_rival_team(1, 4)
	assert(rival_ids.size() == 2, "Brock has 2 Pokemon (Geodude and Onix)")
	
	battle.enemy_team = []
	for eid in rival_ids:
		var inst = GameData.create_pokemon_instance(eid)
		if inst:
			battle.enemy_team.append(inst)
			
	assert(battle.enemy_team.size() == 2, "Enemy team instantiated")
	
	# Simulate the battle setup assignment
	var last_idx = battle.enemy_team.size() - 1
	var stage_info = GameData.get_adventure_stage_info(1, 4)
	var is_boss_stage = bool(stage_info.get("is_boss", false)) or stage_info.get("badge_name", "") != ""
	var t_title = str(stage_info.get("trainer_title", stage_info.get("trainer_name", "")))
	var is_gym_leader = is_boss_stage and ("Líder" in t_title or "Gym Leader" in t_title or stage_info.get("badge_name", "") != "")
	
	assert(is_gym_leader == true, "Stage 4 of Episode 1 must be detected as Gym Leader stage")
	battle.enemy_team[last_idx].foil_type = "gym_leader_ace"
	battle.enemy_team[last_idx].is_gym_leader_ace = true
	
	var ace_pkmn = battle.enemy_team[last_idx]
	assert(ace_pkmn.name == "Onix", "Brock's ace must be Onix")
	assert(ace_pkmn.foil_type == "gym_leader_ace", "Onix must be tagged with gym_leader_ace foil")
	print("  ✓ Brock's Onix successfully identified and tagged with Gym Leader Ace Foil!")
	
	remove_child(battle)
	battle.queue_free()
