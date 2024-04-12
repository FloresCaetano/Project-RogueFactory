@tool
extends Node
@onready var slot = load("res://scenes/UI/inv_ui_slot.tscn")

func set_inventory(inv_rect : NinePatchRect, grid : GridContainer, item_ammount):
	for i in range(item_ammount):
		grid.add_child(slot.intantiate())
