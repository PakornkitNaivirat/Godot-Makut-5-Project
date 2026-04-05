extends CanvasLayer

@onready var text_label = $TextLabel
@onready var color_rect = $ColorRect # ชี้ไปที่ ColorRect (จอดำ)

var typing_tween: Tween
@export var typing_speed: float = 0.04
@export var wait_time: float = 1.5 # เวลาหยุดรอให้คนอ่าน ก่อนจะขึ้นบรรทัดต่อไป

var current_line_index: int = 0

# 🌟 1. ใส่บทพูดทั้งหมดไว้ในนี้ได้เลย! (เพิ่มลดได้ตามใจชอบ)
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
	# เซ็ตหน้าจอเริ่มต้น
	color_rect.modulate.a = 1.0
	text_label.modulate.a = 1.0
	text_label.text = ""
	text_label.visible_characters = 0
	visible = true
	
	# 🌟 ล็อกโค้ดไม่ให้ข้อความลอยดันขึ้นไปข้างบน!
	text_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	# รอ 1 วินาทีก่อนเริ่มเล่าเรื่อง
	await get_tree().create_timer(1.0).timeout
	play_next_line()

func play_next_line():
	# เช็คว่าพิมพ์จบครบทุกบรรทัดหรือยัง
	if current_line_index >= intro_script.size():
		finish_intro()
		return
		
	var new_sentence = intro_script[current_line_index]
	var start_char_count = text_label.text.length()
	
	# 🌟 2. ถ้าไม่ใช่บรรทัดแรก ให้เคาะขึ้นบรรทัดใหม่ (\n\n) แล้วเอาข้อความใหม่ไปต่อท้าย
	if text_label.text != "":
		text_label.text += "\n\n" + new_sentence # ใช้ \n\n เพื่อให้มีช่องว่างระหว่างบรรทัด (อ่านง่ายขึ้น)
		start_char_count += 2 # บวกรวมอักขระ \n เข้าไปด้วย
	else:
		text_label.text = new_sentence
		start_char_count = 0
		
	# ล็อกจุดที่โชว์ตัวอักษร ให้อยู่แค่ตรงบรรทัดเก่า
	text_label.visible_characters = start_char_count
	
	# 🌟 3. สร้างแอนิเมชัน พิมพ์ดีด เฉพาะบรรทัดใหม่
	if typing_tween:
		typing_tween.kill()
		
	typing_tween = get_tree().create_tween()
	
	var target_char_count = text_label.text.length()
	var type_duration = new_sentence.length() * typing_speed
	
	typing_tween.tween_property(text_label, "visible_characters", target_char_count, type_duration)
	
	# รอจนกว่าจะพิมพ์บรรทัดนี้เสร็จ
	await typing_tween.finished
	
	current_line_index += 1
	
	# หยุดรอให้ผู้เล่นอ่านนิดนึง แล้วค่อยเรียกตัวเองเพื่อพิมพ์บรรทัดถัดไป
	await get_tree().create_timer(wait_time).timeout
	play_next_line()

func finish_intro():
	var fade_tween = get_tree().create_tween()
	
	# เฟดข้อความและจอดำหายไปแบบสวยๆ
	fade_tween.tween_property(text_label, "modulate:a", 0.0, 1.5)
	fade_tween.parallel().tween_property(color_rect, "modulate:a", 0.0, 2.0)
	
	await fade_tween.finished
	visible = false
	
	LoadingScreen.transition_to_screenfunc("res://Asset/Screen/BG/Reuseable/bed_room.tscn")
