extends Area3D

@onready var build = get_parent()
var can_cancel = false

func _process(_delta):
	if has_overlapping_bodies():
		build.is_colliding = true
	elif can_cancel:
		build.is_colliding = false


func _on_timer_timeout():
	can_cancel = true



