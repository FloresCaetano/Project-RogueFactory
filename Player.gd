extends CharacterBody3D
#DEBUG
@onready var DebugLabel = $Label
#
var drag_data
var drag_target_data
@onready var Pivote = $Pivote
@onready var Camera = $Pivote/Camera3D
@onready var MouseRayCast = $Pivote/Camera3D/MouseRayCast
@onready var BuildGrid : GridMap = get_tree().get_nodes_in_group("Build_Grid")[0]
@onready var CoyoteTimer : Timer = $CoyoteTimer
@onready var Animator : AnimationPlayer = $NAUT/AnimationPlayer

#SIGNALS
signal build_mode_on
signal build_mode_off
#STATES
var can_build = false
var can_move = true
var can_jump = true
var is_jumping = false
var can_move_camera = true

#JUMP
var max_height = 0.7
var jump_strength : float = 2
var reference_jump_height : float
var gravity = 25 #25

func _ready():
	pass
func _physics_process(delta):
	DebugLabel.text = str(Engine.get_frames_per_second())
	if gravity == 0:
		space_move(delta, get_input())
	else:
		jump()
		move(delta, get_input())

func move(delta, input):
	if Input.is_action_just_pressed("Intro"):
		emit_signal("build_mode_on")
	if Input.is_action_just_pressed("Escape"):
		emit_signal("build_mode_off")
	var max_speed = 4
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
		Animator.play("Anim")
		$NAUT.rotation.y = lerp_angle(
			$NAUT.rotation.y, atan2(impulse.x, impulse.z), delta * 3)
	else:
		Animator.stop()
	move_and_slide()

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

func jump():
	if is_on_floor():
		is_jumping = false
		can_jump = true
	elif CoyoteTimer.is_stopped():
		CoyoteTimer.start()
	if can_jump && Input.is_action_just_pressed("Space"):
		reference_jump_height = global_position.y
		is_jumping = true
	if is_jumping && (global_position.y - reference_jump_height) <= max_height:
		if Input.is_action_pressed("Space"):
			velocity.y += jump_strength 
	elif is_jumping:
		velocity.y /= 1.5
		is_jumping = false
	

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

func debug():
	if Input.is_action_pressed("Tab"):
		gravity = 0
	else:
		gravity = 15

func _on_coyote_time_timeout():
	can_jump = false
