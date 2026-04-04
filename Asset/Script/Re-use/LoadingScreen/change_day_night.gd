extends Node2D

@onready var anim = $AnimationPlayer

func _ready():
	anim.play("NextDays")

func _finish():
	Global.load_exact_pos = false 
	Global.current_day += 1
	Global.day_night = false
	
	var next_scene = Global.pending_next_scene
	
	if next_scene != "":
		Global.pending_next_scene = "" 
		LoadingScreen.transition_to_screenfunc(next_scene)
