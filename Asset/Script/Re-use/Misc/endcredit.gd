extends Node2D

@onready var anim = $AnimationPlayer

@export var next_scene_path: String = ""

func _ready() -> void:
	if anim:
		anim.play("Endcredit")
		
func finish():
	
	if next_scene_path != "":
		print("กำลังเปลี่ยนฉากไปที่: ", next_scene_path)
		Global.load_exact_pos = false
		LoadingScreen.transition_to_screenfunc(next_scene_path)
	
