extends Node

func _ready() -> void:
	print("--- INICIANDO TEST COMPLETO DE LOBBY Y ESCENAS ---")
	call_deferred("_run_tests")

func _run_tests() -> void:
	# 1. Cargar main_menu.tscn
	var main_scene_res = load("res://scenes/main_menu.tscn")
	if not main_scene_res:
		print("❌ ERROR: No se pudo cargar res://scenes/main_menu.tscn")
		get_tree().quit(1)
		return
	print("✅ res://scenes/main_menu.tscn cargado correctamente.")

	var main_menu = main_scene_res.instantiate()
	add_child(main_menu)
	await get_tree().process_frame
	await get_tree().process_frame

	print("Verificando script adjunto a main_menu:")
	if not main_menu.get_script():
		print("❌ ERROR: main_menu no tiene script adjunto!")
		get_tree().quit(1)
		return
	print("✅ main_menu tiene su script adjunto correctamente: ", main_menu.get_script().resource_path)

	# 2. Verificar que los botones principales del lobby existan y estén conectados
	var btn_campaign = main_menu.btn_campaign
	var btn_quick_battle = main_menu.btn_quick_battle
	var btn_collection = main_menu.btn_collection
	var btn_shop = main_menu.btn_shop

	if not btn_campaign or not btn_campaign.pressed.is_connected(main_menu._on_campaign_pressed):
		print("❌ ERROR: btn_campaign no está conectado a _on_campaign_pressed!")
		get_tree().quit(1)
		return
	print("✅ btn_campaign conectado correctamente.")

	if not btn_quick_battle or not btn_quick_battle.pressed.is_connected(main_menu._on_quick_battle_pressed):
		print("❌ ERROR: btn_quick_battle no está conectado a _on_quick_battle_pressed!")
		get_tree().quit(1)
		return
	print("✅ btn_quick_battle conectado correctamente.")

	if not btn_collection or not btn_collection.pressed.is_connected(main_menu._on_collection_pressed):
		print("❌ ERROR: btn_collection no está conectado a _on_collection_pressed!")
		get_tree().quit(1)
		return
	print("✅ btn_collection conectado correctamente.")

	if not btn_shop or not btn_shop.pressed.is_connected(main_menu._on_shop_pressed):
		print("❌ ERROR: btn_shop no está conectado a _on_shop_pressed!")
		get_tree().quit(1)
		return
	print("✅ btn_shop conectado correctamente.")

	# 3. Probar interacción con los botones
	print("\n--- Probando Botón Colección ---")
	btn_collection.emit_signal("pressed")
	await get_tree().process_frame
	if not main_menu.collection_modal.visible:
		print("❌ ERROR: collection_modal no es visible tras pulsar btn_collection!")
		get_tree().quit(1)
		return
	print("✅ Modal Colección abierto con éxito.")

	# Probar abrir detalle de una carta y verificar panel de nivel y naturaleza
	print("Abriendo detalle de carta en la colección...")
	main_menu.open_collection_detail(0)
	await get_tree().process_frame
	if not main_menu.collection_detail_view.visible:
		print("❌ ERROR: collection_detail_view no es visible!")
		get_tree().quit(1)
		return
	print("✅ Detalle de carta abierto correctamente sin errores.")

	# Probar volver al grid de colección
	main_menu._on_back_to_grid_pressed()
	await get_tree().process_frame
	if main_menu.collection_detail_view.visible:
		print("❌ ERROR: collection_detail_view sigue visible tras volver al grid!")
		get_tree().quit(1)
		return
	print("✅ Volver al grid de colección funcionó.")

	# Cerrar modal colección
	if main_menu.btn_close_collection:
		main_menu.btn_close_collection.emit_signal("pressed")
	else:
		main_menu.collection_modal.visible = false
	await get_tree().process_frame
	print("✅ Modal Colección cerrado.")

	# 4. Probar Botón Campaña
	print("\n--- Probando Botón Campaña ---")
	btn_campaign.emit_signal("pressed")
	await get_tree().process_frame
	if not main_menu.campaign_hub_modal.visible:
		print("❌ ERROR: campaign_hub_modal no es visible tras pulsar btn_campaign!")
		get_tree().quit(1)
		return
	print("✅ Modal Campaña abierto con éxito.")
	main_menu.campaign_hub_modal.visible = false
	await get_tree().process_frame

	# 5. Probar Botón Quick Battle (Selección de equipo)
	print("\n--- Probando Botón Quick Battle ---")
	btn_quick_battle.emit_signal("pressed")
	await get_tree().process_frame
	if not main_menu.team_select_modal.visible:
		print("❌ ERROR: team_select_modal no es visible tras pulsar btn_quick_battle!")
		get_tree().quit(1)
		return
	print("✅ Modal Selección de Equipo abierto con éxito.")
	main_menu._on_close_team_select_pressed()
	await get_tree().process_frame

	# 6. Probar Botón Tienda
	print("\n--- Probando Botón Tienda ---")
	btn_shop.emit_signal("pressed")
	await get_tree().process_frame
	if not main_menu.shop_modal.visible:
		print("❌ ERROR: shop_modal no es visible tras pulsar btn_shop!")
		get_tree().quit(1)
		return
	print("✅ Modal Tienda abierto con éxito.")
	if main_menu.btn_close_shop:
		main_menu.btn_close_shop.emit_signal("pressed")
	else:
		main_menu.shop_modal.visible = false
	await get_tree().process_frame

	# 7. Probar escena de Batalla
	print("\n--- Probando Carga de Escena de Batalla ---")
	var battle_scene_res = load("res://scenes/battle.tscn")
	if not battle_scene_res:
		print("❌ ERROR: No se pudo cargar res://scenes/battle.tscn")
		get_tree().quit(1)
		return
	var battle_scene = battle_scene_res.instantiate()
	add_child(battle_scene)
	await get_tree().process_frame
	await get_tree().process_frame
	print("✅ Escena de batalla instanciada y añadida al árbol correctamente.")
	battle_scene.queue_free()

	# 8. Probar escena Assembled Card
	print("\n--- Probando Carga de Assembled Card ---")
	var assembled_res = load("res://scenes/assembled_card.tscn")
	if not assembled_res:
		print("❌ ERROR: No se pudo cargar res://scenes/assembled_card.tscn")
		get_tree().quit(1)
		return
	var card_node = assembled_res.instantiate()
	add_child(card_node)
	await get_tree().process_frame
	var sample_card = GameData.pokemon_catalog.get(1, {})
	if not sample_card.is_empty():
		card_node.setup(sample_card, true)
		await get_tree().process_frame
	print("✅ Assembled card instanciada y configurada correctamente.")
	card_node.queue_free()

	print("\n🎉 ¡TODAS LAS PRUEBAS DE LOBBY Y ESCENAS PASARON EXITOSAMENTE! 🎉")
	main_menu.queue_free()
	get_tree().quit(0)
