extends Node
#DEBUG
@onready var RayPosLabel = $"../RayPos"
@onready var RayNormalLabel = $"../RayNormal"
#
@onready var Player = $".."
@onready var MouseRayCast = $"../Pivote/Camera3D/MouseRayCast"
@onready var Occluder : OccluderInstance3D =  $"../OccluderInstance3D"
#BUILD VARS
@onready var BuildGrid : GridMap = get_tree().get_nodes_in_group("Build_Grid")[0]
var construction_name : String
var construction_type : String
@onready var construction : PackedScene 
var preview
var global_build_rotation = Vector3.ZERO

func _process(_delta):
	if Player.can_build:
		build_machines()

func build_machines():
	var interaction_ray = MouseRayCast.calc_3D_interactions(0b010)
	if interaction_ray:
		var build_position : Vector3 = interaction_ray.position
		update_preview(build_position)
		preview.get_node("MeshInstance3D").material_overlay = load("res://materials/invalid_build.tres")
		if construction_type == "floor":
			if interaction_ray.collider.is_in_group("floor") and interaction_ray.normal.y == 0:
				build_position = interaction_ray.collider.global_position + interaction_ray.normal
				var placed_construction = build(build_position, false)
		elif construction_type == "up_conveyor":
			build_position = interaction_ray.position + (interaction_ray.normal / Vector3(2, 2, 2))
		elif interaction_ray.normal.y == 1: #Check if the ray is looking A UPPER face
			build_position = interaction_ray.position
			build_position.y = 7
			build(build_position, false)
		else:
			pass
		

func build(build_position, snap_requiered):
	preview.get_node("MeshInstance3D").material_overlay = load("res://materials/valid_build.tres")
	var grid_build_coords = BuildGrid.local_to_map(build_position)
	var global_build_coords = BuildGrid.map_to_local(grid_build_coords)
	update_preview(global_build_coords)
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
		Occluder.bake_mask
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
