extends Node

var checked_sprite = preload("res://Asset/Spirte/Prop/Backpack/image-Photoroom (10).png")
# 1. เพิ่ม "mug" เข้าไปในลิสต์ของต้องห้าม
var not_allowed_items = ["gameboy", "snack", "mug"]

# 2. เพิ่ม -> bool ต่อท้าย เพื่อบอกว่าฟังก์ชันนี้จะตอบคำถามเป็น true/false
func check_item(item_name: String) -> bool:
	
	# ถ้าไอเทมที่ลากมา ดันอยู่ในรายชื่อของห้ามเอาไป
	if item_name in not_allowed_items:
		InnerVoice.speak("I don't think i need this.")
		# ตอบกลับไปว่า false (ไม่อนุญาต)
		return false 
	
	
	# ถ้าไม่ใช่ของต้องห้าม ก็ให้ขีดถูกที่ Checklist ตามปกติ
	match item_name:
		"ipad":
			%Check_Ipad.texture = checked_sprite
		"laptop":
			%Check_Laptop.texture = checked_sprite
		"key":
			%"Check_RoomKey".texture = checked_sprite
		_:
			print("ไม่พบไอเทมนี้ในระบบเช็คลิสต์: ", item_name)
			
	# ตอบกลับไปว่า true (อนุญาตให้เก็บลงกระเป๋าได้เลย)
	return true
