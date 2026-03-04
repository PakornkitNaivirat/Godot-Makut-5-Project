extends Area2D

@onready var interact_icon = $interaction

@export var next_scene_path: String = ""
@export_enum("ไปมินิเกม (กลับมาที่เดิม)", "ข้ามแผนที่ (ระบุชื่อจุดเกิด)") var door_type: int = 0
@export var target_spawn_point_name: String = "" 

var can_interact = false
var current_player: Node2D = null 

func _process(delta):
	if can_interact and Input.is_action_just_pressed("interact"):
		
		if current_player != null:
			if door_type == 0:
				# --- กรณีที่ 1: ไปมินิเกม (จำตำแหน่งเดิมเป๊ะๆ) ---
				Global.last_player_pos = current_player.global_position
				Global.load_exact_pos = true
				Global.target_spawn_name = "" 
			elif door_type == 1:
				# --- กรณีที่ 2 & 3: ข้ามแผนที่ไป/กลับ (ส่งชื่อจุดเกิดไปให้ฉากหน้าหา) ---
				Global.load_exact_pos = false
				Global.target_spawn_name = target_spawn_point_name
		
		if next_scene_path != "":
			print("กำลังเปลี่ยนฉากไปที่: ", next_scene_path)
			LoadingScreen.transition_to_screenfunc(next_scene_path)

func _on_body_entered(body):
	if body.name == "Player":
		can_interact = true
		current_player = body 
		interact_icon.show_icon()

func _on_body_exited(body):
	if body.name == "Player":
		can_interact = false
		current_player = null 
		interact_icon.hide_icon()
