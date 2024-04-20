extends Control
@onready var HUD = get_tree().get_first_node_in_group("Hud")
@onready var SlotsContainer = $"../.."
@onready var Slots = SlotsContainer.get_children()
@onready var ParentSlot = self.get_parent()
@onready var Player = get_tree().get_first_node_in_group("player")
@onready var InteractionHandler = Player.get_node("InteractionHandler")
@onready var Hotbar = get_tree().get_first_node_in_group("Hotbar")
var actual_slot = 0

func _ready():
	Hotbar.items_changed.connect(_on_items_changed)

func _input(event):
	var hotkey = HUD.get_inventory_hotkeys()
	ParentSlot = self.get_parent()
	if hotkey != null:
		change_parent(Slots[hotkey])
		actual_slot = hotkey
	if event.is_action_released("mouse_wheel_down") && actual_slot < 8:
		actual_slot += 1
		change_parent(Slots[actual_slot])
	if event.is_action_released("mouse_wheel_up") && actual_slot > 0:
		actual_slot -= 1
		change_parent(Slots[actual_slot])

func change_parent(new_parent : Node):
	ParentSlot.remove_child(self)
	new_parent.add_child(self)
	send_slot_data(new_parent)
	ParentSlot = new_parent

func get_slot_data():
	return ParentSlot.get_slot_data()

func send_slot_data(slot):
	var slot_data = slot.get_slot_data()
	var item : Item = slot_data.item
	if item is Item and (item.type == "build"):
		if Player.can_build == true:
			Player.emit_signal("build_mode_off")
		InteractionHandler.construction_name = item.tag
		Player.emit_signal("build_mode_on")
	else:
		Player.emit_signal("build_mode_off")
	
func _on_items_changed():
	send_slot_data(ParentSlot)
