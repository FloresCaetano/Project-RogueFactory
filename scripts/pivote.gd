extends Node3D
var look_sensitivity = 10

var mouse_delta = Vector2()
var min_look_angle : float = 50.0
var max_look_angle : float = 50.0
@onready var player = $".."
@onready var camera = $Camera3D

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.is_action_pressed("rightClick"):
			mouse_delta = event.relative
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _process(delta) -> void:
	if player.can_move_camera:
		var rot = Vector3(mouse_delta.y, mouse_delta.x, 0) * look_sensitivity 
		rotation_degrees.y -= rot.y * delta
		mouse_delta = Vector2()
		#camera_zoom()

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

func interpolate_camera(new_angle, weight):
	rotation_degrees.x = lerpf(rotation_degrees.x, new_angle, weight)

func tween_interpolate_camera(new_angle, time, tween_callback : Callable):
	var tween : Tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rotation_degrees", 
		Vector3(new_angle, rotation_degrees.y, rotation_degrees.z ), time)
	tween.tween_callback(tween_callback)
