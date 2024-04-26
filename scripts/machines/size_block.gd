extends "res://scripts/machines/machines.gd"
func check_behavior(interaction_ray : Dictionary) -> Dictionary:
	rotate_build()
	if interaction_ray.normal.y == 0:
		var build_position = interaction_ray.collider.global_position + (interaction_ray.normal)
		return {"can_build" : true,
				"build_position" : build_position,
				"draggable" : true,
				"callable" : true}
	else:
		return {}

func rotate_build():
	if Input.is_action_just_pressed("R"):
		rotation_degrees.y += 90

func callable(floor, preview, handler): 
	handler.can_build = false

func mouse_interaction():
		if Input.is_action_just_pressed("ui_up"):
			GLOBAL.game_data["buildings"].erase(id)
			queue_free()
