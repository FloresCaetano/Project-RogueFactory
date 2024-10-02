extends CharacterBody3D
@onready var pivot : Node3D = $SBCPivot
@onready var Camera : Camera3D = $SBCPivot/Camera3D
@onready var Player : CharacterBody3D = get_tree().get_first_node_in_group("player")
var max_speed = 16
var acceleration = 0.04

#BUILD
@onready var BuildGrid : GridMap = get_tree().get_first_node_in_group("Build_Grid")
@onready var PlayerInteractionHandler = Player.get_child(3)
var Preview : RigidBody3D
@onready var construction_name : String
@onready var construction_type: String
var build_position : Vector3
var global_build_rotation : Vector3
var can_build : bool = false
var valid_material = load("res://materials/valid_build.tres")
var invalid_material = load("res://materials/invalid_build.tres")

func _ready():
	$SBCPivot/Camera3D.current = true

func _physics_process(_delta):
	move(get_input())
	construction_type = PlayerInteractionHandler.construction_type
	if(construction_type == "spaceship_part"):
		Preview = PlayerInteractionHandler.preview
		construction_name = PlayerInteractionHandler.construction_name
		build_spaceship()

#Mouse Handler
func _input(event: InputEvent) -> void:
	if event.is_action_released("Escape"):
		Player.activate()
		Player.on_SBC = false
		queue_free()
	if event is InputEventMouseMotion:
		if(Input.is_action_pressed("rightClick")):
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) #Repos
			pivot.rotate_y(deg_to_rad(-event.relative.x * GLOBAL.look_sensitivity))
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

func move(input : Vector3):
	var impulse = Vector3(
		pivot.transform.basis.x.x * input.x + pivot.transform.basis.z.x * input.z,
		0,
		pivot.transform.basis.x.z * input.x + pivot.transform.basis.z.z * input.z
		).normalized() * max_speed
	velocity.x = lerp(velocity.x, impulse.x, acceleration)
	velocity.z = lerp(velocity.z, impulse.z, acceleration)
	move_and_slide()

func get_input():
	var input = Vector3()
	if Input.is_action_pressed("W"):
		input.z += 1
	if Input.is_action_pressed("S"):
		input.z -= 1
	if Input.is_action_pressed("A"):
		input.x += 1
	if Input.is_action_pressed("D"):
		input.x -= 1
	return input

func build_spaceship():
	var interaction_ray = throwBuildRaycast(0b010)
	var build_behavior : Dictionary
	if interaction_ray:
		build_behavior = Preview.check_behavior(interaction_ray)
		if build_behavior.has("can_build"):
			build_position = build_behavior.build_position
			can_build = build_behavior.can_build
		set_material(invalid_material)
		var grid_build_coords = BuildGrid.local_to_map(build_position)
		build_position = BuildGrid.map_to_local(grid_build_coords)
		update_preview(build_position)
		if Preview.is_colliding:
			can_build = false
	if can_build == true:
		set_material(valid_material)
		if build_behavior.has("draggable") and Input.is_action_pressed("leftClick"):
			build(build_behavior)
		elif Input.is_action_just_released("leftClick"):
			build(build_behavior)

func build(build_behavior):
	var placed_constrution = Preview.duplicate()
	Player.add_sibling(placed_constrution)
	placed_constrution.global_transform.origin = build_position
	placed_constrution.rotation = global_build_rotation
	placed_constrution.collision_layer = 0b11
	Camera.force_update_transform()
	placed_constrution.get_node("ColliderCheck").queue_free()
	reset_material(placed_constrution)
	placed_constrution.write_basic_data("res://scenes/machines/"+ construction_name +".tscn")
	if build_behavior.has("callable"):
		var timer = Timer.new()
		timer.wait_time = 0.1  # Duración del temporizador en segundos
		timer.one_shot = true  # Configura el temporizador para que se ejecute solo una vez
		timer.connect("timeout", func _on_timer_timeout(): placed_constrution.callable(placed_constrution, Preview, self))
		add_child(timer)
		timer.start()
	return placed_constrution

func update_preview(global_build_coords):
	Preview.global_position = global_build_coords
	global_build_rotation = Preview.rotation

func throwBuildRaycast(mask):
	var build_distance = 50
	var mouse_pos = get_viewport().get_mouse_position()
	var origin = Camera.project_ray_origin(mouse_pos)
	var direction = Camera.project_ray_normal(mouse_pos)
	var end = origin + direction * build_distance
	var ray_params = PhysicsRayQueryParameters3D.create(origin, end)
	ray_params.collide_with_areas = true
	ray_params.collide_with_bodies = true
	ray_params.collision_mask = mask
	ray_params.hit_back_faces = true
	ray_params.hit_from_inside = true
	var ray = get_world_3d().direct_space_state.intersect_ray(ray_params)
	return ray
	
func set_material(material):
	var preview_nodes = Preview.get_children(true)
	for node in preview_nodes:
		if node is MeshInstance3D:
			if node.material_override != material:
				node.material_override = material
func reset_material(placed_build):
	var build_nodes = placed_build.get_children(true)
	for node in build_nodes:
		if node is MeshInstance3D:
			node.material_override = null
