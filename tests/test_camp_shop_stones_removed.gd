extends Node

func _ready() -> void:
	print("=== TEST: CAMP SHOP WITHOUT STONES / HYPER POTION & STONE TEXTURE BUY BUTTON ===")
	var menu = load("res://scenes/main_menu.tscn").instantiate()
	add_child(menu)
	await get_tree().process_frame

	# Campaña de prueba con un Pokémon listo para evolucionar por piedra (Bulbasaur -> Leaf)
	GameData.campaign_submode = "TOURNAMENT"
	GameData.change_campaign_team([1])
	var team = GameData.get_active_campaign_team_state()
	assert(not team.is_empty(), "Campaign team must exist")
	team[0]["current_exp"] = 9999
	GameData.set_active_campaign_gold(100)
	menu.update_campaign_ui()

	# 1. Tienda del campamento sin piedras ni Hiper Poción
	assert(menu.camp_shop_stones_list == null, "Camp Shop must NOT list Evolution Stones anymore")
	assert(menu.btn_buy_hyper_potion.get_parent().visible == false, "Hyper Potion row must be hidden from the Camp Shop")
	print("✓ Camp Shop: Evolution Stones and Hyper Potion removed")

	# 2. Selector de evolución: botón de compra con textura de la piedra
	menu._open_camp_evolution_selector(0)
	var buy_btn = menu.camp_evo_selector_modal.find_child("BtnBuyStone", true, false) as Button
	assert(buy_btn != null, "Evolution selector must show the stone buy button when stone is missing")
	assert(buy_btn.icon != null, "Stone buy button must use the stone texture as icon")
	var opts = GameData.get_evolution_options(int(team[0]["id"]), true)
	assert(not opts.is_empty(), "Test Pokémon must have a stone evolution option")
	var req_stone = str(opts[0].get("stone_type", ""))
	var expected_tex = GameData.get_item_texture(req_stone)
	assert(buy_btn.icon.resource_path == expected_tex.resource_path, "Stone buy button icon must be the required %s texture (got %s, expected %s)" % [req_stone, buy_btn.icon.resource_path, expected_tex.resource_path])
	var stones_before = GameData.get_campaign_stone_count(req_stone)
	buy_btn.pressed.emit()
	assert(GameData.get_campaign_stone_count(req_stone) == stones_before + 1, "Pressing stone button must buy 1 stone")
	print("✓ Evolution selector stone button uses stone texture and buys the stone")

	print("=== ALL CAMP SHOP STONE TESTS PASSED ===")
	get_tree().quit(0)
