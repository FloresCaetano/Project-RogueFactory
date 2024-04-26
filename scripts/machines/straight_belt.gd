extends "res://scripts/machines/machines.gd"
@onready var straight_belt = [$MeshInstance3D]
@onready var curve_belt = [$MeshInstance3D2]
@onready var raycasts : Array[RayCast3D] = [$FrontRay, $BackRay]
var connected_belts : Array[RigidBody3D] = [null, null]
var side : String = "back-front"
@onready var conveyor_path : NodePath = "StraightPath/PathFollow3D"
var item_on_top : RigidBody3D = null
var conveyor_speed = 0.01

func _physics_process(_delta):
	if item_on_top is RigidBody3D:
		move_item()

func check_connections():
	var accepted_connections = PackedStringArray(["front-back", "right-left", "back-front", "left-right"])
	if raycasts[0].is_colliding():
		if raycasts[0].get_collider().is_in_group("conveyor"):
			if accepted_connections.has(raycasts[0].get_collider().side.split("-")[0] + "-" + side.split("-")[1]):
				if raycasts[0].get_collider().raycasts[0].get_collider() != self:
					connected_belts[0] = raycasts[0].get_collider()
	else:
		connected_belts[0] = null
	if raycasts[1].is_colliding():
		if raycasts[1].get_collider().is_in_group("conveyor"):
			if accepted_connections.has(raycasts[1].get_collider().side.split("-")[1] + "-" + side.split("-")[0]):
				connected_belts[1] = raycasts[1].get_collider()
	else:
		connected_belts[1] = null
	$Label3D.text = str(connected_belts[0], connected_belts[1]) + " SIDE: " + str(side)

func check_behavior(interaction_ray : Dictionary) -> Dictionary:
	check_connections()
	rotate_build()
	var build_position = interaction_ray.collider.global_position + (interaction_ray.normal)
	if interaction_ray.collider.is_in_group("buildable"):
		return {"can_build" : true,
				"build_position" : build_position,
				"draggable" : true,
				"callable" : true}
	else:
		return {"can_build" : false,
				"build_position" : Vector3(0, 0, 0)}

