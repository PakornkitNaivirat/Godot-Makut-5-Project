extends CanvasLayer

@onready var text_label = $TextLabel
	
var current_tween: Tween
var typing_tween: Tween # 🌟 เพิ่ม Tween สำหรับคุมการพิมพ์แยกจากตอน Fade-in
var is_speaking = false

@export var typing_speed: float = 0.04 # 🌟 ความเร็วในการพิมพ์ (วินาที/1 ตัวอักษร) ค่าน้อย = พิมพ์เร็ว

func is_typing() -> bool:
	return is_speaking and text_label.visible_characters < text_label.text.length()
	
func force_skip_typing():
	if typing_tween and typing_tween.is_valid():
		typing_tween.kill() # สั่งหยุดการพิมพ์ทีละตัว
		
	if current_tween and current_tween.is_valid():
		current_tween.kill() # สั่งหยุดการ Fade-in
		
	text_label.modulate.a = 1.0 # สว่างเต็มที่ 100%
	text_label.visible_characters = text_label.text.length() # โชว์ตัวอักษรครบทุกตัวทันที

func _ready():
	# ซ่อนข้อความไว้ก่อนตอนเริ่มเกม
	text_label.modulate.a = 0 
	visible = false

# ฟังก์ชันสำหรับเรียกใช้เมื่อต้องการโชว์ข้อความ
func speak(text_content: String):
	text_label.text = text_content
	text_label.visible_characters = 0 # 🌟 รีเซ็ตให้เริ่มแสดงจาก 0 ตัวอักษรก่อน
	visible = true
	is_speaking = true
	
	# --- 1. จัดการ Fade-in ความสว่าง (ทำเฉพาะตอนขึ้นประโยคแรก) ---
	if text_label.modulate.a < 1.0:
		if current_tween:
			current_tween.kill() 
		current_tween = get_tree().create_tween()
		current_tween.tween_property(text_label, "modulate:a", 1.0, 0.5)

	# --- 2. จัดการแอนิเมชัน พิมพ์ดีด ---
	if typing_tween:
		typing_tween.kill() # หยุดแอนิเมชันพิมพ์ของประโยคเก่า (ถ้ามี)
		
	typing_tween = get_tree().create_tween()
	
	# คำนวณเวลาที่ต้องใช้ทั้งหมด (จำนวนตัวอักษร * ความเร็ว)
	var type_duration = text_content.length() * typing_speed 
	
	# สั่ง Tween ให้ค่อยๆ เพิ่มจำนวนตัวอักษรที่มองเห็นจนครบตามความยาวข้อความ
	typing_tween.tween_property(text_label, "visible_characters", text_content.length(), type_duration)


func hide_text():
	is_speaking = false
	
	# ทำแอนิเมชัน Fade-out (ค่อยๆ จางหายไป)
	var tween = get_tree().create_tween()
	tween.tween_property(text_label, "modulate:a", 0.0, 0.5)
	
	# รอจนกว่าจะจางเสร็จ แล้วค่อยปิด visible
	await tween.finished
	visible = false
