extends Area2D

var trash_type : String
var dragging = false
var offset = Vector2.ZERO
signal placed_wrong

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging = true
			get_viewport().set_input_as_handled()
			offset = global_position - get_global_mouse_position()
			z_index = 100
			
			# --- ลูกเล่นตอน "คลิก": ให้ขยะขยายตัวนิดนึง ---
			var tween = create_tween()
			tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EaseType.EASE_OUT)
		else:
			dragging = false
			z_index = 10
			
			# --- ลูกเล่นตอน "ปล่อย": ให้ขนาดกลับมาเท่าเดิม ---
			var tween = create_tween()
			tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
			
			check_drop()

func _process(_delta):
	if dragging:
		global_position = get_global_mouse_position() + offset

func check_drop():
	var areas = get_overlapping_areas()
	for area in areas:
		if area.is_in_group("bins"):
			if area.get("bin_type") == trash_type:
				# หยุดการลากทันที
				dragging = false 
				
				# สร้าง Tween สำหรับเอฟเฟกต์ "โดนดูดเข้าถัง"
				var tween = create_tween()
				tween.set_parallel(true) # สั่งให้ทำงานพร้อมกัน (ย้าย+ย่อ+หมุน)
				
				# 1. วิ่งไปที่จุดศูนย์กลางของถังขยะเป๊ะๆ (ใช้ global_position)
				tween.tween_property(self, "global_position", area.global_position, 0.2)
				
				# 2. ย่อขนาดให้หายไป
				tween.tween_property(self, "scale", Vector2(0, 0), 0.2)
				
				# 3. หมุนตัวขยะนิดนึงให้ดูเหมือนโดนดูด
				tween.tween_property(self, "rotation", 1.5, 0.2)
				
				# สั่งให้ถังขยะเด้งรับ (ถ้าพี่ใส่ฟังก์ชัน play_bounce ใน bin.gd ไว้แล้ว)
				if area.has_method("play_bounce"):
					area.play_bounce()
				
				# พอแอนิเมชันจบ 0.2 วินาที ค่อยลบตัวขยะทิ้ง
				tween.set_parallel(false)
				tween.tween_callback(queue_free)
				return
			else:
				# ถ้าวางผิดถัง ให้เด้งไป Game Over ทันที หรือหักเวลาตามที่ตั้งไว้
				emit_signal("placed_wrong")
				return

	# ถ้าปล่อยเมาส์แล้วไม่โดนถังไหนเลย ให้เด้งกลับขนาดปกติ
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
