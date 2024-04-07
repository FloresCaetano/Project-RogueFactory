extends Node
@onready var Player = $".."
@onready var MouseRayCast = $"../Pivote/Camera3D/MouseRayCast"

#BUILD VARS
@onready var BuildGrid : GridMap = get_tree().get_nodes_in_group("Build_Grid")[0]
var construction_name = "medium"
var construction_type = "machine"
@onready var construction = load("res://scenes/machines/"+ construction_name +".tscn")
var preview
var global_build_rotation = Vector3.ZERO

func _process(delta):
	if Player.can_build:
		build_machines(false)

func build_machines(snap_requiered : bool):
	var interaction_ray = MouseRayCast.calc_3D_interactions(0b000)
	if interaction_ray:
		var grid_build_coords = BuildGrid.local_to_map(interaction_ray.position)
		var global_build_coords = BuildGrid.map_to_local(grid_build_coords)
		if Input.is_action_just_pressed("RotateRight"):
			global_build_rotation.y += deg_to_rad(90.0)
		if Input.is_action_just_pressed("RotateLeft"):
			global_build_rotation.y -= deg_to_rad(90.0)
		update_preview(global_build_coords, global_build_rotation)
		
		if not snap_requiered && Input.is_action_just_released("leftClick"):
			var placed_constrution = construction.instantiate()
			Player.add_sibling(placed_constrution)
			placed_constrution.global_position = global_build_coords
			placed_constrution.rotation = global_build_rotation

func create_preview():
	preview = construction.instantiate()
	add_sibling(preview)
func delete_preview():
	preview.queue_free()
func update_preview(global_build_coords, global_build_rotation):
	preview.global_position = global_build_coords
	preview.rotation = global_build_rotation

func _on_player_build_mode_on():
	if not Player.can_build:
		create_preview()
		Player.can_build = true

func _on_player_build_mode_off():
	if Player.can_build:
		delete_preview()
		Player.can_build = false
