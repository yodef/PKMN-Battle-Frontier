extends Node

func _ready() -> void:
	print("==================================================")
	print("🧪 TESTING TUTORIAL TRANSLATIONS (ES & EN)")
	print("==================================================")
	
	await _test_main_menu_tutorial_translations()
	await _test_battle_tutorial_translations()
	
	print("==================================================")
	print("✅ ALL TUTORIAL TRANSLATION TESTS PASSED!")
	print("==================================================")
	get_tree().quit(0)

func _test_main_menu_tutorial_translations() -> void:
	print("Testing main_menu tutorial translations...")
	var menu_scene = load("res://scenes/main_menu.tscn").instantiate()
	add_child(menu_scene)
	await get_tree().process_frame
	
	# Test Spanish mode
	GameData.set_language("es", false)
	assert(GameData.is_spanish(), "Should be Spanish")
	
	# 1. Confirmation Modal (New Tutorial)
	GameData.tutorial_completed = false
	menu_scene._show_tutorial_confirmation_modal()
	assert("¿Iniciar Tutorial de Combate?" in menu_scene.tutorial_confirm_title_lbl.text, "Title should be in Spanish: " + menu_scene.tutorial_confirm_title_lbl.text)
	assert("Iniciar Tutorial" in menu_scene.btn_confirm_tutorial.text, "Confirm button should be in Spanish: " + menu_scene.btn_confirm_tutorial.text)
	assert(menu_scene.btn_cancel_tutorial.text == "Cancelar", "Cancel button should be Cancelar: " + menu_scene.btn_cancel_tutorial.text)
	
	# 2. Confirmation Modal (Replay Tutorial)
	GameData.tutorial_completed = true
	menu_scene._show_tutorial_confirmation_modal()
	assert("¿Repetir Tutorial de Combate?" in menu_scene.tutorial_confirm_title_lbl.text, "Replay title should be in Spanish")
	assert("Iniciar Práctica" in menu_scene.btn_confirm_tutorial.text, "Practice button should be in Spanish")
	
	# 3. Locked Adventure Modal
	menu_scene._show_tutorial_prompt_for_locked_episode()
	assert("¡Modo Aventura Bloqueado!" in menu_scene.tutorial_confirm_title_lbl.text, "Locked title should be in Spanish")
	assert("Iniciar Tutorial" in menu_scene.btn_confirm_tutorial.text, "Confirm should be in Spanish")
	
	# 4. Intro Step 1 Guidance Modal
	menu_scene._show_tutorial_step1_intro_guidance()
	assert("¡Bienvenido a Pokémon Battle Frontier!" in menu_scene.tutorial_confirm_title_lbl.text, "Intro title should be Spanish")
	assert("Ir a la Tienda" in menu_scene.btn_confirm_tutorial.text, "Intro button should be Spanish")
	
	# 5. Card Anatomy Modal
	menu_scene._show_card_anatomy_and_starter_modal()
	assert("Anatomía de una Carta Pokémon" in menu_scene.tutorial_confirm_title_lbl.text, "Anatomy title should be Spanish")
	assert("Elegir Pokémon Inicial" in menu_scene.btn_confirm_tutorial.text, "Anatomy button should be Spanish")
	
	# 6. Starter Selection Modal
	menu_scene._setup_starter_selection_modal()
	menu_scene.starter_region_active = "Kanto"
	menu_scene._refresh_starter_cards_display()
	var first_card = menu_scene.starter_cards_row.get_child(0)
	assert(first_card != null, "Should have starter cards")
	var card_text = first_card.get_child(0).get_child(1).get_child(1).text # stats_lbl
	assert("Tipo:" in card_text, "Card stat label should say 'Tipo:' in Spanish: " + card_text)
	var moves_text = first_card.get_child(0).get_child(1).get_child(2).text # moves_lbl
	assert("Movimientos:" in moves_text, "Card moves label should say 'Movimientos:' in Spanish: " + moves_text)
	var select_btn = first_card.get_child(0).get_child(2) as Button
	assert("Elegir" in select_btn.text, "Select button should say 'Elegir' in Spanish: " + select_btn.text)
	
	# 7. Camp Evolution Tutorial Guidance (Not yet evolved, 0 stones)
	GameData.tutorial_completed = false
	GameData.campaign_submode = "ADVENTURE"
	GameData.set_tutorial_starter(1) # Charmander (#1) -> Charmeleon (#6)
	GameData.adventure_player_team_state = [{"id": 1, "name": "Charmander"}]
	GameData.adventure_inventory["fire_stone"] = 0
	GameData.tutorial_step = 4
	menu_scene._show_camp_evolution_tutorial_guidance()
	assert("Campamento y Evolución" in menu_scene.tutorial_confirm_title_lbl.text, "Camp evolution title should be Spanish: " + menu_scene.tutorial_confirm_title_lbl.text)
	assert("Abrir Evolución" in menu_scene.btn_confirm_tutorial.text, "Open evolution button should be Spanish")
	
	# 8. Camp Evolution Tutorial Guidance (Has stone in inventory)
	GameData.add_campaign_stone("Fire", 1)
	menu_scene._show_camp_evolution_tutorial_guidance()
	assert("¡Listo para Evolucionar!" in menu_scene.tutorial_confirm_title_lbl.text, "Ready to evolve title should be Spanish: " + menu_scene.tutorial_confirm_title_lbl.text)
	assert("Entendido" in menu_scene.btn_confirm_tutorial.text, "Understood button should be Spanish")
	
	# 9. Camp Combat 2 Prompt
	menu_scene._show_camp_combat2_prompt()
	assert("¡Evolución Completada!" in menu_scene.tutorial_confirm_title_lbl.text, "Combat 2 prompt title should be Spanish")
	assert("Iniciar Combate Avanzado" in menu_scene.btn_confirm_tutorial.text, "Combat 2 prompt button should be Spanish")
	
	# Test English mode switch
	GameData.set_language("en", false)
	assert(not GameData.is_spanish(), "Should be English")
	
	GameData.tutorial_completed = false
	menu_scene._show_tutorial_confirmation_modal()
	assert("Start Combat Tutorial?" in menu_scene.tutorial_confirm_title_lbl.text, "Title should be in English: " + menu_scene.tutorial_confirm_title_lbl.text)
	assert("Start Tutorial" in menu_scene.btn_confirm_tutorial.text, "Confirm button should be in English: " + menu_scene.btn_confirm_tutorial.text)
	assert(menu_scene.btn_cancel_tutorial.text == "Cancel", "Cancel button should be Cancel: " + menu_scene.btn_cancel_tutorial.text)
	
	# Starter card in English
	menu_scene._refresh_starter_cards_display()
	first_card = menu_scene.starter_cards_row.get_child(0)
	card_text = first_card.get_child(0).get_child(1).get_child(1).text # stats_lbl
	assert("Type:" in card_text, "Card stat label should say 'Type:' in English: " + card_text)
	moves_text = first_card.get_child(0).get_child(1).get_child(2).text # moves_lbl
	assert("Moves:" in moves_text, "Card moves label should say 'Moves:' in English: " + moves_text)
	select_btn = first_card.get_child(0).get_child(2) as Button
	assert("Choose" in select_btn.text, "Select button should say 'Choose' in English: " + select_btn.text)
	
	# Camp guidance in English
	GameData.adventure_inventory.clear()
	menu_scene._show_camp_evolution_tutorial_guidance()
	assert("Camp & Evolution" in menu_scene.tutorial_confirm_title_lbl.text, "Camp evolution title should be English: " + menu_scene.tutorial_confirm_title_lbl.text)
	assert("Open Evolution" in menu_scene.btn_confirm_tutorial.text, "Open evolution button should be English")
	
	GameData.add_campaign_stone("Fire", 1)
	menu_scene._show_camp_evolution_tutorial_guidance()
	assert("Ready to Evolve!" in menu_scene.tutorial_confirm_title_lbl.text, "Ready to evolve title should be English")
	assert("Understood" in menu_scene.btn_confirm_tutorial.text, "Understood button should be English")
	
	menu_scene._show_camp_combat2_prompt()
	assert("Evolution Complete!" in menu_scene.tutorial_confirm_title_lbl.text, "Combat 2 prompt title should be English")
	assert("Start Advanced Battle" in menu_scene.btn_confirm_tutorial.text, "Combat 2 prompt button should be English")
	
	menu_scene.queue_free()
	print("   ✓ main_menu tutorial translations verified successfully in ES and EN.")

