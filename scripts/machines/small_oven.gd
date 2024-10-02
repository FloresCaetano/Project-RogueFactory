extends "res://scripts/machines/machines.gd"
@onready var output_ray : RayCast3D = $Output
@onready var inventory : Control = $MachineInvetory/InventoryUI
@onready var Hud_invetories_container = get_tree().get_first_node_in_group("Hud").get_node("VSplitContainer2/VSplitContainer")
var connected_belt : RigidBody3D

func _physics_process(_delta):
	$Label3D.text = "time : " + str(inventory.items[1]) + "  belt : " + str(connected_belt)
	if $BurningTime.is_stopped() and activated:
		$BurningTime.start()

func _ready():
	inventory.close()
	activated = true

func check_connections():
	if output_ray.is_colliding():
		if output_ray.get_collider().is_in_group("conveyor"):
			connected_belt = output_ray.get_collider()

func burn():
		if inventory.items[0] is Item:
			var item : Item = inventory.items[0]
			inventory.set_item(1, item, 1)
			inventory.remove_item(0, 1)
		if inventory.items[1] is Item and connected_belt is RigidBody3D:
			if connected_belt.item_on_top == null and inventory.items[1].type == "material":
				var entity_item = load("res://scenes/" + inventory.items[1].tag + ".tscn").instantiate()
				connected_belt.get_node(connected_belt.conveyor_path).add_child(entity_item)
				connected_belt.item_on_top = entity_item
				inventory.remove_item(1, 1)

func _on_burning_time_timeout():
	check_connections()
	burn()

func check_behavior(interaction_ray : Dictionary) -> Dictionary:
	rotate_build()
	var build_position = interaction_ray.collider.global_position + (interaction_ray.normal)
	return {"can_build" : true,
			"build_position" : build_position,
			"callable" : true}

func rotate_build():
	if Input.is_action_just_pressed("R"):
		rotation_degrees.y += 90.0
		
func mouse_interaction():
	if get_tree().get_first_node_in_group("Hud").inventories_on_screen.size() < 2 and Input.is_action_just_pressed("E"):
		if inventory.is_open:
			get_tree().get_first_node_in_group("MainInventory").close()
			inventory.close()
		else:
			get_tree().get_first_node_in_group("MainInventory").open()
			inventory.open()

func callable(conveyor, _preview, _handler):
	conveyor.check_connections()
	if connected_belt is RigidBody3D: #Check if it has a valid build connected
		conveyor.connected_belt.call("check_connections")
