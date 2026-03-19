extends Node2D

@export var next_scene_path: String = "" # ช่องสำหรับใส่ Path ฉากหลักที่จะกลับไป
@export var target_spawn_point_name: String = "" 
@onready var anim = $AnimationPlayer

func _ready():
	anim.play("Cutscreen")

func finish_cutscene():
	
	Global.load_exact_pos = false
	Global.target_spawn_name = target_spawn_point_name
	Global.event_flags["wash_face"] = true
	get_tree().call_group("interactable_items", "update_state")
	
	if next_scene_path != "":
		LoadingScreen.transition_to_screenfunc(next_scene_path)
