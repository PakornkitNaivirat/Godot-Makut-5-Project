extends Node2D

@export var next_scene_path: String = "" # ช่องสำหรับใส่ Path ฉากหลักที่จะกลับไป
@export var target_spawn_point_name: String = "" 
@onready var anim = $AnimationPlayer

func _ready():
	# ซ่อนภาพทั้งหมดก่อนเริ่ม (กันเหนียว)
	# (หรือคุณจะไปปรับค่า Modulate (Alpha) ให้เป็น 0 ใน Inspector รอไว้เลยก็ได้)
	
	# สั่งให้ Animation เริ่มเล่นทันทีที่โหลดฉากนี้เสร็จ
	anim.play("Cutscreen") # ชื่อต้องตรงกับที่คุณตั้งใน AnimationPlayer นะครับ

# 🌟 สร้างฟังก์ชันนี้เตรียมไว้ เพื่อให้ AnimationPlayer เรียกใช้ตอนภาพสุดท้าย Fade เสร็จ!
func finish_cutscene():
	print("คัตซีนจบแล้ว กำลังเปลี่ยนฉากกลับ...")
	
	# สั่งให้ระบบจำว่า ต้องกลับไปโผล่ที่ตำแหน่งเดิมเป๊ะๆ ก่อนตัดเข้าคัตซีน
	Global.load_exact_pos = false
	Global.target_spawn_name = target_spawn_point_name
	Global.event_flags["wash_face"] = true
	get_tree().call_group("interactable_items", "update_state")
	
	if next_scene_path != "":
		LoadingScreen.transition_to_screenfunc(next_scene_path)
