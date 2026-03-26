extends Node2D

@onready var anim = $AnimationPlayer
@export var next_scene_path: String = ""

func _ready():
	anim.play("Ring")

func finish_cutscene():
	
	Global.play_cutscene_after_lab = false
	Global.play_cutscene_after_lab2 = true
	Global.load_exact_pos = false    
	
	if next_scene_path != "":
		LoadingScreen.transition_to_screenfunc(next_scene_path)
