extends Node3D
@onready var pivote : Node3D = $"../Pivote"
@onready var Player = $".."
@onready var Raycast : RayCast3D = $RayCast3D
var is_camera_moving : bool = false
var upper_angle = 68.0
var lower_angle = 50.0

func _physics_process(_delta):
	rotation.y = pivote.rotation.y
	$"../Label2".text = str(pivote.rotation_degrees.x)
	if Raycast.is_colliding():
		if  Raycast.get_collider().is_in_group("occludeable") and pivote.rotation_degrees.x != 75.0 :
			var rest = abs(Player.global_position - Raycast.get_collider().global_position)
			var distance = (rest * Raycast.get_collision_normal()).length()
			var new_angle = (distance - 2.2) * (upper_angle - lower_angle) / (1.18 - 2.2) + lower_angle
			new_angle = clamp(new_angle, lower_angle, upper_angle)
			pivote.interpolate_camera(new_angle, 0.06)
	elif pivote.rotation_degrees.x < pivote.min_look_angle or pivote.rotation_degrees.x > pivote.max_look_angle:
		pivote.interpolate_camera(lower_angle, 0.06)



