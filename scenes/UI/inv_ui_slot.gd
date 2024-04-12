extends Panel

@onready var ItemSprite : Sprite2D = $CenterContainer/Panel/ItemSprite
@onready var ItemAmmount : Label = $CenterContainer/Panel/ItemAmmount
@onready var InventoryUI = $"../../.."
@onready var ItemContainer : CenterContainer = $CenterContainer
@onready var Player = get_tree().get_nodes_in_group("player")[0]

var slot_data
var take_item : bool


func update(item : Item):
	if not item:
		ItemSprite.visible = false
		ItemAmmount.visible = false
	else:
		ItemSprite.visible = true
		ItemSprite.texture = item.texture
		ItemAmmount.visible = true
		ItemAmmount.text = str(item.ammount)
	ItemContainer.position = Vector2(0, 0)
	ItemContainer.z_index = 0
func get_slot_data():
	var item_index = get_index()
	var item = InventoryUI.items[item_index]
	var data = {}
	if item is Item:
		data.item = item
		data.item_index = item_index
		data.container = InventoryUI
	else:
		data.item = null
		data.item_index = item_index
		data.container = InventoryUI
	return data


func _on_mouse_exited():
	Player.drag_target_data = {}


func _on_gui_input(event : InputEvent):
	if not InventoryUI.item_on_hand && not Input.is_action_pressed("Shift"):
		slot_data = get_slot_data()
		if event.is_action_pressed("leftClick") && slot_data.item is Item:
			Player.drag_data = slot_data
			InventoryUI.ItemContainer = ItemContainer
			InventoryUI.item_on_hand = true
			Player.drag_target_data = {}
			take_item = false

func _on_mouse_entered():
	slot_data = get_slot_data()
	Player.drag_target_data = slot_data
