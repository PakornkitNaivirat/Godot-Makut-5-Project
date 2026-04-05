extends CanvasLayer

@onready var display_label = $DisplayLabel
@onready var bg = $BG

@export var typing_speed: float = 0.05
@export var fade_duration: float = 1.0
@export var stay_duration: float = 2.0  # เวลาที่ข้อความค้างไว้ให้คนอ่าน

func _ready():
	# 1. เตรียมหน้าจอให้พร้อม (จอดำสนิท, ข้อความใส)
	bg.modulate.a = 1.0
	display_label.modulate.a = 0.0
	display_label.visible_characters = 0
	visible = true
	
	# 2. เริ่มรันเนื้อเรื่อง (เขียนบทตรงนี้ได้เลย!)
	await start_intro_sequence()

# --- ส่วนของ "บทเนื้อเรื่อง" ---
func start_intro_sequence():
	await get_tree().create_timer(1.0).timeout # รอให้คนดูนิ่งๆ 1 วิ
	
	# ใส่ประโยคที่ต้องการทีละบรรทัด
	await show_message("When I was a kid, I loved sea creatures so much.")
	await show_message("I even dreamed of becoming a marine scientist.")
	await show_message("But I eventually gave up on that dream.")
	await show_message("Even though my life isn't bad now,")
	await show_message("I still secretly wonder what it would be like if I could pursue that dream again.")
	await show_message("Or even just get a little closer to it.")
	await show_message("If that happened, my life might be a little more fun.")
	await show_message("...ring...ring...ring...")
	
	# เมื่อจบเนื้อเรื่อง ให้เฟดจอดำออกเพื่อเริ่มเกม
	await finish_intro()

# --- ฟังก์ชันการทำงานหลัก (ไม่ต้องแก้ส่วนนี้) ---

func show_message(content: String):
	display_label.text = content
	display_label.visible_characters = 0
	
	# 1. เฟดตัวอักษรเข้ามา
	var fade_in = get_tree().create_tween()
	fade_in.tween_property(display_label, "modulate:a", 1.0, fade_duration)
	
	# 2. ทำเอฟเฟกต์พิมพ์ดีด
	var typewriter = get_tree().create_tween()
	var duration = content.length() * typing_speed
	typewriter.tween_property(display_label, "visible_characters", content.length(), duration)
	
	await typewriter.finished
	await get_tree().create_timer(stay_duration).timeout
	
	# 3. เฟดตัวอักษรหายไป (เพื่อเตรียมขึ้นบรรทัดใหม่)
	var fade_out = get_tree().create_tween()
	fade_out.tween_property(display_label, "modulate:a", 0.0, fade_duration)
	await fade_out.finished

func finish_intro():
	# ค่อยๆ เฟดจอดำออกให้เห็นฉากเกมด้านหลัง
	var final_fade = get_tree().create_tween()
	final_fade.tween_property(bg, "modulate:a", 0.0, 2.0)
	await final_fade.finished
	visible = false # ปิด Layer นี้ไปเลย
