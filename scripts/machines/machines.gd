extends RigidBody3D

var activated = false
var is_colliding = false
var id : String

func rotate_build():
	if Input.is_action_just_pressed("R"):
		rotation_degrees.y += 90.0

func write_basic_data(path):
	var data = {}
	
	data.id = str(get_instance_id())
	data.path = path
	data.position = global_position
	data.rotation = rotation
	id = data.id
	
	GLOBAL.game_data.buildings[str(get_instance_id())] = data

func load_data(_data):
	pass
