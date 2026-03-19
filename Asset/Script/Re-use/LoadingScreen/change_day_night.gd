extends Node2D

@export var next_scene_path: String = ""

@onready var anim = $AnimationPlayer

func _ready():
	anim.play("NextDays")

func _finish():
	Global.load_exact_pos = false 
	Global.current_day += 1
	Global.day_night = false
	
	if next_scene_path != "":
		LoadingScreen.transition_to_screenfunc(next_scene_path)
	
