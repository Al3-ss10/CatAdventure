extends Control

# Percorsi delle scene — adattali alla tua struttura di progetto
const SCENE_LEVEL_SELECT = "res://scenes/LevelSelect.tscn"
const SCENE_INVENTORY    = "res://scenes/Inventory.tscn"
const SCENE_SHOP         = "res://scenes/Shop.tscn"
const SCENE_SKIN         = "res://scenes/SkinSelect.tscn"

func _ready() -> void:
	$CenterContainer/VBoxContainer/BtnGioca.pressed.connect(_on_gioca)
	$CenterContainer/VBoxContainer/BtnInventario.pressed.connect(_on_inventario)
	$CenterContainer/VBoxContainer/BtnShop.pressed.connect(_on_shop)
	$CenterContainer/VBoxContainer/BtnSkin.pressed.connect(_on_skin)
	$CenterContainer/VBoxContainer/BtnEsci.pressed.connect(_on_esci)

func _on_gioca() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_inventario() -> void:
	get_tree().change_scene_to_file("res://scenes/InventoryScene.tscn")

func _on_shop() -> void:
	get_tree().change_scene_to_file("res://scenes/ShopScene.tscn")

func _on_skin() -> void:
	get_tree().change_scene_to_file(SCENE_SKIN)

func _on_esci() -> void:
	get_tree().quit()
