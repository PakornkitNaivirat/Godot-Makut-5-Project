extends Control

# 🌟 สร้าง Signal เผื่อไว้ให้โหนดอื่นรับรู้ตอนคุยจบ
signal chat_finished_signal

@export_group("Scene Transition")
@export var next_scene_path: String = ""
@export var target_spawn_point_name: String = ""

@export var trigger_next_day: bool = false

@export_group("Chat Settings")
@export var global_event_flag: String = "" # ชื่อ Event Flag ที่อยากให้เป็น true ตอนคุยจบ

# 🌟 รูปแบบการพิมพ์: "คนพูด: ข้อความ" 
@export_multiline var chat_messages: Array[String] = [
	"NPC: Hello there! Welcome to the club.",
	"Narrator: ฉันหยิบโทรศัพท์ขึ้นมาพิมพ์ตอบกลับอย่างรวดเร็ว",
	"ME: I want to join!",
	"NPC: Thank you for applying."
]

@onready var chat_scroll = $Panel/ChatScroll
@onready var message_list = $Panel/ChatScroll/MessageList
# ดึงโหนดเสียงมาใช้งาน (อ้างอิงจากชื่อโหนดใน Scene ของคุณ)
@onready var message_sound = $MessageSound

var bubble_scene = preload("res://Asset/Screen/script_reuseable/Text/Chat/message_bubble.tscn")

var current_index = 0

func _input(event):
	# กด Spacebar / Enter เพื่อเด้งข้อความถัดไป
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("interact"):
		
		# 🌟 ดักเช็คก่อนว่า InnerVoice กำลังพิมพ์อยู่ไหม
		if InnerVoice.visible and InnerVoice.is_typing():
			InnerVoice.force_skip_typing()
			
		else:
			# ถ้าไม่ได้พิมพ์อยู่ ค่อยไปประโยคถัดไป
			if current_index < chat_messages.size():
				var full_text = chat_messages[current_index]
				process_and_add_message(full_text)
				current_index += 1
			else:
				finish_chat()
			
	# ระบบเลื่อนเมาส์
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			chat_scroll.scroll_vertical -= 40 
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			chat_scroll.scroll_vertical += 40 

# 🌟 ฟังก์ชันแยกส่วนข้อความว่าใครพูด
func process_and_add_message(full_text: String):
	var parts = full_text.split(":", true, 1)
	var display_text = full_text
	var is_me = false
	var is_narrator = false 
	
	if parts.size() > 1:
		var speaker = parts[0].strip_edges().to_lower()
		display_text = parts[1].strip_edges()
		
		if speaker == "narrator" or speaker == "innervoice" or speaker == "inner":
			is_narrator = true
		elif speaker == "me" or speaker == "player":
			is_me = true
			
	if is_narrator:
		InnerVoice.speak(display_text)
	else:
		InnerVoice.hide_text()
		add_message(display_text, is_me)

func add_message(text_content: String, is_me: bool):
	var new_bubble = bubble_scene.instantiate()
	message_list.add_child(new_bubble)
	
	# --- [ส่วนที่แก้ไข] สั่งเล่นเสียงข้อความเข้า/ออก ---
	if message_sound:
		# ถ้าเราเป็นคนส่ง (is_me) อาจจะปรับ Pitch ให้ต่างกันนิดหน่อยเพื่อให้เสียงดูมีมิติ
		if is_me:
			message_sound.pitch_scale = 1.1
		else:
			message_sound.pitch_scale = 1.0
		message_sound.play()
	# -------------------------------------------

	var hbox = new_bubble.get_node("HBoxContainer")
	var bubble_bg = hbox.get_node("BubbleBg")
	var msg_label = bubble_bg.get_node("MessageText")
	
	msg_label.text = text_content

	if text_content.length() < 35:
		msg_label.autowrap_mode = TextServer.AUTOWRAP_OFF
		msg_label.custom_minimum_size.x = 0
	else:
		msg_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		msg_label.custom_minimum_size.x = 350
		
	var style = bubble_bg.get_theme_stylebox("panel").duplicate()
	
	if is_me:
		hbox.alignment = BoxContainer.ALIGNMENT_END
		style.bg_color = Color("51c4d7ff") 
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
	set_process_input(false) 
	InnerVoice.hide_text()
	emit_signal("chat_finished_signal")
	
	if global_event_flag != "":
		Global.event_flags[global_event_flag] = true 
		get_tree().call_group("interactable_items", "update_state")
	
	Global.load_exact_pos = false
	if target_spawn_point_name != "":
		Global.target_spawn_name = target_spawn_point_name
		
	if next_scene_path != "":
		if trigger_next_day == true:
			Global.pending_next_scene = next_scene_path
			LoadingScreen.transition_to_screenfunc("res://Asset/Screen/script_reuseable/Loading/change_day_night.tscn")
		else:
			LoadingScreen.transition_to_screenfunc(next_scene_path)
