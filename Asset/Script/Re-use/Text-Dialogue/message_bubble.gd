extends Control

@onready var chat_scroll = $Panel/ChatScroll
@onready var message_list = $Panel/ChatScroll/MessageList
# โหลดแม่แบบก้อนข้อความเข้ามา
var bubble_scene = preload("res://Asset/Screen/script_reuseable/Text/message_bubble.tscn")

# ข้อมูลจำลอง: Array เก็บ Dictionary ที่มี "ข้อความ" และบอกว่า "เราเป็นคนพูดหรือไม่"
var chat_data = [
	{"text": "Hey! Did you all make this group chat just to trash talk me?!", "is_me": false},
	{"text": "Haha.", "is_me": true},
	{"text": "Phantom! Phantom!\nWhere's that thing I need?", "is_me": false},
	{"text": "In the green filing cabinet by the references desk.\nSecond drawer from the top.", "is_me": true},
	{"text": "In the green filing cabinet by the references desk.\nSecond drawer from the top.", "is_me": true},
	{"text": "In the green filing cabinet by the references desk.\nSecond drawer from the top.", "is_me": true},
	{"text": "In the green filing cabinet by the references desk.\nSecond drawer from the top.", "is_me": true},
	{"text": "In the green filing cabinet by the references desk.\nSecond drawer from the top.", "is_me": true}
]

var current_index = 0

func _input(event):
	# กด Spacebar (หรือจิ้มจอ) เพื่อเด้งข้อความถัดไป
	if event.is_action_pressed("ui_accept"):
		if current_index < chat_data.size():
			var data = chat_data[current_index]
			add_message(data["text"], data["is_me"])
			current_index += 1
	if event is InputEventMouseButton and event.pressed:
		# ถ้ากลิ้งเมาส์ขึ้น
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			chat_scroll.scroll_vertical -= 40 # เลื่อนขึ้น (เลข 40 คือความเร็ว ปรับเพิ่มลดได้)
			
		# ถ้ากลิ้งเมาส์ลง
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			chat_scroll.scroll_vertical += 40 # เลื่อนลง

func add_message(text_content: String, is_me: bool):
	# 1. เสกก้อนข้อความออกมา
	var new_bubble = bubble_scene.instantiate()
	message_list.add_child(new_bubble)
	
	# 2. ดึง Node ย่อยๆ ในก้อนข้อความมาตั้งค่า
	var hbox = new_bubble.get_node("HBoxContainer")
	#var avatar = hbox.get_node("Avatar")
	var bubble_bg = hbox.get_node("BubbleBg")
	var msg_label = bubble_bg.get_node("MessageText")
	
	# 3. ใส่ข้อความลงไป
	msg_label.text = text_content
	
	# 4. จัดหน้าตาตามคนพูด (จุดกะเทาะเปลือกความเท่!)
	var style = bubble_bg.get_theme_stylebox("panel").duplicate() # ก๊อปปี้ Style มาแก้สี
	
	if is_me:
		# ถ้าเราพูด: ชิดขวา, ซ่อนรูปโปรไฟล์, เปลี่ยนกล่องเป็นสีส้ม
		hbox.alignment = BoxContainer.ALIGNMENT_END
		#avatar.hide()
		style.bg_color = Color("51c4d7ff") # สีส้มอมเหลือง
		msg_label.add_theme_color_override("font_color", Color.WHITE)
	else:
		# ถ้าเพื่อนพูด: ชิดซ้าย, โชว์รูปโปรไฟล์, กล่องสีขาวขอบมน
		hbox.alignment = BoxContainer.ALIGNMENT_BEGIN
		#avatar.show()
		style.bg_color = Color.WHITE
		msg_label.add_theme_color_override("font_color", Color.BLACK)
	
	bubble_bg.add_theme_stylebox_override("panel", style)
	
	# 5. สั่งให้เลื่อนจอลงล่างสุด
	scroll_to_bottom()

func scroll_to_bottom():
	# รอให้ Godot คำนวณความสูงของ UI ใหม่ให้เสร็จก่อน 1 เฟรม (สำคัญมาก ถ้าไม่รอ มันจะเลื่อนไม่สุด)
	await get_tree().process_frame
	
	# ดึงสไลเดอร์แนวตั้งมา แล้วสั่งให้วิ่งไปที่ค่า max (ล่างสุด)
	var scrollbar = chat_scroll.get_v_scroll_bar()
	chat_scroll.scroll_vertical = scrollbar.max_value
