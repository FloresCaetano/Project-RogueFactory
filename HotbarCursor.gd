extends Control
@onready var HUD = get_tree().get_first_node_in_group("Hud")
@onready var SlotsContainer = $"../.."
@onready var Slots = SlotsContainer.get_children()
@onready var ParentSlot = self.get_parent()
var actual_slot = 0

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

func get_slot_data():
	return ParentSlot.get_slot_data()
