extends Node

func _ready() -> void:
	print("--- INICIANDO TEST DE TABLA GLOBAL DE TIPOS Y DEBILIDAD (+2) ---")
	
	# 1. Verificar carga de la tabla global de tipos
	assert(GameData.global_type_chart.size() >= 9, "Debe haber al menos 9 tipos en la tabla global.")
	assert(GameData.global_type_chart["GRASS"]["weakness"] == "FIRE", "GRASS debe ser débil a FIRE.")
	assert(GameData.global_type_chart["GRASS"]["resistance"] == "GROUND", "GRASS debe ser resistente a GROUND.")
	assert(GameData.global_type_chart["FIRE"]["weakness"] == "WATER", "FIRE debe ser débil a WATER.")
	assert(GameData.global_type_chart["FIRE"]["resistance"] == "GRASS", "FIRE debe ser resistente a GRASS.")
	assert(GameData.global_type_chart["WATER"]["weakness"] in ["ELECTRIC", "THUNDER"], "WATER debe ser débil a ELECTRIC.")
	assert(GameData.global_type_chart["WATER"]["resistance"] == "FIRE", "WATER debe ser resistente a FIRE.")
	print("✓ Verificación 1: Tabla global de tipos cargada correctamente.")
	
	# 2. Normalización y equivalencia THUNDER <-> ELECTRIC
	assert(GameData.types_match("THUNDER", "ELECTRIC") == true, "THUNDER y ELECTRIC deben ser equivalentes.")
	assert(GameData.types_match("electric", "thunder") == true, "Debe ser insensible a mayúsculas.")
	assert(GameData.types_match("FIRE", "WATER") == false, "FIRE y WATER no son equivalentes.")
	assert(GameData.types_match("NONE", "FIRE") == false, "NONE nunca coincide.")
	print("✓ Verificación 2: Equivalencia THUNDER/ELECTRIC y match de tipos funcional.")
	
	# 3. Herencia global vs Prioridad de PKMN
	var bulba = GameData.get_pokemon_data(0)
	assert(bulba["weakness"] == "FIRE", "Bulbasaur debe heredar debilidad FIRE de la tabla global. Actual: " + str(bulba["weakness"]))
	assert(bulba["resistant"] == "GROUND", "Bulbasaur debe heredar resistencia GROUND de la tabla global. Actual: " + str(bulba["resistant"]))
	
	var charma = GameData.get_pokemon_data(1)
	assert(charma["weakness"] == "WATER", "Charmander debe heredar debilidad WATER.")
	assert(charma["resistant"] == "GRASS", "Charmander debe heredar resistencia GRASS.")
	
	var squirtle = GameData.get_pokemon_data(2)
	assert(GameData.types_match(squirtle["weakness"], "ELECTRIC"), "Squirtle debe heredar debilidad ELECTRIC/THUNDER.")
	assert(squirtle["resistant"] == "FIRE", "Squirtle debe heredar resistencia FIRE.")
	
	var pichu = GameData.get_pokemon_data(3)
	assert(pichu["weakness"] == "GROUND", "Pichu debe heredar debilidad GROUND.")
	assert(pichu["resistant"] == "WATER", "Pichu debe heredar resistencia WATER.")
	
	# Weedle (id 13: DARK, con FIRE en su fila de poke_stats) -> Prioridad de PKMN sobre VARIABLE
	var weedle = GameData.get_pokemon_data(13)
	assert(weedle["weakness"] == "FIRE", "Weedle debe usar su debilidad propia FIRE. Actual: " + str(weedle["weakness"]))
	assert(weedle["resistant"] == "PSYCHIC", "Weedle debe heredar resistencia PSYCHIC de DARK.")
	
	# Pidgey (id 16: NORMAL, con THUNDER y NONE en su fila) -> Prioridad de PKMN
	var pidgey = GameData.get_pokemon_data(16)
	assert(GameData.types_match(pidgey["weakness"], "THUNDER"), "Pidgey debe usar su debilidad propia THUNDER.")
	assert(pidgey["resistant"] == "NONE", "Pidgey debe mantener su resistencia explícita NONE.")
	
	# Charizard (id 7: FIRE, Stage 2) -> hereda WATER (+2) y GRASS (-2)
	var charizard = GameData.get_pokemon_data(7)
	assert(charizard["name"] == "Charizard", "ID 7 debe ser Charizard.")
	assert(charizard["weakness"] == "WATER", "Charizard debe ser débil a WATER.")
	assert(charizard["resistant"] == "GRASS", "Charizard debe ser resistente a GRASS.")
	
	# Wartortle (id 8: WATER, Stage 1, Pasiva Protect) -> hereda ELECTRIC (+2) y FIRE (-2)
	var wartortle = GameData.get_pokemon_data(8)
	assert(wartortle["name"] == "Wartortle", "ID 8 debe ser Wartortle.")
	assert(wartortle["passive_name"] == "Protect", "Wartortle debe tener la pasiva Protect.")
	assert(GameData.types_match(wartortle["weakness"], "ELECTRIC"), "Wartortle debe ser débil a ELECTRIC.")
	
	# Blastoise (id 9: WATER, Stage 2) -> hereda ELECTRIC (+2) y FIRE (-2)
	var blastoise = GameData.get_pokemon_data(9)
	assert(blastoise["name"] == "Blastoise", "ID 9 debe ser Blastoise.")
	assert(blastoise["hp"] == 36, "Blastoise debe tener 36 HP.")
	assert(blastoise["energy"] == 8, "Blastoise debe tener 8 EN.")
	assert(blastoise["m2_name"] == "Hydro Pump", "Blastoise debe tener Hydro Pump como move2.")
	print("✓ Verificación 3: Prioridad de datos individuales del PKMN sobre la tabla global verificada.")
	
	# 4. AssembledCard muestra '+2' en vez de 'x2'
	var card_scene = load("res://scenes/assembled_card.tscn").instantiate()
	add_child(card_scene)
	card_scene.setup(bulba, true)
	
	var weak_val = card_scene.get_node("CardPanel/Margin/VBox/FooterHBox/WeakBox/WeakVal") as Label
	var weak_icon = card_scene.get_node("CardPanel/Margin/VBox/FooterHBox/WeakBox/WeakIcon") as TextureRect
	var res_val = card_scene.get_node("CardPanel/Margin/VBox/FooterHBox/ResBox/ResVal") as Label
	var res_icon = card_scene.get_node("CardPanel/Margin/VBox/FooterHBox/ResBox/ResIcon") as TextureRect
	
	assert(weak_val.text == "+2", "El valor de debilidad en la carta debe ser '+2'. Actual: " + weak_val.text)
	assert(weak_icon.visible == true, "Icono de debilidad debe ser visible para Bulbasaur.")
	assert(res_val.text == "-2", "El valor de resistencia en la carta debe ser '-2'. Actual: " + res_val.text)
	assert(res_icon.visible == true, "Icono de resistencia debe ser visible para Bulbasaur.")
	print("✓ Verificación 4: AssembledCard muestra '+2' y '-2' correctamente.")
	
	# 5. Vista de Detalle en Menú Principal
	var menu = load("res://scenes/main_menu.tscn").instantiate()
	add_child(menu)
	menu._on_collection_pressed()
	menu.open_collection_detail(0) # Bulbasaur
	
	var deb_val_lbl = menu.get_node("CollectionModal/DetailView/DetailsScroll/DetailsBox/StatsPanel/StatsMargin/StatsVBox/DebRow/DebVal") as Label
	var res_val_lbl = menu.get_node("CollectionModal/DetailView/DetailsScroll/DetailsBox/StatsPanel/StatsMargin/StatsVBox/ResRow/ResVal") as Label
	
	assert(deb_val_lbl.text.contains("+2"), "El texto de debilidad en detalle debe indicar '+2'. Actual: " + deb_val_lbl.text)
	assert(not deb_val_lbl.text.contains("x2"), "No debe decir 'x2'. Actual: " + deb_val_lbl.text)
	assert(res_val_lbl.text.contains("-2"), "El texto de resistencia en detalle debe indicar '-2'. Actual: " + res_val_lbl.text)
	print("✓ Verificación 5: Detalle de carta en colección muestra '(+2 daño recibido)' y '(-2 daño recibido)'.")
	
	print("\n🎉 TODOS LOS TESTS DE TIPOS, PRIORIDADES Y DEBILIDAD (+2) PASARON EXITOSAMENTE.")
	get_tree().quit(0)
