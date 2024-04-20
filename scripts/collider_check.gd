extends Area3D

@onready var build = get_parent()
var can_cancel = false


func _on_timer_timeout():
	can_cancel = true

func _on_body_entered(_body):
	build.is_colliding = true

func _on_body_exited(_body):
	build.is_colliding = false
