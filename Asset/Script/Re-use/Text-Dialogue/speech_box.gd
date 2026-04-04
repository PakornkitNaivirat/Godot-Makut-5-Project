extends Node2D

# ดึงโหนดเสียงมาใช้งาน (ต้องมีโหนดชื่อ KeyboardSound ใน Scene)
@onready var keyboard_sound = $KeyboardSound
@onready var panel = $PanelContainer
@onready var label = $PanelContainer/MarginContainer/Label

@export var typing_speed: float = 0.05 

var current_tween: Tween # ตัวแปรเก็บแอนิเมชัน

func _ready():
	scale = Vector2.ZERO 

func show_dialogue(text_to_show: String):
	# ถ้ามีแอนิเมชันเก่ารันอยู่ให้หยุดก่อน
	if current_tween and current_tween.is_valid():
		current_tween.kill()
		
	label.text = text_to_show
	panel.reset_size() 
	panel.position = Vector2(-panel.size.x / 2, -panel.size.y)
	panel.pivot_offset = Vector2(panel.size.x / 2, panel.size.y)
	label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	
	scale = Vector2.ZERO
	label.visible_ratio = 0.0 
	show()
	
	# สร้าง Tween ใหม่
	current_tween = create_tween()
	
	# 1. ให้กล่องขยายตัว (Scale) พร้อมกับเริ่มพิมพ์ (ใช้ set_parallel)
	current_tween.set_parallel(true)
	current_tween.tween_property(self, "scale", Vector2.ONE, 0.3)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	# 2. ส่วนการพิมพ์ข้อความทีละตัวอักษร
	current_tween.set_parallel(false) # กลับมาทำทีละขั้นตอนเพื่อคุมจังหวะเสียง
	
	# ลูปตามจำนวนตัวอักษรเพื่อเล่นเสียง
	for i in range(text_to_show.length() + 1):
		var target_ratio = float(i) / text_to_show.length()
		
		# เลื่อนค่า visible_ratio ทีละนิด
		current_tween.tween_property(label, "visible_ratio", target_ratio, typing_speed)
		
		# ถ้าตัวอักษรไม่ใช่ช่องว่าง ให้เล่นเสียงคีย์บอร์ด
		if i < text_to_show.length() and text_to_show[i] != " ":
			current_tween.tween_callback(play_keyboard_sound)

# ฟังก์ชันสำหรับเล่นเสียงคีย์บอร์ด
func play_keyboard_sound():
	if keyboard_sound:
		# สุ่ม Pitch เล็กน้อยเพื่อให้เสียงไม่ซ้ำซาก (ดูธรรมชาติขึ้น)
		keyboard_sound.pitch_scale = randf_range(0.9, 1.2)
		keyboard_sound.play()

# เช็คว่ายังพิมพ์ไม่เสร็จใช่ไหม
func is_typing() -> bool:
	return label.visible_ratio < 1.0

# สั่งให้ข้อความเต็มทันที (Skip)
func force_skip_typing():
	if current_tween and current_tween.is_valid():
		current_tween.kill()
		
	scale = Vector2.ONE
	label.visible_ratio = 1.0
	
func hide_dialogue():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.2)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await tween.finished
	hide()
