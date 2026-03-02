extends Sprite2D

@onready var anim = $AnimationPlayer

func _ready():
	hide()

func show_icon():
	show()
	anim.play("shake") 

func hide_icon():
	hide()
