extends Area2D

@export var backpack: Node2D 

var is_dragging = false

func _process(delta: float) -> void:
	if is_dragging:
		global_position = get_global_mouse_position()
		
		# ระบบขอบเขต (ลากทะลุจอไม่ได้)
		var screen_size = get_viewport_rect().size
		global_position.x = clamp(global_position.x, 0, screen_size.x)
		global_position.y = clamp(global_position.y, 0, screen_size.y)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		
		# --- จังหวะคลิก (หยิบ) ---
		if event.pressed:
			var distance = get_global_mouse_position().distance_to(global_position)
			if distance < 100:
				is_dragging = true
				
				# 🌟 แอนิเมชันขยายใหญ่ (สเกล 1.2 เท่า ภายใน 0.1 วินาที)
				var tween = get_tree().create_tween()
				tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1)
				
		# --- จังหวะปล่อยเมาส์ ---
		elif not event.pressed:
			if is_dragging:
				is_dragging = false
				
				# 🌟 แอนิเมชันหดกลับขนาดเดิม (สเกล 1.0)
				var tween = get_tree().create_tween()
				tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
				
				if backpack != null:
					var distance_to_bp = global_position.distance_to(backpack.global_position)
					if distance_to_bp < 200:
						
						# 🎒 บอกกระเป๋าว่า "ฉันลงกระเป๋าแล้วนะ นำไป 1 แต้ม!"
						if backpack.has_method("add_item"):
							backpack.add_item()
							
						queue_free() # ทำลายไอเท็มทิ้ง (เข้ากระเป๋าไปแล้ว)
