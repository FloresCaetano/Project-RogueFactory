extends Node3D
var look_sensitivity = 10
var min_look_angle = 50.0
var max_look_angle = 50.0

var mouse_delta = Vector2()

@onready var player = $".."
@onready var camera = $Camera3D

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.is_action_pressed("rightClick"):
			player.moving_camera = true
			mouse_delta = event.relative
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _process(delta: float) -> void:
	var rot = Vector3(mouse_delta.y, mouse_delta.x, 0) * look_sensitivity * delta
	rotation_degrees.x += rot.x
	rotation_degrees.x = clamp(rotation_degrees.x, min_look_angle, max_look_angle)
	rotation_degrees.y -= rot.y
	mouse_delta = Vector2()
	camera_zoom()

func camera_zoom():
	const zoom_transition = 0.3
	const zoom_speed = Vector3(0.3, 0.3, 0.3)
	if Input.is_action_just_pressed("mouse_wheel_down"):
		player.moving_camera = true
		var tween : Tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "scale", scale + zoom_speed, zoom_transition)
	if Input.is_action_just_pressed("mouse_wheel_up"):
		player.moving_camera = true
		var tween : Tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "scale", scale - zoom_speed, zoom_transition)
