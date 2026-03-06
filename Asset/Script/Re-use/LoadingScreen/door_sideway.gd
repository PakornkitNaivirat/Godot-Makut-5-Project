extends Area2D

@onready var anim = $AnimationPlayer
@onready var icon = $Sprite2D

@export var next_scene_path: String = ""
@export var target_spawn_point_name: String = "" 

var can_interact = false
var current_player: Node2D = null 

func _process(delta):
	if can_interact and Input.is_action_just_pressed("interact"):
		
		if current_player != null:
			# --- ข้ามแผนที่ไป/กลับ (ส่งชื่อจุดเกิดไปให้ฉากหน้าหา) ---
			Global.load_exact_pos = false
			Global.target_spawn_name = target_spawn_point_name
		
		if next_scene_path != "":
			print("กำลังเปลี่ยนฉากไปที่: ", next_scene_path)
			LoadingScreen.transition_to_screenfunc(next_scene_path)

func _on_body_entered(body):
	if body.name == "Player":
		print("found")
		can_interact = true
		current_player = body 
		icon.show()
		anim.play("interact")

func _on_body_exited(body):
	if body.name == "Player":
		can_interact = false
		current_player = null 
		icon.hide()
