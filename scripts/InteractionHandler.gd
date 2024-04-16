extends Node
@onready var Player = $".."
@onready var MouseRayCast = $"../Pivote/Camera3D/MouseRayCast"
@onready var Occluder : OccluderInstance3D =  $"../OccluderInstance3D"
#BUILD VARS
@onready var BuildGrid : GridMap = get_tree().get_nodes_in_group("Build_Grid")[0]
var construction_name : String
var construction_type : String
@onready var construction : PackedScene 
var preview : StaticBody3D
var global_build_rotation = Vector3.ZERO
var can_build : bool
var build_position : Vector3 = Vector3.ZERO
var valid_material = load("res://materials/valid_build.tres")
var invalid_material = load("res://materials/invalid_build.tres")

func _physics_process(_delta):
	if Player.can_build:
		build_machines()

func build_machines():
	var interaction_ray = MouseRayCast.calc_3D_interactions(0b010)
	if interaction_ray:
		can_build = false
		build_position = interaction_ray.position
		update_preview(build_position)
		if preview.get_node("MeshInstance3D").material_overlay != invalid_material:
			preview.get_node("MeshInstance3D").material_overlay = invalid_material
		if construction_type == "floor":
			if interaction_ray.collider.is_in_group("floor") and interaction_ray.normal.y == 0:
				build_position = interaction_ray.collider.global_position + interaction_ray.normal
				can_build = true
		elif construction_type == "up_conveyor":
			build_position = interaction_ray.position + (interaction_ray.normal / Vector3(2, 2, 2))
		elif interaction_ray.normal.y == 1: #Check if the ray is looking A UPPER face
			build_position = interaction_ray.position
			build_position.y = 7
			can_build = true
		else:
			pass
	if can_build == true:
		build(false)

func build(snap_requiered):
	var grid_build_coords = BuildGrid.local_to_map(build_position)
	var global_build_coords = BuildGrid.map_to_local(grid_build_coords)
	update_preview(global_build_coords)
	if preview.is_colliding:
		return
	if preview.get_node("MeshInstance3D").material_overlay != valid_material:
		preview.get_node("MeshInstance3D").material_overlay = valid_material
	if Input.is_action_just_pressed("RotateRight"):
		global_build_rotation.y += deg_to_rad(90.0)
	if Input.is_action_just_pressed("RotateLeft"):
		global_build_rotation.y -= deg_to_rad(90.0)
	
	if not snap_requiered && Input.is_action_just_released("leftClick"):
		var placed_constrution = construction.instantiate()
		Player.add_sibling(placed_constrution)
		placed_constrution.global_position = global_build_coords
		placed_constrution.rotation = global_build_rotation
		placed_constrution.collision_layer = 0b11
		$"../Pivote/Camera3D".force_update_transform()
		placed_constrution.get_node("ColliderCheck").queue_free()
		return placed_constrution


func create_preview():
	preview = construction.instantiate()
	Player.add_sibling(preview)

func delete_preview():
	preview.queue_free()

func update_preview(global_build_coords):
	preview.global_position = global_build_coords
	preview.rotation = global_build_rotation

func _on_player_build_mode_on():
	construction = load("res://scenes/machines/"+ construction_name +".tscn")
	create_preview()
	Player.can_build = true

func _on_player_build_mode_off():
	if Player.can_build == true:
		delete_preview()
		Player.can_build = false
