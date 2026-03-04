extends Node2D # หรือ Area2D ขึ้นอยู่กับว่ากระเป๋าคุณสร้างมาจากอะไร

@onready var anim = $AnimationPlayer
@export var full_texture: Texture2D 

var collected_count = 0  # ตัวนับจำนวนของ
var max_items = 2        # จำนวนของที่ต้องเก็บให้ครบ (Ipad + Laptop = 2)

# ฟังก์ชันนี้จะถูกเรียกตอนที่เราปล่อยไอเท็มลงกระเป๋า
func add_item():
	collected_count += 1
	print("เก็บของได้: ", collected_count, "/", max_items)
	
	# 🌟 แอนิเมชันกระเป๋าเด้งรับของ (ย่อ-ขยาย) ด้วย Tween
	var tween = get_tree().create_tween()
	# 1. ขยายกระเป๋าขึ้น 1.2 เท่า อย่างรวดเร็ว (0.1 วินาที)
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1)
	# 2. หดกระเป๋ากลับมาขนาดปกติ (1.0 เท่า) ภายใน 0.1 วินาที
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
	
	# ถ้าเก็บครบ 2 ชิ้นแล้ว
	if collected_count >= max_items:
		print("ของครบแล้ว! เปลี่ยนรูปกระเป๋า!")
		
		# เราสามารถให้มันรอจังหวะเด้งเสร็จนิดนึง ค่อยเล่นอนิเมชัน Full ก็ได้
		# โดยใช้ await ของ tween
		await tween.finished
		anim.play("Full")
		