func _test_battle_tutorial_translations() -> void:
	print("Testing battle tutorial translations...")
	GameData.is_tutorial_mode = true
	GameData.tutorial_combat_phase = 1
	var battle_scene = load("res://scenes/battle.tscn").instantiate()
	add_child(battle_scene)
	await get_tree().process_frame
	
	# Test Spanish mode in battle
	GameData.set_language("es", false)
	
	battle_scene._show_forfeit_confirmation_modal()
	assert("¿SALIR DEL TUTORIAL?" in battle_scene.forfeit_title_lbl.text, "Forfeit title should be Spanish: " + battle_scene.forfeit_title_lbl.text)
	assert("Salir del Tutorial" in battle_scene.btn_confirm_forfeit.text, "Forfeit confirm should be Spanish: " + battle_scene.btn_confirm_forfeit.text)
	assert("Seguir Luchando" in battle_scene.btn_cancel_forfeit.text, "Forfeit cancel should be Spanish: " + battle_scene.btn_cancel_forfeit.text)
	
	# Test show callout with default btn_text
	battle_scene._show_tutorial_callout(
		"test_es",
		GameData.tr_text("TUTORIAL • STEP 1 OF 5", "TUTORIAL • PASO 1 DE 5"),
		GameData.tr_text("🎓 Welcome to Pokémon Combat!", "🎓 ¡Bienvenido al Combate Pokémon!"),
		GameData.tr_text("Arena explanation", "Explicación de la arena")
	)
	assert(battle_scene.tutorial_callout_badge_lbl.text == "TUTORIAL • PASO 1 DE 5", "Badge should be Spanish")
	assert(battle_scene.tutorial_callout_title_lbl.text == "🎓 ¡Bienvenido al Combate Pokémon!", "Title should be Spanish")
	assert(battle_scene.btn_tutorial_callout_next.text == "¡Entendido! ➡️", "Next button default should be Spanish")
	
	# Test game over buttons
	GameData.tutorial_completed = false
	GameData.just_completed_tutorial_combat1 = true
	battle_scene.show_game_over(
		GameData.tr_text("🎓 COMBAT 1 COMPLETE!", "🎓 ¡COMBATE 1 COMPLETADO!"),
		"Combat 1 message"
	)
	assert("Ir al Campamento / Evolución" in battle_scene.btn_game_over_menu.text, "Game over button should be Spanish: " + battle_scene.btn_game_over_menu.text)
	
	# Switch to English
	GameData.set_language("en", false)
	battle_scene._show_forfeit_confirmation_modal()
	assert("EXIT TUTORIAL?" in battle_scene.forfeit_title_lbl.text, "Forfeit title should be English: " + battle_scene.forfeit_title_lbl.text)
	assert("Exit Tutorial" in battle_scene.btn_confirm_forfeit.text, "Forfeit confirm should be English: " + battle_scene.btn_confirm_forfeit.text)
	assert("Keep Battling" in battle_scene.btn_cancel_forfeit.text, "Forfeit cancel should be English: " + battle_scene.btn_cancel_forfeit.text)
	
	battle_scene._show_tutorial_callout(
		"test_en",
		GameData.tr_text("TUTORIAL • STEP 1 OF 5", "TUTORIAL • PASO 1 DE 5"),
		GameData.tr_text("🎓 Welcome to Pokémon Combat!", "🎓 ¡Bienvenido al Combate Pokémon!"),
		GameData.tr_text("Arena explanation", "Explicación de la arena")
	)
	assert(battle_scene.tutorial_callout_badge_lbl.text == "TUTORIAL • STEP 1 OF 5", "Badge should be English")
	assert(battle_scene.tutorial_callout_title_lbl.text == "🎓 Welcome to Pokémon Combat!", "Title should be English")
	assert(battle_scene.btn_tutorial_callout_next.text == "Understood! ➡️", "Next button default should be English")
	
	battle_scene.show_game_over(
		GameData.tr_text("🎓 COMBAT 1 COMPLETE!", "🎓 ¡COMBATE 1 COMPLETADO!"),
		"Combat 1 message"
	)
	assert("Go to Camp / Evolution" in battle_scene.btn_game_over_menu.text, "Game over button should be English: " + battle_scene.btn_game_over_menu.text)
	
	battle_scene.queue_free()
	print("   ✓ battle tutorial translations verified successfully in ES and EN.")
