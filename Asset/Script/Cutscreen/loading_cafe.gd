extends Node2D

@export var next_scene_path: String = ""
@export var target_spawn_point_name: String = "" 

@onready var anim = $AnimationPlayer

func _ready():
	anim.play("cafe")

func finish_cutscene():
	# ปลดล็อกผู้เล่น
	var player = get_tree().get_first_node_in_group("player")
	
	Global.load_exact_pos = false 
	Global.target_spawn_name = target_spawn_point_name
	
	if next_scene_path != "":
		LoadingScreen.transition_to_screenfunc(next_scene_path)
