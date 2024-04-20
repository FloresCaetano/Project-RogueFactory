extends Node
@onready var Player = $".."
@onready var MouseRayCast = $"../Pivote/Camera3D/MouseRayCast"
@onready var Occluder : OccluderInstance3D =  $"../OccluderInstance3D"
#BUILD VARS
@onready var BuildGrid : GridMap = get_tree().get_nodes_in_group("Build_Grid")[0]
var construction_name : String
@onready var construction : PackedScene 
var preview : RigidBody3D
var global_build_rotation = Vector3.ZERO
var build_position : Vector3 = Vector3.ZERO
var can_build : bool
var valid_material = load("res://materials/valid_build.tres")
var invalid_material = load("res://materials/invalid_build.tres")

func _physics_process(_delta):
	if Player.can_build:
		build_machines()

func build_machines():
	var interaction_ray = MouseRayCast.calc_3D_interactions(0b010)
	var build_behavior : Dictionary
	if interaction_ray:
		build_behavior = preview.check_behavior(interaction_ray)
		if build_behavior.has("can_build"):
			build_position = build_behavior.build_position
			can_build = build_behavior.can_build
		set_material(invalid_material)
		var grid_build_coords = BuildGrid.local_to_map(build_position)
		build_position = BuildGrid.map_to_local(grid_build_coords)
		update_preview(build_position)
		if preview.is_colliding:
			can_build = false
	if can_build == true:
		build(build_behavior)

func build(build_behavior):
	set_material(valid_material)
	if Input.is_action_just_released("leftClick"):
		var placed_constrution = construction.instantiate()
		Player.add_sibling(placed_constrution)
		placed_constrution.global_transform.origin = build_position
		placed_constrution.rotation = global_build_rotation
		placed_constrution.collision_layer = 0b11
		$"../Pivote/Camera3D".force_update_transform()
		placed_constrution.get_node("ColliderCheck").queue_free()
		reset_material(placed_constrution)
		if build_behavior.has("callable"):
			build_behavior.callable.call(placed_constrution)
		return placed_constrution


func create_preview():
	preview = construction.instantiate()
	Player.add_sibling(preview)

func delete_preview():
	preview.queue_free()

func update_preview(global_build_coords):
	preview.global_position = global_build_coords
	global_build_rotation = preview.rotation

func _on_player_build_mode_on():
	construction = load("res://scenes/machines/"+ construction_name +".tscn")
	create_preview()
	Player.can_build = true

func _on_player_build_mode_off():
	if Player.can_build == true:
		delete_preview()
		Player.can_build = false

func set_material(material):
	var preview_nodes = preview.get_children(true)
	for node in preview_nodes:
		if node is MeshInstance3D:
			if node.material_overlay != material:
				node.material_overlay = material
func reset_material(placed_build):
	var build_nodes = placed_build.get_children(true)
	for node in build_nodes:
		if node is MeshInstance3D:
			node.material_overlay = null