func rotate_build():
	if Input.is_action_just_pressed("R"):
		var curve_0 = load("res://conveyor_paths/curve_belt_0_path.tres")
		var curve_180 = load("res://conveyor_paths/curve_belt_180_path.tres")
		if connected_belts[1] is RigidBody3D and side.split("-")[0] == "back":
			if side == "back-front":
				side = "back-right"
				conveyor_path = "CurvePath/PathFollow3D"
				raycasts[0].target_position = Vector3(1, 0, 0)
				raycasts[1].target_position = Vector3(0, 0, 1)
				$CurvePath.curve = curve_180
				turn_off(straight_belt)
				turn_on(curve_belt)
			elif side == "back-right":
				side = "back-left"
				conveyor_path = "CurvePath/PathFollow3D"
				raycasts[0].target_position = Vector3(0, 0, 1)
				raycasts[1].target_position = Vector3(1, 0, 0)
				$CurvePath.curve = curve_0
				rotation.y = deg_to_rad(-90)
				turn_off(straight_belt)
				turn_on(curve_belt)
			elif side == "back-left":
				side = "left-right"
				conveyor_path = "StraightPath/PathFollow3D"
				raycasts[0].target_position = Vector3(0, 0, -1)
				raycasts[1].target_position = Vector3(0, 0, 1)
				$CurvePath.curve = curve_0
				rotation.y = deg_to_rad(-90)
				turn_on(straight_belt)
				turn_off(curve_belt)
		elif connected_belts[1] is RigidBody3D and side.split("-")[0] == "right":
			if side == "right-left":
				side = "right-front"
				conveyor_path = "CurvePath/PathFollow3D"
				raycasts[0].target_position = Vector3(1, 0, 0)
				raycasts[1].target_position = Vector3(0, 0, 1)
				$CurvePath.curve = curve_180
				turn_off(straight_belt)
				turn_on(curve_belt)
			elif side == "right-front":
				side = "right-back"
				conveyor_path = "CurvePath/PathFollow3D"
				raycasts[0].target_position = Vector3(0, 0, 1)
				raycasts[1].target_position = Vector3(1, 0, 0)
				$CurvePath.curve = curve_180
				rotation.y = deg_to_rad(0)
				turn_off(straight_belt)
				turn_on(curve_belt)
			elif side == "right-back":
				side = "back-front"
				conveyor_path = "StraightPath/PathFollow3D"
				raycasts[0].target_position = Vector3(0, 0, -1)
				raycasts[1].target_position = Vector3(0, 0, 1)
				$CurvePath.curve = curve_0
				rotation.y = deg_to_rad(0)
				turn_on(straight_belt)
				turn_off(curve_belt)
		elif connected_belts[1] is RigidBody3D and side.split("-")[0] == "front":
			if side == "front-back":
				side = "front-left"
				conveyor_path = "CurvePath/PathFollow3D"
				raycasts[0].target_position = Vector3(1, 0, 0)
				raycasts[1].target_position = Vector3(0, 0, 1)
				$CurvePath.curve = curve_180
				turn_off(straight_belt)
				turn_on(curve_belt)
			elif side == "front-left":
				side = "front-right"
				conveyor_path = "CurvePath/PathFollow3D"
				raycasts[0].target_position = Vector3(0, 0, 1)
				raycasts[1].target_position = Vector3(1, 0, 0)
				$CurvePath.curve = curve_0
				rotation.y = deg_to_rad(90)
				turn_off(straight_belt)
				turn_on(curve_belt)
			elif side == "front-right":
				side = "right-left"
				conveyor_path = "StraightPath/PathFollow3D"
				raycasts[0].target_position = Vector3(0, 0, -1)
				raycasts[1].target_position = Vector3(0, 0, 1)
				$CurvePath.curve = curve_0
				rotation.y = deg_to_rad(90)
				turn_on(straight_belt)
				turn_off(curve_belt)
		elif connected_belts[1] is RigidBody3D and side.split("-")[0] == "left":
			if side == "left-right":
				side = "left-back"
				conveyor_path = "CurvePath/PathFollow3D"
				raycasts[0].target_position = Vector3(1, 0, 0)
				raycasts[1].target_position = Vector3(0, 0, 1)
				$CurvePath.curve = curve_180
				turn_off(straight_belt)
				turn_on(curve_belt)
			elif side == "left-back":
				side = "left-front"
				conveyor_path = "CurvePath/PathFollow3D"
				raycasts[0].target_position = Vector3(0, 0, 1)
				raycasts[1].target_position = Vector3(1, 0, 0)
				$CurvePath.curve = curve_0
				rotation.y = deg_to_rad(180)
				turn_off(straight_belt)
				turn_on(curve_belt)
			elif side == "left-front":
				side = "front-back"
				conveyor_path = "StraightPath/PathFollow3D"
				raycasts[0].target_position = Vector3(0, 0, -1)
				raycasts[1].target_position = Vector3(0, 0, 1)
				$CurvePath.curve = curve_0
				rotation.y = deg_to_rad(180)
				turn_on(straight_belt)
				turn_off(curve_belt)
		elif side == "back-front":
			side = "left-right"
			conveyor_path = "StraightPath/PathFollow3D"
			raycasts[0].target_position = Vector3(0, 0, -1)
			raycasts[1].target_position = Vector3(0, 0, 1)
			$CurvePath.curve = curve_0
			rotation.y = deg_to_rad(-90)
			turn_on(straight_belt)
			turn_off(curve_belt)
		elif side == "left-right":
			side = "front-back"
			conveyor_path = "StraightPath/PathFollow3D"
			raycasts[0].target_position = Vector3(0, 0, -1)
			raycasts[1].target_position = Vector3(0, 0, 1)
			$CurvePath.curve = curve_0
			rotation.y = deg_to_rad(180)
			turn_on(straight_belt)
			turn_off(curve_belt)
		elif side == "front-back":
			side = "right-left"
			conveyor_path = "StraightPath/PathFollow3D"
			raycasts[0].target_position = Vector3(0, 0, -1)
			raycasts[1].target_position = Vector3(0, 0, 1)
			$CurvePath.curve = curve_0
			rotation.y = deg_to_rad(90)
			turn_on(straight_belt)
			turn_off(curve_belt)
		elif side == "right-left":
			side = "back-front"
			conveyor_path = "StraightPath/PathFollow3D"
			raycasts[0].target_position = Vector3(0, 0, -1)
			raycasts[1].target_position = Vector3(0, 0, 1)
			$CurvePath.curve = curve_0
			rotation.y = deg_to_rad(0)
			turn_on(straight_belt)
			turn_off(curve_belt)
		else:
			side = "back-front"
			conveyor_path = "StraightPath/PathFollow3D"
			raycasts[0].target_position = Vector3(0, 0, -1)
			raycasts[1].target_position = Vector3(0, 0, 1)
			$CurvePath.curve = curve_0
			rotation.y = deg_to_rad(0)
			turn_on(straight_belt)
			turn_off(curve_belt)

func callable(conveyor, preview, handler): 
	conveyor.side = preview.side
	conveyor.conveyor_path = preview.conveyor_path
	conveyor.call("check_connections")
	for belt in conveyor.connected_belts:
		if belt is RigidBody3D:
			belt.call("check_connections")

func turn_off(belts):
	for belt in belts:
		belt.visible = false

func turn_on(belts):
	for belt in belts:
		belt.visible = true
	

func move_item():
	var path = get_node_or_null(conveyor_path)
	if path.progress_ratio <= 1-conveyor_speed:
		path.progress_ratio += conveyor_speed
	elif connected_belts[0] is RigidBody3D and connected_belts[0].item_on_top == null:
		connected_belts[0].item_on_top = item_on_top
		path.remove_child(item_on_top)
		connected_belts[0].get_node(connected_belts[0].conveyor_path).add_child(item_on_top)
		item_on_top = null
		path.progress_ratio = 0
	
