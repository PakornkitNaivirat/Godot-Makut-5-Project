extends Area2D

@export var backpack: Node2D 

var is_dragging = false
var start_position: Vector2

func _ready() -> void:
	start_position = global_position

func _process(delta: float) -> void:
	if is_dragging:
		global_position = get_global_mouse_position()
		
		# ระบบขอบเขต (ลากทะลุจอไม่ได้)
		var screen_size = get_viewport_rect().size
		global_position.x = clamp(global_position.x, 0, screen_size.x)
		global_position.y = clamp(global_position.y, 0, screen_size.y)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		
		if event.pressed:
			var distance = get_global_mouse_position().distance_to(global_position)
			if distance < 100:
				is_dragging = true
				
				var tween = get_tree().create_tween()
				tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1)
				
		
		elif not event.pressed:
			if is_dragging:
				is_dragging = false
				
				var tween = get_tree().create_tween()
				tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
				
				if backpack != null:
					var distance_to_bp = global_position.distance_to(backpack.global_position)
					if distance_to_bp < 200:
						
						if backpack.has_method("add_item"):
							backpack.add_item()
							
						queue_free()
					else:
						return_to_start()
				else:
					return_to_start()
					
func return_to_start():
	var move_tween = get_tree().create_tween()
	
	move_tween.tween_property(self, "global_position", start_position, 0.2)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
