extends CanvasLayer

func _ready():
	# เชื่อมสัญญาณปุ่มกากบาทเข้ากับโค้ด (อย่าลืมเปลี่ยนชื่อโหนด $CloseButton ให้ตรงกับที่คุณตั้ง)
	$CloseButton.pressed.connect(_on_close_button_pressed)

func _on_close_button_pressed():
	# ลบหน้าต่าง Option นี้ทิ้งไป (เหมือนการกดปิด)
	queue_free()
