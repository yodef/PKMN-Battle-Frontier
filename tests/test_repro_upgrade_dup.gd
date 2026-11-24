extends Node

func _ready() -> void:
	print("--- TEST DE DUPLICACIÓN EN DETALLES DE MEJORA ---")
	call_deferred("_run_repro")

func _run_repro() -> void:
	var main_scene_res = load("res://scenes/main_menu.tscn")
	var main_menu = main_scene_res.instantiate()
	add_child(main_menu)
	await get_tree().process_frame
	await get_tree().process_frame

	# Ensure player has plenty of gold and a card unlocked
	GameData.add_active_campaign_gold(50000)
	GameData.unlock_all_pokemon()
	GameData.save_profile()

	main_menu.open_collection_detail(0)
	await get_tree().process_frame

	print("Children of details_box after open_collection_detail:")
	for c in main_menu.details_box.get_children():
		print(" - ", c.name, " (class: ", c.get_class(), ", visible: ", c.visible, ")")

	# Find CardUpgradePanel
	var up_panel = main_menu.details_box.get_node_or_null("CardUpgradePanel")
	print("Found CardUpgradePanel: ", up_panel != null)
	assert(up_panel != null, "CardUpgradePanel must exist")

	# Find btn_lvl inside up_panel
	var btn_lvl: Button = null
	for node in up_panel.find_children("*", "Button", true, false):
		print("  Btn in up_panel: '", node.text, "'")
		if "Subir" in node.text or "Level Up" in node.text or "Lv." in node.text:
			btn_lvl = node
			break
	print("Found btn_lvl: ", btn_lvl != null, " Text: ", btn_lvl.text if btn_lvl else "NONE")

	# Click btn_lvl
	print("\n>>> SIMULATING CLICK ON btn_lvl (UPGRADING) <<<")
	btn_lvl.emit_signal("pressed")
	
	# Wait for idle processing
	await get_tree().process_frame
	await get_tree().process_frame

	print("\nChildren of details_box after upgrade + 2 frames:")
	var upgrade_panels_found = []
	for c in main_menu.details_box.get_children():
		print(" - ", c.name, " (class: ", c.get_class(), ", visible: ", c.visible, ", is_queued: ", c.is_queued_for_deletion(), ")")
		if "Upgrade" in c.name or "CardUpgrade" in c.name or (c is PanelContainer and c.name != "HeaderPanel" and c.name != "LockedNoticePanel" and c.name != "StatsPanel" and c.name != "PassivePanel" and c.name != "Move1Panel" and c.name != "Move2Panel"):
			upgrade_panels_found.append(c)

	print("\nDetailed inspection of all children in details_box:")
	for c in main_menu.details_box.get_children():
		print(" Child: '", c.name, "' (", c.get_class(), ") visible=", c.visible)
		for btn in c.find_children("*", "Button", true, false):
			print("   Button: '", btn.text, "' visible=", btn.is_visible_in_tree(), " disabled=", btn.disabled)
		for lbl in c.find_children("*", "Label", true, false):
			if "Nivel" in lbl.text or "Level" in lbl.text:
				print("   Label: '", lbl.text, "'")

	print("\n>>> SIMULATING SECOND CLICK ON btn_lvl (UPGRADING AGAIN) <<<")
	var btn_lvl_2: Button = null
	for node in main_menu.details_box.find_children("*", "Button", true, false):
		if "Subir" in node.text or "Level Up" in node.text:
			btn_lvl_2 = node
			break
	if btn_lvl_2:
		print("Clicking btn_lvl_2: ", btn_lvl_2.text)
		btn_lvl_2.emit_signal("pressed")
		await get_tree().process_frame
		await get_tree().process_frame

	print("\nChildren of details_box after SECOND upgrade:")
	var upgrade_panels_count = 0
	for c in main_menu.details_box.get_children():
		var is_up = false
		for lbl in c.find_children("*", "Label", true, false):
			if "Nivel" in lbl.text or "Level" in lbl.text:
				is_up = true
				print(" [UPGRADE PANEL] Name: '", c.name, "' Label: '", lbl.text, "'")
		if is_up:
			upgrade_panels_count += 1
	print(">>> Total duplicate upgrade panels visible: ", upgrade_panels_count)
	get_tree().quit(0)
