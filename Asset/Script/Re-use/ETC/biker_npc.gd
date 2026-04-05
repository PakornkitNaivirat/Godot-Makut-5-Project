extends Node2D

var current_speed: float = 0.0
var direction: int = 1
var end_pos_x: float = 1500.0

@onready var sprite = $Sprite2D

# 🌟 เปลี่ยนให้รับ Texture2D แค่รูปเดียว
func setup(tex: Texture2D, speed: float, dir: int, end_x: float):
	if tex:
		sprite.texture = tex # ใช้รูปที่ตัวแม่ส่งมาให้
		
	current_speed = speed
	direction = dir
	end_pos_x = end_x
	
	# ถ้าวิ่งไปทางซ้าย (-1) ให้กลับด้านรูป
	if direction == -1:
		sprite.flip_h = false  # ถ้าวิ่งไปซ้าย ให้กลับรูป
	else:
		sprite.flip_h = true

func _process(delta):
	position.x += current_speed * direction * delta
	
	# วิ่งพ้นจอแล้วลบทิ้ง
	if (direction == 1 and position.x >= end_pos_x) or (direction == -1 and position.x <= end_pos_x):
		queue_free()
