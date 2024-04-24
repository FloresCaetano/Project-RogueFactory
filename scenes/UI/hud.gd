extends Control

@onready var inventories_on_screen : Array
@onready var Player = get_tree().get_first_node_in_group("player")
@onready var Hotbar = get_tree().get_first_node_in_group("Hotbar")
func _process(_delta):
	if Input.is_action_just_released("Escape") and inventories_on_screen != []:
		inventories_on_screen[-1].close()
	if Player.drag_target_data is Dictionary and Player.drag_target_data.has("item"):
		num_shortcuts()

#HOTKEY
func shift_click():
	if Input.is_action_pressed("Shift") and Input.is_action_just_pressed("leftClick") and Player.drag_target_data.item is Item:
		var container = Player.drag_target_data.container
		var item = container.items[Player.drag_target_data.item_index]
		var active_inventory
		if container == inventories_on_screen[-1]:
			active_inventory = Hotbar
		else:
			active_inventory = inventories_on_screen[-1]
		
		var free_slot = active_inventory.check_free_slot()
		if free_slot != null:
			active_inventory.set_item(free_slot, item)
			container.item_on_hand = false
			container.remove_item(Player.drag_target_data.item_index, 10000)

func num_shortcuts():
	var pressed_hotkey = get_inventory_hotkeys()
	if pressed_hotkey != null:
		var container = Player.drag_target_data.container
		container.swamp_items(Player.drag_target_data, Hotbar.Slots[pressed_hotkey].get_slot_data())

func get_inventory_hotkeys():
	var input_key
	if Input.is_action_just_pressed("1"):
		input_key = 0
	elif Input.is_action_just_pressed("2"):
		input_key = 1
	elif Input.is_action_just_pressed("3"):
		input_key = 2
	elif Input.is_action_just_pressed("4"):
		input_key = 3
	elif Input.is_action_just_pressed("5"):
		input_key = 4
	elif Input.is_action_just_pressed("6"):
		input_key = 5
	elif Input.is_action_just_pressed("7"):
		input_key = 6
	elif Input.is_action_just_pressed("8"):
		input_key = 7
	elif Input.is_action_just_pressed("9"):
		input_key = 8
	else:
		input_key = null
	return input_key

func check_inventory():
	if inventories_on_screen != []:
		Player.can_move_camera = false
		Player.can_move = false
	else:
		Player.can_move_camera = true
		Player.can_move = true


func _on_aereo_camera_toggled(toggled_on):
	var pivote = Player.get_node("Pivote")
	if toggled_on:
		var tween_callback : Callable = func(): pivote.max_look_angle = 75.0
		pivote.max_look_angle = 75.0
		pivote.tween_interpolate_camera(75.0, 0.5, tween_callback)
	else:
		var tween_callback : Callable = func(): pivote.max_look_angle = 50.0
		pivote.tween_interpolate_camera(50.0, 0.5, tween_callback)
