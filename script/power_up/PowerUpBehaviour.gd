extends Node

onready var player_movement = $"../"
onready var power_up_attacher = $"../PowerUpAttacher"
onready var sound_player = $"../SoundPlayer"

const RAINBOW_PIECE_TIMEOUT = 3

export(float) var rope_momentum = 1500
var can_die = true

func on_piece_attached(piece):
	sound_player.play_sfx("click")

	if piece.type == GlobalScript.PieceType.RAINBOW:
		piece.destroy_in(RAINBOW_PIECE_TIMEOUT)
		can_die = false
	
func on_piece_de_attached(piece, slot):
	sound_player.play_sfx("click")

	if piece.type == GlobalScript.PieceType.GRAVITY:
		reset_gravity()

	if piece.type == GlobalScript.PieceType.RAINBOW:
		can_die = true

	if slot == 2 and power_up_attacher.find_piece(GlobalScript.PieceType.LEGS):
		var legs = power_up_attacher.get_piece(GlobalScript.PieceType.LEGS)
		power_up_attacher.switch_slots(legs.attached_slot, 2)

func _input(event):
	#gravity
	if event.is_action_pressed("invert_gravity") and power_up_attacher.find_piece(GlobalScript.PieceType.GRAVITY):
		if player_movement.current_gravity_force < 0:
			power_up_attacher.de_attach_piece_enum(GlobalScript.PieceType.GRAVITY)
		else:
			invert_gravity()
			
	#rope
	if event.is_action_pressed("trigger_slingshot") and power_up_attacher.find_piece(GlobalScript.PieceType.SLINGSHOT):
		use_slingshot()
		
func invert_gravity():
	sound_player.play_sfx("gravity")
	player_movement.current_gravity_force *= -1

func reset_gravity():
	if player_movement.current_gravity_force < 0:
		player_movement.current_gravity_force *= -1

func use_slingshot():
	sound_player.play_sfx("slingshot")

	var degrees = 1.22 #(around 70 degrees)
	player_movement.velocity = Vector2(cos(degrees) * player_movement.facing_direction, \
										sin(-degrees) * player_movement.gravity_direction) * rope_momentum

	power_up_attacher.de_attach_piece_enum(GlobalScript.PieceType.SLINGSHOT)
