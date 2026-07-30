extends Control

# ─── Node References ─────────────────────────────────────────────────────────
@onready var item_grid       : GridContainer  = $UI/Body/Left/ScrollContainer/ItemGrid
@onready var detail_panel    : VBoxContainer  = $UI/Body/Right/DetailPanel
@onready var filter_bar      : HBoxContainer  = $UI/FilterBar
@onready var item_count_label: Label          = $UI/TopBar/TopBarHBox/ItemCountLabel
@onready var use_button      : Button         = $UI/Body/Right/DetailPanel/Buttons/UseButton
@onready var drop_button     : Button         = $UI/Body/Right/DetailPanel/Buttons/DropButton
@onready var equip_button    : Button         = $UI/Body/Right/DetailPanel/Buttons/EquipButton

var item_card_scene := preload("res://scenes/InventoryCard.tscn")
var active_filter: String = "all"
var selected_item: Dictionary = {}

# ─── Ready ───────────────────────────────────────────────────────────────────
func _ready() -> void:
	detail_panel.visible = false
	_build_filter_buttons()
	_populate_grid("all")
	use_button.pressed.connect(_on_use_pressed)
	drop_button.pressed.connect(_on_drop_pressed)
	equip_button.pressed.connect(_on_equip_pressed)
	$UI/TopBar/TopBarHBox/BackButton.pressed.connect(_on_back_pressed)

# ─── Back ────────────────────────────────────────────────────────────────────
func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

# ─── Filter Bar ──────────────────────────────────────────────────────────────
func _build_filter_buttons() -> void:
	var filters := ["all", "weapon", "armor", "consumable", "accessory"]
	for f in filters:
		var btn := Button.new()
		btn.text = f.capitalize()
		btn.name = "Filter_" + f
		btn.toggle_mode = true
		btn.button_pressed = (f == "all")
		btn.pressed.connect(_on_filter_pressed.bind(f, btn))
		filter_bar.add_child(btn)

func _on_filter_pressed(filter: String, pressed_btn: Button) -> void:
	active_filter = filter
	for child in filter_bar.get_children():
		if child is Button:
			child.button_pressed = (child == pressed_btn)
	_populate_grid(filter)

# ─── Item Grid ───────────────────────────────────────────────────────────────
func _populate_grid(filter: String) -> void:
	for child in item_grid.get_children():
		child.queue_free()
	for item_id in Global.ListaPowerUp:
		if Global.ListaPowerUp[item_id] <= 0:
			continue
		if not Global.ItemDB.has(item_id):
			continue
		var item: Dictionary = Global.ItemDB[item_id].duplicate()
		item["quantity"] = Global.ListaPowerUp[item_id]
		if filter != "all" and item["type"] != filter:
			continue
		var card: PanelContainer = item_card_scene.instantiate()
		item_grid.add_child(card)
		card.setup(item)
		card.card_selected.connect(_on_card_selected.bind(item))
	item_count_label.text = "Items: " + str(item_grid.get_child_count())

# ─── Detail Panel ────────────────────────────────────────────────────────────
func _on_card_selected(item: Dictionary) -> void:
	selected_item = item
	detail_panel.visible = true
	detail_panel.get_node("ItemName").text    = item.get("name", "")
	detail_panel.get_node("ItemDesc").text    = item.get("desc", "")
	detail_panel.get_node("ItemStat").text    = item.get("stat", "")
	detail_panel.get_node("QuantityLabel").text = "Quantity: " + str(Global.ListaPowerUp.get(item.get("id", ""), 0))
	detail_panel.get_node("RarityLabel").text = item.get("rarity", "").to_upper()
	detail_panel.get_node("TypeLabel").text   = "[" + item.get("type", "").capitalize() + "]"
	var equipped: bool = item.get("equipped", false)
	equip_button.text = "UNEQUIP" if equipped else "EQUIP"
	# Mostra USE solo per consumabili
	use_button.visible = item.get("type", "") == "consumable"
	equip_button.visible = item.get("type", "") != "consumable"
# ─── Buttons ─────────────────────────────────────────────────────────────────
func _on_use_pressed() -> void:
	if selected_item["id"] == 'polpetta':
		if (Global.vita ==1 or Global.vita ==2) and Global.ListaPowerUp['polpetta'] >0:
			Global.vita+=1
			Global.ListaPowerUp['polpetta'] -=1

func _on_drop_pressed() -> void:
	pass # DA COMPLETARE

func _on_equip_pressed() -> void:
	var item_id: String = selected_item.get("id", "")
	
	if item_id == "gomitolo" and Global.ListaPowerUp["gomitolo"] > 0:
		if Global.gomitolo:
			Global.gomitolo = false
			equip_button.text = "EQUIP"
		else:
			Global.gomitolo = true
			Global.box = false
			Global.ListaPowerUp["gomitolo"] -= 1
			equip_button.text = "UNEQUIP"
			_populate_grid(active_filter)

	elif item_id == "scatola" and Global.ListaPowerUp["scatola"] > 0:
		if Global.box:
			Global.box = false
			equip_button.text = "EQUIP"
		else:
			Global.box = true
			Global.gomitolo = false
			Global.ListaPowerUp["scatola"] -= 1
			equip_button.text = "UNEQUIP"
			_populate_grid(active_filter)
