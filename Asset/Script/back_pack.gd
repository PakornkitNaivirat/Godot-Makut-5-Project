extends Node2D

@onready var anim = $AnimationPlayer
@export var full_texture: Texture2D 

var collected_count = 0
var max_items = 2


func add_item():
	collected_count += 1
	print("เก็บของได้: ", collected_count, "/", max_items)
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
	
	# ถ้าเก็บครบ 2 ชิ้นแล้ว
	if collected_count >= max_items:
		print("ของครบแล้ว! เปลี่ยนรูปกระเป๋า!")
		
		await tween.finished
		anim.play("Full")
		
