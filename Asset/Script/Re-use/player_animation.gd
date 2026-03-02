extends Node2D

@export var player_movement : PlayerController
@export var animation_player : AnimationPlayer
@export var sprite : Sprite2D

func _process(delta: float) -> void:
	#Check is player is locked?
	if player_movement.is_locked :
		return
	
	#Flipping sprite
	if player_movement.direction == 1:
		sprite.flip_h = false
	elif player_movement.direction == -1:
		sprite.flip_h = true	
	
	#Animation
	if abs(player_movement.velocity.x) != 0:
		animation_player.play("move")
	else:
		animation_player.play("idle")
