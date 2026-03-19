extends Node2D

@onready var anim = $AnimationPlayer
@export var next_scene_path: String = ""

func _ready():
	anim.play("Bed")

func finish_cutscene():
	
	Global.event_flags["washed_face"] = true 
	Global.load_exact_pos = false 
	
	if next_scene_path != "":
		LoadingScreen.transition_to_screenfunc(next_scene_path)
