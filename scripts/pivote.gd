extends Node3D
var look_sensitivity = 10
var min_look_angle = 50.0
var max_look_angle = 75.0

var mouse_delta = Vector2()

@onready var DebugLabel = $"../Label"
@onready var player = $".."
@onready var camera = $Camera3D

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.is_action_pressed("rightClick"):
			mouse_delta = event.relative
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _process(delta: float) -> void:
	if player.can_move_camera:
		var rot = Vector3(mouse_delta.y, mouse_delta.x, 0) * look_sensitivity * delta
		rotation_degrees.x += rot.x
		rotation_degrees.x = clamp(rotation_degrees.x, min_look_angle, max_look_angle)
		rotation_degrees.y -= rot.y
		mouse_delta = Vector2()
		camera_zoom()

func camera_zoom():
	const zoom_transition = 0.3
	const zoom_speed = Vector3(0.4, 0.4, 0.4)
	const min_zoom = Vector3(1.4, 1.4, 1.4)
	const max_zoom = Vector3(3.3, 3.3, 3.3)
	if Input.is_action_just_pressed("mouse_wheel_down"):
		var tween : Tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "scale", 
						clamp(scale + zoom_speed, min_zoom, max_zoom), zoom_transition)
	if Input.is_action_just_pressed("mouse_wheel_up"):
		var tween : Tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "scale", 
						clamp(scale - zoom_speed, min_zoom, max_zoom), zoom_transition)
