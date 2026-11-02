extends Node

var frames = 0
var menu

func _ready() -> void:
	GameData.unlock_pokemon(7) # Desbloquear Charizard
	menu = load("res://scenes/main_menu.tscn").instantiate()
	add_child(menu)
	menu._on_collection_pressed()
	menu.open_collection_detail(11) # Charizard

func _process(_delta: float) -> void:
	frames += 1
	if frames == 5:
		var img = get_viewport().get_texture().get_image()
		if img:
			var path = "D:/Games/Pokemon Battle Frontier/APP/pkmn-battle-frontier/tests/charizard_detail_screenshot.png"
			img.save_png(path)
			print("Bulbasaur Detail Screenshot guardado en: ", path)
		get_tree().quit(0)
