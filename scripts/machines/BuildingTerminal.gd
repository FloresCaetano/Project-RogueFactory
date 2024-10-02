extends "res://scripts/machines/machines.gd"
@onready var Player = get_tree().get_first_node_in_group("player")

func check_behavior(interaction_ray : Dictionary) -> Dictionary:
	rotate_build()
	var build_position = interaction_ray.collider.global_position + (interaction_ray.normal)
	if interaction_ray.collider.is_in_group("buildable"):
		return {"can_build" : true,
				"build_position" : build_position,
				"draggable" : true}
	else:
		return {"can_build" : false,
				"build_position" : Vector3(0, 0, 0)}

func mouse_interaction():
	if Input.is_action_just_pressed("E"):
		Player.desactivate()
		Player.on_SBC = true
		var spaceshipBuildingCamera : PackedScene = load("res://scenes/spaceship_building_camera.tscn")
		var SpaceshipBuildingCamera = spaceshipBuildingCamera.instantiate()
		add_sibling(SpaceshipBuildingCamera)
		SpaceshipBuildingCamera.global_position = global_position
		SpaceshipBuildingCamera.global_rotation = global_rotation
