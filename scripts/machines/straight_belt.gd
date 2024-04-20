extends "res://scripts/machines/machines.gd"
@onready var straight_belt = [$MeshInstance3D]
@onready var curve_belt = [$MeshInstance3D2]
@onready var raycasts : Array[RayCast3D] = [
	$FrontRay, $BackRay]
var connected_belts : Array[RigidBody3D] = [null, null]
var active_conection : Dictionary = {"front" : false,
									"back" : false}
var side : String = "front"

func _physics_process(_delta):
	pass

func _ready():
	check_connections()
	for belt in connected_belts:
		if belt is RigidBody3D:
			belt.check_connections()

func check_connections():
	for i in range(raycasts.size()):
		#raycasts[i].enabled = true
		print(raycasts[i].get_collider())
		if raycasts[i].is_colliding() && raycasts[i].get_collider().is_in_group("conveyor"):
			connected_belts[i] = raycasts[i].get_collider()
			active_conection[i] = true
			#Checking if both conveyors aren't facing each other
			if raycasts[i].get_collider().raycasts[i].get_collider() == self:
				connected_belts[i] = null
		#raycasts[i].enabled = false

func check_behavior(interaction_ray : Dictionary) -> Dictionary:
	rotate_build()
	var build_position = interaction_ray.collider.global_position + (interaction_ray.normal)
	return {"can_build" : true,
			"build_position" : build_position,
			"callable" : func update_connections(conveyor): pass}

func rotate_build():
	if Input.is_action_just_pressed("R"):
		if side == "front":
			side = "up-right"
			raycasts[0].target_position = Vector3(1, 0, 0)
			turn_off(straight_belt)
			turn_on(curve_belt)
		elif side == "up-right":
			side = "right"
			raycasts[0].target_position = Vector3(0, 0, -1)
			rotation.y = deg_to_rad(-90)
			turn_on(straight_belt)
			turn_off(curve_belt)
		elif side == "right":
			side = "right-back"
			raycasts[0].target_position = Vector3(1, 0, 0)
			rotation.y = deg_to_rad(-90)
			turn_off(straight_belt)
			turn_on(curve_belt)
		elif side == "right-back":
			side = "back"
			raycasts[0].target_position = Vector3(0, 0, -1)
			rotation.y = deg_to_rad(180)
			turn_on(straight_belt)
			turn_off(curve_belt)
		elif side == "back":
			side = "back-left"
			raycasts[0].target_position = Vector3(1, 0, 0)
			rotation.y = deg_to_rad(-180)
			turn_off(straight_belt)
			turn_on(curve_belt)
		elif side == "back-left":
			side = "left"
			raycasts[0].target_position = Vector3(0, 0, -1)
			rotation.y = deg_to_rad(90)
			turn_on(straight_belt)
			turn_off(curve_belt)
		elif side == "left":
			side = "left-front"
			raycasts[0].target_position = Vector3(1, 0, 0)
			rotation.y = deg_to_rad(90)
			turn_off(straight_belt)
			turn_on(curve_belt)
		elif side == "left-front":
			side = "front"
			raycasts[0].target_position = Vector3(0, 0, -1)
			rotation.y = deg_to_rad(0)
			turn_on(straight_belt)
			turn_off(curve_belt)

func turn_off(belts):
	for belt in belts:
		belt.visible = false

func turn_on(belts):
	for belt in belts:
		belt.visible = true
	

