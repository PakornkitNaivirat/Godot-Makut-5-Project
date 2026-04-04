extends Node2D

@onready var anim = $AnimationPlayer
@export var next_scene_path: String = ""

func _ready():
	anim.play("Concert")

func finish_cutscene():
	
	Global.load_exact_pos = false 
	Global.day_night = true
	
	if next_scene_path != "":
		LoadingScreen.transition_to_screenfunc(next_scene_path)
