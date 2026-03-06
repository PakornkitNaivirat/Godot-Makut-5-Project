extends Area2D

@onready var anim = $AnimationPlayer
@onready var icon = $Sprite2D

@export_group("Settings")
@export var next_scene_path: String = ""
@export var minigame_id: String = ""

@export_group("Conditions")
# 🌟 1. เงื่อนไข "ก่อนเกิด": ต้องทำสิ่งนี้ก่อนถึงจะโผล่มา (เว้นว่าง = โผล่มาเลย)
@export var required_event_id: String = ""

# 🌟 2. เงื่อนไข "หลังเล่นจบ": พอเล่นมินิเกมเสร็จ จะให้ทำยังไงต่อ?
@export_enum("หายไปเมื่อผ่านแล้ว", "ยังอยู่แต่กดไม่ได้", "แสดงตัวเมื่อผ่านแล้วเท่านั้น") var behavior_after_done: int = 0

var can_interact = false
var current_player: Node2D = null 

func _ready():
	# เอาตัวเองเข้าไปอยู่ใน Group เพื่อให้ฉากอื่นสั่งอัปเดตข้าม Scene ได้
	add_to_group("interactable_items")
	
	if icon: icon.hide()
	
	# อัปเดตสถานะตัวเองทันทีที่โหลดฉาก
	update_state()

# 🌟 ยุบรวม 2 ฟังก์ชันมาไว้ที่นี่ที่เดียว!
func update_state():
	# --- STEP 1: เช็คเงื่อนไขก่อนเกิด (Pre-condition) ---
	if required_event_id != "" and Global.event_flags.has(required_event_id):
		if Global.event_flags[required_event_id] == false:
			# ยังไม่ผ่านเงื่อนไขบังคับ -> ซ่อนตัว ปิดการชน จบการทำงาน
			self.hide()
			monitoring = false
			return 

	# --- STEP 2: เช็คสถานะหลังเล่น (Post-condition) ---
	var is_done = false
	if minigame_id != "" and Global.minigame_status.has(minigame_id):
		is_done = Global.minigame_status[minigame_id]
	
	if is_done:
		# กรณี: มินิเกมนี้เล่นผ่านไปแล้ว
		if behavior_after_done == 0:     # หายไปเมื่อผ่านแล้ว
			self.queue_free()
		elif behavior_after_done == 1:   # ยังอยู่แต่กดไม่ได้
			self.show()
			monitoring = true
			set_process(false)           # ปิดการทำงาน _process ทิ้งไปเลย
		elif behavior_after_done == 2:   # แสดงตัวเมื่อผ่านแล้วเท่านั้น
			self.show()
			monitoring = false           # โชว์เฉยๆ แต่ไม่ต้องมีปุ่มให้กด
			set_process(false)
	else:
		# กรณี: มินิเกมนี้ "ยังไม่ได้เล่น"
		if behavior_after_done == 0 or behavior_after_done == 1:
			self.show()                  # สถานะปกติ โชว์ตัวและรอให้คนมากด
			monitoring = true
			set_process(true)
		elif behavior_after_done == 2:   # แสดงตัวเมื่อผ่านแล้วเท่านั้น
			self.hide()                  # ตอนนี้ยังไม่ผ่าน ต้องซ่อนไว้ก่อน
			monitoring = false

func _process(delta):
	if can_interact and Input.is_action_just_pressed("interact"):
		# เช็คกันเหนียว
		if Global.minigame_status.has(minigame_id) and Global.minigame_status[minigame_id] == true:
			return
			
		if current_player != null:
			Global.last_player_pos = current_player.global_position
			Global.load_exact_pos = true
			Global.target_spawn_name = "" 
		
		if next_scene_path != "":
			print("กำลังเข้ามินิเกมที่: ", next_scene_path)
			LoadingScreen.transition_to_screenfunc(next_scene_path)

func _on_body_entered(body):
	if body.name == "Player":
		if Global.minigame_status.has(minigame_id) and Global.minigame_status[minigame_id] == true:
			return
		
		can_interact = true
		current_player = body 
		if icon: icon.show()
		if anim: anim.play("interact")

func _on_body_exited(body):
	if body.name == "Player":
		can_interact = false
		current_player = null 
		if icon: icon.hide()
		if anim: anim.stop()
