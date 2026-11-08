extends Node

func _ready() -> void:
	print("========================================")
	print("--- TEST NEW FEATURES START ---")
	print("========================================")
	
	# TEST 1: Profile Erase Button and Modal
	print("\n>>> Testing Profile Erase...")
	var mm = load("res://scenes/main_menu.tscn").instantiate()
	add_child(mm)
	assert(mm.btn_erase_profile != null, "btn_erase_profile should exist")
	print("BtnEraseProfile text: ", mm.btn_erase_profile.text)
	
	# Open erase confirm modal
	mm._on_erase_profile_prompt_pressed()
	assert(mm.erase_confirm_modal.visible == true, "erase_confirm_modal should be visible")
	print("Erase modal opened successfully.")
	
	# Cancel erase
	mm.btn_cancel_erase.emit_signal("pressed")
	assert(mm.erase_confirm_modal.visible == false, "erase_confirm_modal should close on cancel")
	print("Erase modal cancelled successfully.")
	
	# TEST 2: First-time Settings Modal before Tutorial
	print("\n>>> Testing First-Time Settings Modal...")
	GameData.tutorial_completed = false
	GameData.tutorial_step = 1
	GameData.initial_settings_shown = false
	
	mm._start_tutorial_flow_or_settings()
	assert(mm.settings_modal.visible == true, "Settings modal should open on first tutorial entry")
	print("Settings modal opened! btn_close_settings text: ", mm.btn_close_settings.text)
	
	# Change language to Spanish and check button text
	GameData.set_language("es")
	mm._on_language_changed("es")
	print("Language set to ES. btn_close_settings text: ", mm.btn_close_settings.text)
	assert("Continuar" in mm.btn_close_settings.text, "Button text should offer continuing to tutorial in ES")
	
	# Press continue to tutorial
	mm._on_close_settings_pressed()
	assert(mm.settings_modal.visible == false, "Settings modal should close")
	assert(GameData.initial_settings_shown == true, "initial_settings_shown should now be true")
	print("Settings confirmed! initial_settings_shown: ", GameData.initial_settings_shown)
	
	# TEST 3: Battle Log Translations
	print("\n>>> Testing Battle Log Translations...")
	var battle = load("res://scenes/battle.tscn").instantiate()
	add_child(battle)
	
	GameData.set_language("es")
	battle.log_action("[b]Tactical switch![/b] Bulbasaur withdraws, [b]Charmander[/b] enters!")
	print("Log text (ES): ", battle.log_label.text)
	assert("Cambio" in battle.log_label.text or "retira" in battle.log_label.text, "Battle log should be translated to Spanish")
	
	battle.log_action("Trainer used [color=cyan]Potion[/color] on [b]Bulbasaur[/b], restoring [color=green]+10 HP[/color]! 🧪 (10/10)")
	print("Log text 2 (ES): ", battle.log_label.text)
	assert("Poción" in battle.log_label.text or "restaurando" in battle.log_label.text, "Potion log should be in Spanish")
	
	# Switch to English and verify
	GameData.set_language("en")
	battle._on_battle_language_changed("en")
	print("Log text (EN): ", battle.log_label.text)
	assert("Potion" in battle.log_label.text, "Battle log should revert to English when language is EN")
	
	battle.queue_free()
	mm.queue_free()
	
	print("\n========================================")
	print("ALL NEW FEATURES VERIFIED SUCCESSFULLY!")
	print("========================================")
	get_tree().quit(0)
