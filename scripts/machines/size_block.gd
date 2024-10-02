extends "res://scripts/machines/machines.gd"
func check_behavior(interaction_ray : Dictionary) -> Dictionary:
	rotate_build()
	if interaction_ray.collider.is_in_group("SBM_foor"):
		var build_position = Vector3(interaction_ray.position.x, 7, interaction_ray.position.z)
		return {"can_build" : true,
				"build_position" : build_position,
				"draggable" : true,
				"callable" : true}
	else:
		return {}

func rotate_build():
	if Input.is_action_just_pressed("R"):
		rotation_degrees.x += 90

func callable(_floor, _preview, handler): 
	handler.can_build = false

func mouse_interaction():
		if Input.is_action_just_pressed("ui_up"):
			GLOBAL.game_data["buildings"].erase(id)
			queue_free()
