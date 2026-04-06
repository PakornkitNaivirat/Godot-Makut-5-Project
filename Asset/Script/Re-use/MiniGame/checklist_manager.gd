extends Node

var checked_sprite = preload("res://Asset/Spirte/Prop/Backpack/image-Photoroom (10).png")

# BlackList Item
var not_allowed_items = ["mug"]

#
func check_item(item_name: String) -> bool:
	
	# ถ้าเป็น BlackList
	if item_name in not_allowed_items:
		InnerVoice.speak("I don't think i need this.")
		# ไม่อนุญาต
		return false 
	
	
	# ถ้าไม่ใช่  BlackList ก็ให้ติด Checklist ตามปกติ
	match item_name:
		"ipad":
			%Check_Ipad.texture = checked_sprite
		"laptop":
			%Check_Laptop.texture = checked_sprite
		"key":
			%"Check_RoomKey".texture = checked_sprite
		_:
			print("ไม่พบไอเทมนี้ในระบบเช็คลิสต์: ", item_name)
			
	# อนุญาตให้เก็บลงกระเป๋า
	return true
