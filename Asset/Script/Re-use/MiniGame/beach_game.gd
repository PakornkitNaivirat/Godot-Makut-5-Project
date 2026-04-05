extends Node2D

var score : int = 0
@export var target_score : int = 40 # 🌟 เป้าหมายคะแนน (สามารถไปปรับเลขได้ในหน้า Inspector)

# --- 🌟 ตัวแปรระบบจับเวลา ---
@export var time_limit: float = 60 # ตั้งเวลาให้ด่านนี้ (วินาที)
var time_left: float
var is_game_over: bool = false

# 🌟 เช็ค Path ของ Label ให้ตรงกับใน Scene 
@onready var count_label = $CanvasLayer/UI_Panel/HBoxContainer/CountLabel

# 🌟 เพิ่มตัวแปรสำหรับ UI จับเวลา (อย่าลืมไปสร้างโหนด Label ไว้ใน Scene Tree ด้วยนะครับ!)
@onready var timer_label = $CanvasLayer/TimerLabel

func _ready():
	if has_node("SandBackground"):
		$SandBackground.z_index = -1
		$SandBackground.set_process_input(false)
	
	# 🌟 เริ่มต้นเวลา
	time_left = time_limit
	update_ui()
	update_timer_ui()

# 🌟 อัปเดตเวลาทุกๆ เฟรม
func _process(delta):
	if not is_game_over:
		time_left -= delta
		update_timer_ui()
			
		if time_left <= 0:
			time_out()

func _on_trash_clicked():
	# 🌟 ถ้าเกมจบแล้ว ไม่ให้กดเก็บเพิ่ม
	if is_game_over: return 
	
	score += 1
	update_ui()
	
	# เอฟเฟกต์ตัวหนังสือเด้งตอนได้คะแนน (Pop Effect)
	if count_label:
		count_label.scale = Vector2(1, 1) 
		var tween = get_tree().create_tween()
		count_label.scale = Vector2(1.5, 1.5) 
		tween.tween_property(count_label, "scale", Vector2(1, 1), 0.2).set_trans(Tween.TRANS_BOUNCE)
	
	# เช็กว่าคะแนนถึงเป้าหมายหรือยัง
	if score >= target_score:
		win_game()

func _on_trash_stolen():
	# 🌟 ถ้าเกมจบแล้ว ไม่ให้ปูมาหักคะแนน
	if is_game_over: return 
	
	# ถ้าโดนขโมย หักคะแนน 1 แต้ม (ไม่ให้คะแนนติดลบ)
	score -= 1
	if score < 0:
		score = 0
	update_ui()
	
	# เอฟเฟกต์ตัวหนังสือกระพริบสีแดงตอนโดนขโมย
	if count_label:
		var tween = get_tree().create_tween()
		count_label.modulate = Color.RED
		tween.tween_property(count_label, "modulate", Color.WHITE, 0.3)

func update_ui():
	if count_label:
		count_label.text = "Trash Collected: " + str(score) + " / " + str(target_score)

# 🌟 ฟังก์ชันอัปเดต UI เวลาบนหน้าจอ
func update_timer_ui():
	if timer_label:
		# ใช้ max(0.0, time_left) เพื่อไม่ให้เลขติดลบ และโชว์ทศนิยม 2 ตำแหน่ง
		timer_label.text = "Time: %.2f" % max(0.0, time_left)

# 🌟 ฟังก์ชันเมื่อชนะเกม 
func win_game():
	is_game_over = true
	print("เก็บขยะครบเป้าหมายแล้ว! รอแป๊บนึงก่อนไปแยกขยะ...")
	
	if count_label:
		count_label.modulate = Color.GREEN # เปลี่ยนเป็นสีเขียวตอนชนะ
		
	# หยุดคลื่นขยะ
	if has_node("WaveSpawner"):
		$WaveSpawner.queue_free()
		
	# 🌟 ให้ InnerVoice ชมผู้เล่นตอนชนะ
	if InnerVoice:
		InnerVoice.speak("Great job! The beach is clean now.")
	
	await get_tree().create_timer(2.0).timeout 
	
	# ซ่อนข้อความก่อนเปลี่ยนด่าน
	if InnerVoice:
		InnerVoice.hide_text()
		
	LoadingScreen.transition_to_screenfunc("res://Asset/Screen/BG/Minigames/sorting_game.tscn")

# 🌟 ฟังก์ชันเมื่อหมดเวลา (แก้ไขเพื่อเรียกใช้ InnerVoice)
func time_out():
	is_game_over = true
	time_left = 0.0
	update_timer_ui()
	print("หมดเวลา! เริ่มใหม่นะ")
	
	# เปลี่ยนสีเวลาเป็นสีแดงให้รู้ว่าหมดเวลา
	if timer_label:
		timer_label.modulate = Color.RED
		
	# หยุดคลื่นขยะและปูทั้งหมด
	if has_node("WaveSpawner"):
		$WaveSpawner.queue_free()
		
	# 🌟 เรียกฟังก์ชันจบเกมพร้อมข้อความ InnerVoice
	trigger_game_over("I ran out of time... The beach is still dirty! Let's try again.")

# 🌟 ฟังก์ชันใหม่: แสดงข้อความ InnerVoice ถ่วงเวลา แล้วรีเซ็ตด่าน
func trigger_game_over(reason_text: String):
	# แสดงข้อความบ่น
	if InnerVoice:
		InnerVoice.speak(reason_text)
		
	# รอให้ผู้เล่นอ่านข้อความ 3.5 วินาที
	await get_tree().create_timer(3.5).timeout 
	
	# ปิดกล่องข้อความ
	if InnerVoice:
		InnerVoice.hide_text()
		
	# โหลดด่านใหม่
	get_tree().reload_current_scene()
