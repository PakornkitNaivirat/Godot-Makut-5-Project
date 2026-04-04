extends Area2D

# 1. ส่วนเลือกรูปขยะ
@export var trash_texture : Texture2D

# 2. ส่วนอ้างอิงโหนดรูปภาพ
@onready var sprite = $Sprite2D

# 3. ส่วนส่งสัญญาณ
signal trash_clicked

# 🌟 เพิ่มตัวแปรล็อคการคลิกเบิ้ล
var is_collected: bool = false

func _ready():
	# เปลี่ยนรูปให้ตามที่เลือกไว้ใน Inspector
	if trash_texture and sprite:
		sprite.texture = trash_texture
	
	# ตั้งค่าให้พร้อมรับการคลิก
	input_pickable = true
	z_index = 10  # บังคับให้อยู่หน้าทรายเสมอ

func _input(event):
	# 🌟 ถ้าโดนเก็บไปแล้ว ให้หยุดการทำงาน (ป้องกันการคลิกซ้ำ)
	if is_collected:
		return

	# เช็คว่าเป็นการคลิกเมาส์ซ้าย
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		
		var mouse_pos = get_global_mouse_position()
		
		# ระยะห่างระหว่างเมาส์กับขยะ
		if global_position.distance_to(mouse_pos) < 60:
			collect_trash()

# 🌟 ฟังก์ชันแยกสำหรับตอนเก็บขยะ
func collect_trash():
	is_collected = true # ล็อคทันทีไม่ให้คลิกซ้ำ
	
	print("--- ทำลายขยะสำเร็จ: ", name)
	
	# ส่งสัญญาณบอกแม่ (beach_game) ให้บวกคะแนน
	emit_signal("trash_clicked")
	
	# 1. ปิดการมองเห็น และปิดการชน
	if sprite:
		sprite.visible = false
	if has_node("CollisionShape2D"):
		$CollisionShape2D.set_deferred("disabled", true)
		
	# 2. เล่นฝุ่น 
	if has_node("DustEffect"):
		$DustEffect.emitting = true
		
	# 3. เล่นเสียง
	if has_node("SoundEffect"):
		$SoundEffect.play()
		
	# 🌟 4. หน่วงเวลาส่วนกลาง (ไม่ว่าจะมีเสียงหรือไม่มี ก็ให้รอ 1.5 วินาทีเพื่อให้ฝุ่นกระจายเสร็จ)
	await get_tree().create_timer(1.5).timeout
	
	# 5. ลบทิ้ง
	queue_free()
