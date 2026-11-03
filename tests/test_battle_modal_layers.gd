extends Node

func _ready() -> void:
	print("--- Running Test: Battle Modal Layering and Z-Index Hierarchy ---")
	
	# Reset states
	GameData.is_campaign_mode = false
	GameData.is_tutorial_mode = false
	GameData.is_online_pvp = false
	
	# Instantiate Battle scene
	var battle_scene = load("res://scenes/battle.tscn")
	assert(battle_scene != null, "scenes/battle.tscn must be valid")
	
	var battle = battle_scene.instantiate()
	add_child(battle)
	
	# Check modal existence and z_index
	var game_over = battle.get_node_or_null("GameOverOverlay")
	assert(game_over != null, "GameOverOverlay must exist")
	print("GameOverOverlay z_index = %d" % game_over.z_index)
	assert(game_over.z_index >= 70, "GameOverOverlay z_index must be >= 70, got: %d" % game_over.z_index)
	
	var evo_modal = battle.get_node_or_null("EvolutionModal")
	assert(evo_modal != null, "EvolutionModal must exist")
	print("EvolutionModal z_index = %d" % evo_modal.z_index)
	assert(evo_modal.z_index >= 60, "EvolutionModal z_index must be >= 60, got: %d" % evo_modal.z_index)
	
	var energy_modal = battle.get_node_or_null("EnergyModal")
	assert(energy_modal != null, "EnergyModal must exist")
	print("EnergyModal z_index = %d" % energy_modal.z_index)
	assert(energy_modal.z_index >= 40, "EnergyModal z_index must be >= 40, got: %d" % energy_modal.z_index)
	
	var bag_modal = battle.get_node_or_null("BagModal")
	assert(bag_modal != null, "BagModal must exist")
	print("BagModal z_index = %d" % bag_modal.z_index)
	assert(bag_modal.z_index >= 40, "BagModal z_index must be >= 40, got: %d" % bag_modal.z_index)
	
	var type_modal = battle.get_node_or_null("TypeChartModal")
	assert(type_modal != null, "TypeChartModal must exist")
	print("TypeChartModal z_index = %d" % type_modal.z_index)
	assert(type_modal.z_index >= 40, "TypeChartModal z_index must be >= 40, got: %d" % type_modal.z_index)
	
	# Check PlayerCard miniature and inspect button
	var player_card = battle.get_node_or_null("MainContainer/PlayerSection/HBox/PlayerCard")
	assert(player_card != null, "PlayerCard must exist")
	var btn_inspect = player_card.find_child("BtnInspect", true, false)
	assert(btn_inspect != null, "BtnInspect must exist")
	
	var inspect_effective_z = player_card.z_index + (btn_inspect.z_index if btn_inspect.z_as_relative else 0)
	print("PlayerCard z_index = %d, BtnInspect z_index = %d, effective z = %d" % [player_card.z_index, btn_inspect.z_index, inspect_effective_z])
	
	assert(game_over.z_index > inspect_effective_z, "GameOverOverlay MUST be above inspect button! %d vs %d" % [game_over.z_index, inspect_effective_z])
	assert(evo_modal.z_index > inspect_effective_z, "EvolutionModal MUST be above inspect button! %d vs %d" % [evo_modal.z_index, inspect_effective_z])
	assert(energy_modal.z_index > inspect_effective_z, "EnergyModal MUST be above inspect button! %d vs %d" % [energy_modal.z_index, inspect_effective_z])
	assert(bag_modal.z_index > inspect_effective_z, "BagModal MUST be above inspect button! %d vs %d" % [bag_modal.z_index, inspect_effective_z])
	assert(type_modal.z_index > inspect_effective_z, "TypeChartModal MUST be above inspect button! %d vs %d" % [type_modal.z_index, inspect_effective_z])
	
	# Test details modal
	assert(battle.details_modal != null, "details_modal must exist")
	print("CombatDetailsModal z_index = %d" % battle.details_modal.z_index)
	assert(battle.details_modal.z_index >= 40, "details_modal z_index must be >= 40")
	assert(battle.details_modal.z_index > inspect_effective_z, "details_modal MUST be above inspect button")
	
	# Test GameOver display and interaction guard
	battle._show_game_over_internal("🎉 POKÉMON TOURNAMENT CHAMPION!", "Test champion")
	assert(game_over.visible == true, "GameOverOverlay must be visible")
	assert(battle.details_modal.visible == false, "details_modal must be closed when game over opens")
	
	# Simulate clicking player card or inspect during Game Over - must NOT open details modal
	battle._on_player_inspect_pressed()
	assert(battle.details_modal.visible == false, "details_modal must stay closed during Game Over")
	
	var click_ev = InputEventMouseButton.new()
	click_ev.pressed = true
	click_ev.button_index = MOUSE_BUTTON_LEFT
	battle._on_player_card_clicked(click_ev)
	assert(battle.details_modal.visible == false, "details_modal must stay closed when card is clicked during Game Over")
	
	print("✅ ALL BATTLE MODAL LAYER & Z-INDEX CHECKS PASSED SUCCESSFULLY!")
	get_tree().quit()
