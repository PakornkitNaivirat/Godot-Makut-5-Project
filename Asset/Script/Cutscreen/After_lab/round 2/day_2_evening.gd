extends Node2D

@onready var anim = $AnimationPlayer

func walk_away():
	anim.play("walk")
