extends CanvasLayer

@onready var text_label = $TextLabel
@onready var color_rect = $ColorRect # ชี้ไปที่ ColorRect (จอดำ)
	
var current_tween: Tween
var typing_tween: Tween 
var bg_tween: Tween 
var is_speaking = false

@export var typing_speed: float = 0.04 

func is_typing() -> bool:
	return is_speaking and text_label.visible_characters < text_label.text.length()
	
func force_skip_typing():
	if typing_tween and typing_tween.is_valid():
		typing_tween.kill() 
		
	if current_tween and current_tween.is_valid():
		current_tween.kill() 
		
	text_label.modulate.a = 1.0 
	text_label.visible_characters = text_label.text.length() 

func _ready():
	text_label.modulate.a = 0 
	
	# เซ็ตให้จอดำโปร่งใสตอนเริ่มเกม
	if color_rect:
		color_rect.modulate.a = 0 
		
	visible = false

# 🌟 เพิ่ม parameter "auto_hide" เข้ามา
func speak(text_content: String, auto_hide: bool = true):
	text_label.text = text_content
	text_label.visible_characters = 0 
	visible = true
	is_speaking = true
	
	# --- 1. จัดการ Fade-in ข้อความและจอดำ ---
	if current_tween:
		current_tween.kill() 
	current_tween = get_tree().create_tween()
	current_tween.tween_property(text_label, "modulate:a", 1.0, 0.5)
	
	if bg_tween:
		bg_tween.kill()
	bg_tween = get_tree().create_tween()
	bg_tween.tween_property(color_rect, "modulate:a", 0.8, 0.5)

	# --- 2. จัดการแอนิเมชัน พิมพ์ดีด ---
	if typing_tween:
		typing_tween.kill() 
		
	typing_tween = get_tree().create_tween()
	var type_duration = text_content.length() * typing_speed 
	typing_tween.tween_property(text_label, "visible_characters", text_content.length(), type_duration)

	# --- 3. ระบบรอให้พิมพ์เสร็จ ---
	await typing_tween.finished 
	
	# 🌟 ล็อกไว้ว่า ถ้าเราสั่งปิด auto_hide (จากคัทซีน) ระบบนี้จะไม่ทำงาน! จอดำก็จะค้างไว้
	if auto_hide:
		await get_tree().create_timer(1.5).timeout 
		if text_label.text == text_content:
			hide_text()

func hide_text():
	is_speaking = false
	
	var tween = get_tree().create_tween()
	
	# เฟดหายไปพร้อมกันทั้งจอดำและข้อความ
	tween.tween_property(text_label, "modulate:a", 0.0, 0.5)
	if color_rect:
		tween.parallel().tween_property(color_rect, "modulate:a", 0.0, 0.5)
	
	await tween.finished
	visible = false
