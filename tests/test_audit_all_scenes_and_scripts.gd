extends Node

func _ready() -> void:
	print("\n=======================================================")
	print("🔍 AUDITORÍA INTEGRAL DE ESCENAS, SCRIPTS Y MODALES")
	print("=======================================================\n")
	
	await get_tree().process_frame
	await get_tree().process_frame

	# 1. Auditar AssembledCard
	print("1. Verificando scenes/assembled_card.tscn...")
	var card_scene = preload("res://scenes/assembled_card.tscn").instantiate()
	assert(card_scene != null, "Error al instanciar assembled_card.tscn")
	add_child(card_scene)
	card_scene.setup(GameData.pokemon_catalog[0]) # Bulbasaur
	card_scene.setup(GameData.pokemon_catalog[6]) # Charizard
	print("✓ AssembledCard instanciada y configurada sin errores.")
	card_scene.queue_free()
	await get_tree().process_frame

	# 2. Auditar Main Menu y sus Modales
	print("\n2. Verificando scenes/main_menu.tscn y sus botones/modales...")
	GameData.tutorial_completed = true
	var main_menu = preload("res://scenes/main_menu.tscn").instantiate()
	assert(main_menu != null, "Error al instanciar main_menu.tscn")
	add_child(main_menu)
	await get_tree().process_frame
	await get_tree().process_frame

	# Verificar versión mostrada
	var version_lbl = main_menu.find_child("VersionLbl", true, false)
	if version_lbl:
		print("  Version label encontrada: %s" % version_lbl.text)

	# Verificar botones del lobby
	var btn_col = main_menu.find_child("BtnCollection", true, false)
	var btn_camp = main_menu.find_child("BtnCampaign", true, false)
	var btn_qb = main_menu.find_child("BtnQuickBattle", true, false)
	var btn_shop = main_menu.find_child("BtnShop", true, false)
	
	assert(btn_col != null, "BtnCollection no encontrado")
	assert(btn_camp != null, "BtnCampaign no encontrado")
	assert(btn_qb != null, "BtnQuickBattle no encontrado")
	assert(btn_shop != null, "BtnShop no encontrado")
	print("✓ Botones principales del Lobby verificados.")

	# Modal Colección
	btn_col.emit_signal("pressed")
	await get_tree().process_frame
	assert(main_menu.collection_modal != null and main_menu.collection_modal.visible, "collection_modal debe estar visible")
	print("✓ Modal de Colección abre correctamente.")

	# Abrir detalle de carta desde colección
	main_menu.open_collection_detail(0)
	await get_tree().process_frame
	var detail_view = main_menu.collection_detail_view
	assert(detail_view != null and detail_view.visible, "collection_detail_view debe estar visible")
	print("✓ Detalle de carta (CollectionDetailView) abre sin errores.")

	# Cerrar detalle y volver al grid
	main_menu._on_back_to_grid_pressed()
	await get_tree().process_frame
	assert(main_menu.collection_grid_view.visible, "collection_grid_view debe estar visible tras volver")
	
	main_menu.collection_modal.visible = false
	await get_tree().process_frame
	print("✓ Cierre de Detalle y Colección correcto.")

	# Modal Campaña Hub
	btn_camp.emit_signal("pressed")
	await get_tree().process_frame
	assert(main_menu.campaign_hub_modal != null and main_menu.campaign_hub_modal.visible, "campaign_hub_modal debe estar visible")
	print("✓ Modal de Campaña Hub abre correctamente.")
	main_menu.campaign_hub_modal.visible = false
	await get_tree().process_frame

	# Modal Selección de Equipo (Quick Battle)
	btn_qb.emit_signal("pressed")
	await get_tree().process_frame
	assert(main_menu.team_select_modal != null and main_menu.team_select_modal.visible, "team_select_modal debe estar visible")
	print("✓ Modal de Selección de Equipo abre correctamente.")

	# Abrir detalle de carta desde selección de equipo
	main_menu.open_card_detail_from_team_select(6) # Charizard
	await get_tree().process_frame
	assert(detail_view.visible, "Detalle desde Team Select debe estar visible")
	print("✓ Detalle de carta desde Selección de Equipo abre correctamente.")
	
	# Volver a Selección de Equipo
	main_menu._on_back_to_grid_pressed()
	await get_tree().process_frame
	assert(main_menu.team_select_modal.visible, "Debe restaurar team_select_modal")
	print("✓ Regreso a Selección de Equipo verificado con éxito.")

	main_menu.team_select_modal.visible = false
	await get_tree().process_frame

	# Modal Tienda
	btn_shop.emit_signal("pressed")
	await get_tree().process_frame
	assert(main_menu.shop_modal != null and main_menu.shop_modal.visible, "shop_modal debe estar visible")
	print("✓ Modal de Tienda abre correctamente.")
	main_menu.shop_modal.visible = false
	await get_tree().process_frame

	main_menu.queue_free()
	await get_tree().process_frame

	# 3. Auditar Escena de Batalla
	print("\n3. Verificando scenes/battle.tscn y sus controles...")
	var battle_scene = preload("res://scenes/battle.tscn").instantiate()
	assert(battle_scene != null, "Error al instanciar battle.tscn")
	add_child(battle_scene)
	await get_tree().process_frame
	await get_tree().process_frame

	var p_act = battle_scene.get_active_player()
	var e_act = battle_scene.get_active_enemy()
	assert(p_act != null, "Battle: Player activo no puede ser null")
	assert(e_act != null, "Battle: Enemy activo no puede ser null")
	
	# Verificar botones de combate
	var btn_rec = battle_scene.find_child("BtnRecover", true, false)
	var btn_bag = battle_scene.find_child("BtnBag", true, false)
	assert(btn_rec != null, "BtnRecover no encontrado")
	assert(btn_bag != null, "BtnBag no encontrado")
	print("✓ Controles de combate y barras de batalla verificados.")

	# Modal de mochila
	battle_scene.can_player_act = true
	battle_scene.is_player_turn = true
	battle_scene.is_busy = false
	btn_bag.emit_signal("pressed")
	await get_tree().process_frame
	var bag_modal = battle_scene.find_child("BagModal", true, false)
	assert(bag_modal != null and bag_modal.visible, "BagModal debe abrirse")
	print("✓ Modal de Mochila en combate verificado.")
	var btn_close_bag = battle_scene.find_child("BtnCloseBag", true, false)
	if btn_close_bag:
		btn_close_bag.emit_signal("pressed")
		await get_tree().process_frame

	# Modal de rendición / salir
	battle_scene._show_forfeit_confirmation_modal()
	await get_tree().process_frame
	assert(battle_scene.forfeit_modal != null and battle_scene.forfeit_modal.visible, "forfeit_modal debe abrirse")
	print("✓ Modal de Salir / Rendirse en combate verificado.")
	battle_scene.forfeit_modal.visible = false
	await get_tree().process_frame

	battle_scene.queue_free()
	await get_tree().process_frame

	print("\n=======================================================")
	print("🎉 AUDITORÍA COMPLETA: TODAS LAS ESCENAS Y MODALES ESTÁN 100% OPERATIVOS")
	print("=======================================================\n")
	get_tree().quit(0)
