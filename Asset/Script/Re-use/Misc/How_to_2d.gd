extends Node2D

@onready var anim = $AnimationPlayer

func _ready() -> void:
	if anim:
		anim.play("How to")
