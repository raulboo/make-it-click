extends KinematicBody2D

onready var animated_sprite = $AnimatedSprite
onready var piece_holder = $PieceHolder
onready var r_collider = $RightCollider
onready var l_collider = $LeftCollider

export(float) var acceleration_speed = 0.25
export(float) var de_acceleration = 0.5
export(float) var max_walking_speed = 300
export(float) var max_running_speed = 450
export(float) var jump_force = 900
export(float) var gravity_force = 4000

var velocity = Vector2.ZERO
var current_max_speed = max_walking_speed

var facing_direction = 1
var gravity_direction = 0

var moving_input = 0
var jump_input = false

func _physics_process(delta):
	get_input()
	move(delta)
	calculate_animations()
	calculate_directions()

func get_input():
	moving_input = 0
	if Input.is_action_pressed("move_right"):
		moving_input = 1
	if Input.is_action_pressed("move_left"):
		moving_input = -1

	jump_input = false
	if Input.is_action_just_pressed("jump"):
		jump_input = true

#physics calculations
func move(delta):
	if  moving_input != 0:
		velocity.x = lerp(velocity.x, moving_input * current_max_speed, acceleration_speed)
	elif moving_input == 0 and is_on_floor():
		velocity.x = lerp(velocity.x, 0, de_acceleration)

	velocity.y += gravity_force * delta

	if jump_input and is_on_floor():
		velocity.y = -jump_force * gravity_direction

	if(abs(velocity.x) < 1):
		velocity.x = 0
	
	velocity = move_and_slide(velocity, Vector2(0, -gravity_direction))

#plays the proper animations
func calculate_animations():
	if velocity.x != 0:
		if facing_direction != -sign(velocity.x):
			flip_to(facing_direction)
		
		animated_sprite.play("walking")
	elif !is_on_floor():
		animated_sprite.play("jump")
	else:
		animated_sprite.play("idle")

#calculate facing direction and gravity direction
func calculate_directions():
	gravity_direction = sign(gravity_force)

	if velocity.x != 0:
		facing_direction = sign(velocity.x)

#flips player to direction
func flip_to(direction):
	animated_sprite.flip_h = (direction < 0)
	piece_holder.scale.x = direction
	r_collider.position.x = abs(r_collider.position.x) * direction
	l_collider.position.x = abs(l_collider.position.x) * -direction