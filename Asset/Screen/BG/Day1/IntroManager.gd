extends CanvasLayer

@onready var text_label = $TextLabel
@onready var color_rect = $ColorRect
# 🌟 เพิ่มโหนดเสียง (อย่าลืมสร้างโหนดชื่อนี้ใน Scene นะครับ)
@onready var keyboard_sound = $KeyboardSound

var typing_tween: Tween
@export var typing_speed: float = 0.04
@export var wait_time: float = 1.5 

var current_line_index: int = 0

var intro_script = [
	"When I was a kid, I loved sea creatures so much.",
	"I even dreamed of becoming a marine scientist.",
	"But I eventually gave up on that dream.",
	"Even though my life isn't bad now,",
	"I still secretly wonder what it would be like if I could pursue that dream again.",
	"Or even just get a little closer to it.",
	"If that happened, my life might be a little more fun.",
	"...ring...ring...ring..."
]

func _ready():
	color_rect.modulate.a = 1.0
	text_label.modulate.a = 1.0
	text_label.text = ""
	text_label.visible_characters = 0
	visible = true
	
	text_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	await get_tree().create_timer(1.0).timeout
	play_next_line()

func play_next_line():
	if current_line_index >= intro_script.size():
		finish_intro()
		return
		
	var new_sentence = intro_script[current_line_index]
	var start_char_count = text_label.text.length()
	
	if text_label.text != "":
		text_label.text += "\n\n" + new_sentence
		# ไม่นับรวม \n\n ในการเล่นเสียงพิมพ์ (เพื่อความสมจริง)
		start_char_count = text_label.text.length() - new_sentence.length()
	else:
		text_label.text = new_sentence
		start_char_count = 0
		
	text_label.visible_characters = start_char_count
	
	if typing_tween:
		typing_tween.kill()
		
	typing_tween = get_tree().create_tween()
	
	var target_char_count = text_label.text.length()
	var type_duration = new_sentence.length() * typing_speed
	
	# 🌟 เปลี่ยนจาก tween_property เป็น tween_method เพื่อเรียกฟังก์ชันเล่นเสียง
	typing_tween.tween_method(type_next_character, start_char_count, target_char_count, type_duration)
	
	await typing_tween.finished
	
	current_line_index += 1
	await get_tree().create_timer(wait_time).timeout
	play_next_line()

# 🌟 ฟังก์ชันจัดการการพิมพ์และเล่นเสียง (ถอดแบบมาจากโค้ดตัวอย่าง)
func type_next_character(current_char: int):
	if current_char > text_label.visible_characters:
		text_label.visible_characters = current_char
		
		# ตรวจสอบตัวอักษรล่าสุดที่พิมพ์ออกมา
		var char_index = current_char - 1
		if char_index >= 0 and char_index < text_label.text.length():
			# ถ้าไม่ใช่ช่องว่างและไม่ใช่การขึ้นบรรทัดใหม่ ให้เล่นเสียง
			var current_letter = text_label.text[char_index]
			if current_letter != " " and current_letter != "\n":
				play_keyboard_sound()

# 🌟 ฟังก์ชันเล่นเสียงพร้อมสุ่ม Pitch
func play_keyboard_sound():
	if keyboard_sound:
		keyboard_sound.pitch_scale = randf_range(0.9, 1.2)
		keyboard_sound.play()
	else:
		print("Error: KeyboardSound node NOT FOUND!") # 🌟 ถ้าขึ้นอันนี้ แสดงว่าหาโหนดไม่เจอ

func finish_intro():
	var fade_tween = get_tree().create_tween()
	fade_tween.tween_property(text_label, "modulate:a", 0.0, 1.5)
	fade_tween.parallel().tween_property(color_rect, "modulate:a", 0.0, 2.0)
	
	await fade_tween.finished
	visible = false
	LoadingScreen.transition_to_screenfunc("res://Asset/Screen/BG/Reuseable/bed_room.tscn")
