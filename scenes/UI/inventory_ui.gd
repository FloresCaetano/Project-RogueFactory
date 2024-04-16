extends Control
@export var can_hide = true
@export var hide_key = "Tab"
@export var items: Array[Item]
@onready var slot = load("res://scenes/UI/inv_ui_slot.tscn")
@onready var Slots : Array = $NinePatchRect/GridContainer.get_children()
@onready var HUD : Control = get_tree().get_first_node_in_group("Hud")
@onready var Player = get_tree().get_nodes_in_group("player")[0]
var ItemContainer : CenterContainer
var item_on_hand = false
var is_open = true

signal items_changed

func _ready():
	make_unique()
	update_slots()
	if can_hide:
		HUD.inventories_on_screen.append(self)
		close()

func check_free_slot():
	for i in range(items.size()):
		if not items[i] is Item:
			return i 
		else:
			return null

func update_slots():
	for i in range(items.size()):
		Slots[i].update(items[i])
		emit_signal("items_changed")


func _process(_delta):
	if item_on_hand && is_open:
		if Input.is_action_pressed("leftClick") or Input.is_action_just_released("leftClick"):
			ItemContainer.z_index = 100
			ItemContainer.global_position = get_viewport().get_mouse_position() - Vector2(16, 16)
			if Input.is_action_just_released("leftClick") && Player.drag_target_data.has("item") && Player.drag_target_data != Player.drag_data:
				swamp_items(Player.drag_data, Player.drag_target_data)
				item_on_hand = false
		else:
			item_on_hand = false
			update_slots()

	if Input.is_action_just_pressed(hide_key) && can_hide:
		if is_open:
			close()
		else:
			open()

func open():
	Player.desactivate()
	HUD.inventories_on_screen.append(self)
	visible = true
	is_open = true

func close():
	Player.activate()
	HUD.inventories_on_screen.erase(self)
	visible = false
	is_open = false

func set_item(item_index, item: Item):
	var previous_item : Item = items[item_index]
	if previous_item.name == item.name:
		item.ammount += previous_item.ammount
	else:
		items[item_index] = item.duplicate()
	update_slots()
	return previous_item

func swamp_items(item_data, target_item_data):
	var target_item : Item = target_item_data.container.items[target_item_data.item_index]
	var item : Item = items[item_data.item_index]
	if target_item is Item and item is Item and target_item.name == item.name:
		var overload = item.max_stack - (target_item.ammount + item.ammount)
		if overload > 0:
			target_item.ammount += item.ammount
			remove_item(item_data.item_index, 1000)
		else:
			target_item.ammount = item.max_stack
			item.ammount = abs(overload)
		target_item_data.container.update_slots()
	else:
		target_item_data.container.items[target_item_data.item_index] = item
		items[item_data.item_index] = target_item
		target_item_data.container.update_slots()
	update_slots()

func remove_item(item_index, ammount):
	var item : Item = items[item_index]
	if item != null && item.ammount > ammount:
		item.ammount -= 1
	elif item != null:
		items[item_index] = null
	update_slots()
	return item

func make_unique():
	var unique_items : Array[Item] = []
	for item in items:
		if item is Item:
			unique_items.append(item.duplicate())
		else:
			unique_items.append(null)
	items = unique_items


