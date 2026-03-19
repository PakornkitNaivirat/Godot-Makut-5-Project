extends Control

@export var next_scene_path: String = ""
@export var target_spawn_point_name: String = ""

@onready var chat_scroll = $Panel/ChatScroll
@onready var message_list = $Panel/ChatScroll/MessageList

var bubble_scene = preload("res://Asset/Screen/script_reuseable/Text/message_bubble.tscn")

var chat_data = [
	{"text": " [Marine Conservation Club Bot]\n Hey there! 👋\n Welcome to the Marine Conservation Club.\n\n If you're interested in joining, I can help\n you sign up real quick.\n Just type:\n - 'join' to apply\n - 'info' to learn more about the club", "is_me": false},
	{"text": " join ", "is_me": true},
	{"text": " Please Enter your name , student ID \n and phone number ", "is_me": false},
	{"text": " 68XXXXXX Time 085-0XXXXXX ", "is_me": true},
	{"text": " Thank you for applying to our club. \n We'll contact you back sooner. ", "is_me": false}
]

var current_index = 0

func _input(event):
	# กด Spacebar เพื่อเด้งข้อความถัดไป
	if event.is_action_pressed("ui_accept"):
		if current_index < chat_data.size():
			var data = chat_data[current_index]
			add_message(data["text"], data["is_me"])
			current_index += 1
		else:
			finish_chat()
	if event is InputEventMouseButton and event.pressed:
		# ถ้ากลิ้งเมาส์ขึ้น
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			chat_scroll.scroll_vertical -= 40 # เลื่อนขึ้น (เลข 40 คือความเร็ว ปรับเพิ่มลดได้)
			
		# ถ้ากลิ้งเมาส์ลง
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			chat_scroll.scroll_vertical += 40 # เลื่อนลง

func add_message(text_content: String, is_me: bool):
	var new_bubble = bubble_scene.instantiate()
	message_list.add_child(new_bubble)
	
	var hbox = new_bubble.get_node("HBoxContainer")
	#var avatar = hbox.get_node("Avatar")
	var bubble_bg = hbox.get_node("BubbleBg")
	var msg_label = bubble_bg.get_node("MessageText")
	
	# 3. ใส่ข้อความลงไป
	msg_label.text = text_content

	if text_content.length() < 35:
		# ข้อความสั้น
		msg_label.autowrap_mode = TextServer.AUTOWRAP_OFF
		msg_label.custom_minimum_size.x = 0
	else:
		msg_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		
		msg_label.custom_minimum_size.x = 350
		
	var style = bubble_bg.get_theme_stylebox("panel").duplicate()
	
	if is_me:
		hbox.alignment = BoxContainer.ALIGNMENT_END
		style.bg_color = Color("51c4d7ff") # สีส้มอมเหลือง
		msg_label.add_theme_color_override("font_color", Color.WHITE)
	else:
		hbox.alignment = BoxContainer.ALIGNMENT_BEGIN
		style.bg_color = Color.WHITE
		msg_label.add_theme_color_override("font_color", Color.BLACK)
	
	bubble_bg.add_theme_stylebox_override("panel", style)
	
	scroll_to_bottom()

func scroll_to_bottom():
	await get_tree().process_frame
	await get_tree().process_frame 
	
	
	var scrollbar = chat_scroll.get_v_scroll_bar()
	chat_scroll.scroll_vertical = scrollbar.max_value

func finish_chat():
	# ปิดระบบรับ Input ชั่วคราว 
	set_process_input(false) 
	
	Global.load_exact_pos = false
	if target_spawn_point_name != "":
		Global.target_spawn_name = target_spawn_point_name
		
	Global.event_flags["join_club_done"] = true 
	get_tree().call_group("interactable_items", "update_state")
	
	if next_scene_path != "":
		LoadingScreen.transition_to_screenfunc(next_scene_path)
