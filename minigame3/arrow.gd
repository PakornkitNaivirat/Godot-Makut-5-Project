# ไฟล์ arrow.gd
extends Area2D

var direction = "" # "W", "A", "S", "D"
var speed = 300 # ความเร็วในการวิ่งขึ้น

func _ready():
	# อย่าลืม! เพิ่มกลุ่มนี้เพื่อให้ dance_game.gd นับได้
	add_to_group("arrows")

func _process(delta):
	# สั่งให้วิ่งขึ้นข้างบนจอ (Y ลดลง)
	position.y -= speed * delta
	
	# ถ้าวิ่งทะลุขอบบน (Y < -50) ให้ลบทิ้งและหักเวลา
	if position.y < -50:
		# ต้องสั่งให้ไปเรียกฟังก์ชันหักเวลาในฉากหลัก
		if get_parent().has_method("on_arrow_missed"):
			get_parent().on_arrow_missed()
		queue_free() # ลบตัวเองทิ้ง
