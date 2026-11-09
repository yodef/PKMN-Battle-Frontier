extends Node

func _ready() -> void:
	print("--- INICIANDO TEST: ADVENTURE REGIONS (5 BOTONES) & CHAOS ODYSSEY GUIDE ---")
	
	var main_menu_scene = load("res://scenes/main_menu.tscn")
	assert(main_menu_scene != null, "scenes/main_menu.tscn no pudo cargarse")
	
	var main_menu = main_menu_scene.instantiate()
	add_child(main_menu)
	
	# Asegurar tutorial completado
	GameData.tutorial_completed = true
	
	# 1. VERIFICAR NAVEGACIÓN HACIA ADVENTURE REGIONS
	print("[TEST 1] Verificando entrada a Adventure Regions...")
	main_menu.campaign_hub_modal.visible = true
	main_menu._on_hub_adventure_pressed()
	
	assert(main_menu.campaign_hub_modal.visible == false, "CampaignHubModal no se ocultó")
	assert(main_menu.adventure_regions_modal != null, "adventure_regions_modal es null")
	assert(main_menu.adventure_regions_modal.visible == true, "adventure_regions_modal no se hizo visible")
	print("✓ Apertura de AdventureRegionsModal validada!")
	
	# 2. VERIFICAR LOS 5 BOTONES DE REGIONES
	print("[TEST 2] Verificando los 5 botones de regiones...")
	assert(main_menu.btn_enter_kanto != null, "btn_enter_kanto es null")
	assert(main_menu.btn_enter_johto != null, "btn_enter_johto es null")
	assert(main_menu.btn_enter_hoenn != null, "btn_enter_hoenn es null")
	assert(main_menu.btn_enter_sinnoh != null, "btn_enter_sinnoh es null")
	assert(main_menu.btn_enter_league != null, "btn_enter_league es null")
	
	# Kanto debe estar habilitado
	assert(main_menu.btn_enter_kanto.disabled == false, "Kanto debería estar habilitado")
	
	# Johto, Hoenn, Sinnoh deben estar bloqueados y mencionar en desarrollo
	assert(main_menu.btn_enter_johto.disabled == true, "Johto debe estar deshabilitado")
	assert("desarrollo" in main_menu.btn_enter_johto.text.to_lower() or "development" in main_menu.btn_enter_johto.text.to_lower(), "Johto debe mencionar en desarrollo")
	
	assert(main_menu.btn_enter_hoenn.disabled == true, "Hoenn debe estar deshabilitado")
	assert("desarrollo" in main_menu.btn_enter_hoenn.text.to_lower() or "development" in main_menu.btn_enter_hoenn.text.to_lower(), "Hoenn debe mencionar en desarrollo")
	
	assert(main_menu.btn_enter_sinnoh.disabled == true, "Sinnoh debe estar deshabilitado")
	assert("desarrollo" in main_menu.btn_enter_sinnoh.text.to_lower() or "development" in main_menu.btn_enter_sinnoh.text.to_lower(), "Sinnoh debe mencionar en desarrollo")
	
	# Liga Pokémon debe estar bloqueada hasta conseguir todas las medallas
	assert(main_menu.btn_enter_league.disabled == true, "Liga Pokémon debe estar bloqueada sin todas las medallas")
	assert("bloqueada" in main_menu.btn_enter_league.text.to_lower() or "locked" in main_menu.btn_enter_league.text.to_lower(), "Liga Pokémon debe indicar que está bloqueada")
	print("✓ Los 5 botones de regiones configurados correctamente!")
	
	# 3. VERIFICAR ACCESO A KANTO Y RETORNO
	print("[TEST 3] Verificando navegación Kanto -> Regiones -> Hub...")
	main_menu.btn_enter_kanto.emit_signal("pressed")
	assert(main_menu.adventure_regions_modal.visible == false, "adventure_regions_modal no se ocultó al entrar a Kanto")
	assert(main_menu.adventure_episodes_modal.visible == true, "adventure_episodes_modal no se abrió")
	
	# Botón de regreso a regiones
	main_menu.btn_close_adventure_episodes.emit_signal("pressed")
	assert(main_menu.adventure_episodes_modal.visible == false, "adventure_episodes_modal no se ocultó al regresar")
	assert(main_menu.adventure_regions_modal.visible == true, "adventure_regions_modal no se volvió a mostrar")
	
	# Botón de regreso al Hub
	main_menu.btn_close_adventure_regions.emit_signal("pressed")
	assert(main_menu.adventure_regions_modal.visible == false, "adventure_regions_modal no se ocultó al salir")
	assert(main_menu.campaign_hub_modal.visible == true, "campaign_hub_modal no volvió al salir de regiones")
	print("✓ Flujo de navegación de regreso verificado exitosamente!")
	
	# 4. VERIFICAR GUÍA DE CHAOS ODYSSEY
	print("[TEST 4] Verificando guía dinámica de Chaos Odyssey y Stadium...")
	main_menu._open_guide_modal("CHAOS", main_menu.campaign_hub_modal)
	assert(main_menu.stadium_guide_modal.visible == true, "stadium_guide_modal no es visible")
	
	var title_lbl = main_menu.stadium_guide_modal.get_node("Box/Title") as Label
	var p3_header = main_menu.stadium_guide_modal.get_node("Box/GuideScroll/GuideVBox/Phase3Card/Margin/P3VBox/P3Header") as Label
	var p3_info = main_menu.stadium_guide_modal.get_node("Box/GuideScroll/GuideVBox/Phase3Card/Margin/P3VBox/P3Info") as Label
	
	assert("CHAOS" in title_lbl.text, "El título no contiene CHAOS: %s" % title_lbl.text)
	assert("CRYSTAL ONIX" in p3_header.text, "El header del Boss no contiene CRYSTAL ONIX")
	assert("900 HP" in p3_info.text, "La descripción del Boss no menciona 900 HP")
	assert("Crystal Blast" in p3_info.text, "La descripción no menciona Crystal Blast")
	assert("Diamante" in p3_info.text or "Diamond" in p3_info.text, "No menciona la pasiva de diamantes")
	print("✓ Guía de Chaos Odyssey validada correctamente con información de Crystal Onix!")
	
	# Cambiar a STADIUM y verificar que se restaure
	main_menu._open_guide_modal("STADIUM", main_menu.campaign_hub_modal)
	assert("STADIUM" in title_lbl.text, "El título no contiene STADIUM")
	assert("PHASE 3" in p3_header.text, "No se restauró la Fase 3 del Stadium")
	print("✓ Guía de Pokémon Stadium restaurada correctamente!")
	
	# 5. VERIFICAR TEXTO DE GUÍA EN EL CAMPAMENTO SEGÚN SUBMODO
	print("[TEST 5] Verificando botón de guía en el campamento...")
	GameData.campaign_submode = "CHAOS"
	main_menu.update_campaign_ui()
	assert("Chaos" in main_menu.btn_camp_stadium_guide.text, "El botón en campamento Chaos no dice Chaos")
	
	GameData.campaign_submode = "TOURNAMENT"
	main_menu.update_campaign_ui()
	assert("Encounters" in main_menu.btn_camp_stadium_guide.text or "Stadium" in main_menu.btn_camp_stadium_guide.text, "El botón en campamento Stadium no dice Encounters/Stadium")
	print("✓ Textos del campamento según submodo verificados exitosamente!")
	
	print("--- TODOS LOS TESTS DE ADVENTURE REGIONS Y GUÍA CHAOS PASARON EXITOSAMENTE ---")
	get_tree().quit(0)
