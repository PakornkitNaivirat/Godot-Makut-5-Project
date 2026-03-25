extends CanvasLayer

@onready var text_label = $TextLabel
var is_speaking = false

func _ready():
	# ซ่อนข้อความไว้ก่อนตอนเริ่มเกม
	text_label.modulate.a = 0 
	visible = false

# ฟังก์ชันสำหรับเรียกใช้เมื่อต้องการโชว์ข้อความ
func speak(text_content: String):
	text_label.text = text_content
	visible = true
	is_speaking = true
	
	# ทำแอนิเมชัน Fade-in (ค่อยๆ สว่างขึ้น) ให้ดูนุ่มนวลเหมือนในรูป
	var tween = get_tree().create_tween()
	tween.tween_property(text_label, "modulate:a", 1.0, 0.5) # ใช้เวลา 0.5 วินาที

func _input(event):
	# ถ้าข้อความโชว์อยู่ และผู้เล่นกด Spacebar หรือคลิกซ้าย ให้ปิดข้อความ
	if is_speaking and (event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed)):
		hide_text()

func hide_text():
	is_speaking = false
	
	# ทำแอนิเมชัน Fade-out (ค่อยๆ จางหายไป)
	var tween = get_tree().create_tween()
	tween.tween_property(text_label, "modulate:a", 0.0, 0.5)
	
	# รอจนกว่าจะจางเสร็จ แล้วค่อยปิด visible
	await tween.finished
	visible = false
