extends Node2D

export(GlobalScript.PieceType) var type

onready var player_piece_controller = get_node("/root/Level/Player/PowerUpAttacher")

var enabled = false
var prefer_slot = 1
var spawn_position
var attached_slot = -1

func _ready():
	$Sprite.play(GlobalScript.PieceType.keys()[type])
	spawn_position = self.global_position
	hardcode_positions()

#preferable positions for the power-up
func hardcode_positions():
	match type:
		GlobalScript.PieceType.SLINGSHOT:
			prefer_slot = 1 #up
		GlobalScript.PieceType.LEGS:
			prefer_slot = 2 #front
		GlobalScript.PieceType.GRAVITY:
			prefer_slot = 1 #up

func reset(active):
	self.enabled = active
	change_parent($"/root/Level")
	attached_slot = -1
	move_to_spawn()
	
	self.visible = false
	if active:
		self.visible = true
	
#orientates the sprite accordingly
func set_piece_position(position, slot_index):
	$Sprite.rotation_degrees = -90 + (slot_index * 90) 
	self.position = position

#change global position of this piece, useful later for animation
func move_to (pos):
	self.global_position = pos

#return piece to spawn, useful later for animation
func move_to_spawn ():
	self.global_position = spawn_position
	
func set_attached(index):
	attached_slot = index

#change this piece parent
func change_parent(parent_node):
	self.get_parent().remove_child(self)
	parent_node.add_child(self)

func on_body_entered(body):
	if body.is_in_group("player") && attached_slot == -1:
		player_piece_controller.call_deferred("attach_piece", self)
