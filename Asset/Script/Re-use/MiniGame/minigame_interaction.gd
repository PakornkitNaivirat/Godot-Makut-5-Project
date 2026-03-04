extends Area2D

@onready var interact_icon = $interaction

@export var next_scene_path: String = ""
@export var minigame_id: String = ""

var can_interact = false
var current_player: Node2D = null 

func _process(delta):
	if can_interact and Input.is_action_just_pressed("interact"):
		
		# เช็คกันเหนียวอีกรอบ เผื่อผู้เล่นกดรัวๆ
		if Global.minigame_status.has(minigame_id) and Global.minigame_status[minigame_id] == true:
			return
			
		if current_player != null:
			# --- ไปมินิเกม (จำตำแหน่งเดิมเป๊ะๆ) ---
			Global.last_player_pos = current_player.global_position
			Global.load_exact_pos = true
			Global.target_spawn_name = "" 
		
		if next_scene_path != "":
			print("กำลังเข้ามินิเกมที่: ", next_scene_path)
			LoadingScreen.transition_to_screenfunc(next_scene_path)

func _on_body_entered(body):
	if body.name == "Player":
		# 🌟 ถ้าเล่นผ่านแล้ว ไม่ต้องขึ้นปุ่มกด และไม่ให้เข้า
		if Global.minigame_status.has(minigame_id) and Global.minigame_status[minigame_id] == true:
			return
		
		print("Found")
		can_interact = true
		current_player = body 
		interact_icon.show_icon()

func _on_body_exited(body):
	if body.name == "Player":
		can_interact = false
		current_player = null 
		
		if interact_icon != null:
			interact_icon.hide_icon()
