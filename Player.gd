extends CharacterBody3D
#DEBUG
@onready var DebugLabel = $Label
#
@onready var animator = $NAUT/AnimatorSmoothing
@onready var Pivote = $Pivote
@onready var Camera = $Pivote/Camera3D
@onready var MouseRayCast = $Pivote/Camera3D/MouseRayCast
@onready var BuildGrid : GridMap = get_tree().get_nodes_in_group("Build_Grid")[0]
var gravity = 15

#SIGNALS
signal build_mode_on
signal build_mode_off
#STATES
var can_build = false
var can_move = true
var moving_camera = false


func _ready():
	pass
func _physics_process(delta):
	
	#print(Engine.get_frames_per_second())
	if gravity == 0:
		space_move(delta, get_input())
	else:
		move(delta, get_input())

func move(delta, input):
	if Input.is_action_just_pressed("Intro"):
		emit_signal("build_mode_on")
	if Input.is_action_just_pressed("Escape"):
		emit_signal("build_mode_off")
	var max_speed = 6
	var acceleration = 0.04
	var desaceleration = 0.2
	var impulse = Vector3(
		Pivote.transform.basis.x.x * input.x + Pivote.transform.basis.z.x * input.z,
		0,
		Pivote.transform.basis.x.z * input.x + Pivote.transform.basis.z.z * input.z
		).normalized() * max_speed
	velocity.y -= gravity * delta
	if input.x != 0 or input.z != 0:
		velocity.x = lerp(velocity.x, impulse.x, acceleration)
		velocity.z = lerp(velocity.z, impulse.z, acceleration)
	else:
		velocity.x = lerp(velocity.x, 0.0, desaceleration)
		velocity.z = lerp(velocity.z, 0.0, desaceleration)
	if impulse != Vector3():
		$NAUT.rotation.y = lerp_angle(
			$NAUT.rotation.y, atan2(impulse.x, impulse.z), delta * 3)
	move_and_slide()
	DebugLabel.text = "Speed: " + str(velocity)
	DebugLabel.text += "\nImpulse: " + str(impulse)

func space_move(delta, input):
	var speed = 10
	var acceleration = 0.005
	var desaceleration = 0.05
	var vel = Vector3()
	var impulse = Pivote.transform.basis * -input.normalized() * speed
	impulse.y = input.normalized().y * speed
	if input != Vector3():
		vel = lerp(velocity, impulse, acceleration)
	else:
		vel = lerp(velocity, Vector3.ZERO, desaceleration)
	if impulse != Vector3():
		$NAUT.rotation.y = lerp_angle(
			$NAUT.rotation.y, atan2(-impulse.x, -impulse.z), delta * 3)
	set_velocity(vel)
	move_and_slide()
	set_anim()

func set_anim():
	var converted_velocity = -velocity * $NAUT.transform.basis
	animator.set_deferred(
		"parameters/BlendSpace2D/blend_position", 
		Vector2(converted_velocity.x, converted_velocity.z)
	)
	animator.set_deferred("parameters/BlendSpace1D/blend_position", converted_velocity.y)

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
	if Input.is_action_pressed("Space"):
		input.y += 1
	if Input.is_action_pressed("Shift"):
		input.y -= 1
	return input

