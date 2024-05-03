extends "res://scripts/machines/machines.gd"

func check_behavior(interaction_ray : Dictionary) -> Dictionary:
	rotate_build()
	if interaction_ray.normal.y == 0 and interaction_ray.collider.is_in_group("wall"):
		var build_position = interaction_ray.collider.global_position + (interaction_ray.normal)
		build_position.y = 10
		print(interaction_ray.normal)
		return {"can_build" : true,
				"build_position" : build_position}
	else:
		return {}
