extends Control

const RARITY_COLORS := {
	"common":   Color("#9d9d9d"),
	"uncommon": Color("#00a300"),
	"rare":     Color("#4da6ff"),
	"epic":     Color("#b04dff"),
	"legendary":Color("#ffaa00"),
}

var selected_item: Dictionary = {}
var active_filter: String = "all"
var selected_qty: int = 1

@onready var gold_label        : Label          = $UI/TopBar/TopBarHBox/GoldLabel
@onready var item_grid         : GridContainer  = $UI/Body/Left/ScrollContainer/ItemGrid
@onready var detail_panel      : VBoxContainer  = $UI/Body/Right/DetailPanel
@onready var buy_button        : Button         = $UI/Body/Right/DetailPanel/BuyButton
@onready var notification_anim : PanelContainer = $UI/NotificationAnim
@onready var notif_label       : Label          = $UI/NotificationAnim/NotifLabel
@onready var filter_bar        : HBoxContainer  = $UI/FilterBar

var item_card_scene := preload("res://scenes/ItemCard.tscn")

# ─── Ready ───────────────────────────────────────────────────────────────────
func _ready() -> void:
	_update_gold_label()
	_build_filter_buttons()
	_populate_grid("all")
	detail_panel.visible = false
	notification_anim.visible = false
	buy_button.pressed.connect(_on_buy_pressed)
	$UI/TopBar/TopBarHBox/BackButton.pressed.connect(_on_back_pressed)
	if detail_panel.has_node("QtyHBox/QtyMinusButton"):
		detail_panel.get_node("QtyHBox/QtyMinusButton").pressed.connect(_on_qty_minus)
	if detail_panel.has_node("QtyHBox/QtyPlusButton"):
		detail_panel.get_node("QtyHBox/QtyPlusButton").pressed.connect(_on_qty_plus)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

# ─── Gold HUD ────────────────────────────────────────────────────────────────
func _update_gold_label() -> void:
	gold_label.text = str(Global.money) + " G"

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

	for item_id in Global.ItemDB:
		var item: Dictionary = Global.ItemDB[item_id]
		if filter != "all" and item["type"] != filter:
			continue
		var owned: bool = Global.ListaPowerUp.get(item_id, 0) > 0
		var card: PanelContainer = item_card_scene.instantiate()
		item_grid.add_child(card)
		# NB: "owned" qui serve solo a mostrare un badge informativo
		# nella ItemCard — non deve disabilitare/scurire il pulsante d'acquisto.
		# Se ItemCard.gd scurisce la card quando owned=true, va corretto lì.
		card.setup(item, owned)
		card.card_selected.connect(_on_card_selected.bind(item))

# ─── Detail Panel ────────────────────────────────────────────────────────────
func _on_card_selected(item: Dictionary) -> void:
	selected_item = item
	selected_qty = 1
	detail_panel.visible = true

	var rarity_color: Color = RARITY_COLORS.get(item["rarity"], Color.WHITE)
	detail_panel.get_node("ItemName").text    = item["name"]
	detail_panel.get_node("ItemDesc").text    = item["desc"]
	detail_panel.get_node("RarityLabel").text = item["rarity"].to_upper()
	detail_panel.get_node("RarityLabel").add_theme_color_override("font_color", rarity_color)
	detail_panel.get_node("TypeLabel").text   = "[" + item["type"].capitalize() + "]"

	var qty_owned: int = Global.ListaPowerUp.get(item["id"], 0)
	if detail_panel.has_node("OwnedLabel"):
		var owned_label: Label = detail_panel.get_node("OwnedLabel")
		if qty_owned > 0:
			owned_label.text = "Owned: " + str(qty_owned)
			owned_label.visible = true
		else:
			owned_label.visible = false

	_update_qty_ui()

func _on_qty_minus() -> void:
	if selected_item.is_empty():
		return
	selected_qty = max(1, selected_qty - 1)
	_update_qty_ui()

func _on_qty_plus() -> void:
	if selected_item.is_empty():
		return
	# Limite massimo di acquisto per singola transazione: quanto può permettersi
	# oppure 99, qualunque sia minore — evita overflow assurdi nell'input.
	var max_affordable: int = 99
	if selected_item["price"] > 0:
		max_affordable = min(99, Global.money / selected_item["price"])
	selected_qty = min(max(1, max_affordable), selected_qty + 1)
	_update_qty_ui()

func _update_qty_ui() -> void:
	if selected_item.is_empty():
		return
	var total_price: int = selected_item["price"] * selected_qty

	if detail_panel.has_node("QtyHBox/QtyLabel"):
		detail_panel.get_node("QtyHBox/QtyLabel").text = "x" + str(selected_qty)

	detail_panel.get_node("ItemPrice").text = str(total_price) + " G"

	buy_button.text     = "BUY"
	buy_button.disabled = Global.money < total_price

# ─── Purchase ────────────────────────────────────────────────────────────────
func _on_buy_pressed() -> void:
	if selected_item.is_empty():
		return
	var item_id: String = selected_item["id"]
	var total_price: int = selected_item["price"] * selected_qty

	if Global.money < total_price:
		_show_notification("Not enough gold!", Color("#ff4444"))
		return

	Global.money -= total_price
	Global.ListaPowerUp[item_id] = Global.ListaPowerUp.get(item_id, 0) + selected_qty
	_update_gold_label()
	_show_notification("Purchased: " + str(selected_qty) + "x " + selected_item["name"] + "!", Color("#44ff88"))
	_populate_grid(active_filter)
	_on_card_selected(selected_item)
func _show_notification(msg: String, col: Color) -> void:
	notif_label.text = msg
	notif_label.add_theme_color_override("font_color", col)
	var tween := create_tween()
	notification_anim.modulate.a = 0.0
	notification_anim.visible    = true
	tween.tween_property(notification_anim, "modulate:a", 1.0, 0.2)
	tween.tween_interval(1.4)
	tween.tween_property(notification_anim, "modulate:a", 0.0, 0.3)
	tween.tween_callback(_hide_notification)

func _hide_notification() -> void:
	notification_anim.visible = false
