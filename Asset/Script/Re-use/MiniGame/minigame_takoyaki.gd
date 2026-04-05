extends Control

# --- ตั้งค่าเกม ---
@export var target_spawn_point_name: String = ""
@export var win_condition: int = 6 # 🌟 เปลี่ยนเป็น 6 ลูก
@export var time_limit: float = 30.0
@export var max_misses: int = 3
@export var custom_floating_font: Font

var time_left: float
var miss_count: int = 0
var success_count: int = 0
var speed: float = 400.0
var direction: int = 1

var is_active: bool = true
var is_game_over: bool = false

# --- 🌟 อ้างอิง Node ระบบใหม่ (Arrays และ Region) ---
@onready var bg_bar = $BackgroundBar
@onready var target_zone = $BackgroundBar/TargetZone
@onready var arrow = $BackgroundBar/Arrow
@onready var status_label = $StatusLabel
@onready var tongs = $Tongs 
@onready var timer_label = get_node_or_null("TimerLabel")

# ลาก Sprite2D ทาโกะในกระทะ 6 ตัวมาใส่
@export var pan_takos: Array[Sprite2D] 
# ลาก Marker2D ในถาด 6 จุดมาใส่
@export var box_markers: Array[Marker2D]

# ช่องใส่ค่าตัดรูป (Region Rect) ของทาโกะแต่ละแบบ
@export var plain_tako_region: Rect2 
@export var sauce_tako_region: Rect2 
@export var burnt_tako_region: Rect2 

# เก็บตำแหน่งเดิมของทาโกะในกระทะ เอาไว้ตอนรีเซ็ต
var pan_start_positions: Array[Vector2]

func _ready():
	status_label.pivot_offset = status_label.size / 2
	
	# จำตำแหน่งเริ่มต้นของทาโกะทั้ง 6 ลูก
	for tako in pan_takos:
		pan_start_positions.append(tako.global_position)
		
	# ตั้งค่า Z-index ให้ไม้คีบอยู่บนสุดเสมอ
	if tongs: tongs.z_index = 10
	
	print("Global Takoyaki Status: ", Global.minigame_status["takoyaki"])
	reset_entire_game() # ใช้ฟังก์ชันรีเซ็ตใหญ่ตอนเริ่มเลย

func _process(delta):
	if not is_game_over:
		time_left -= delta
		if timer_label:
			timer_label.text = "Time: %.2f" % max(0.0, time_left)
			
		if time_left <= 0:
			# 🌟 ถ้าหมดเวลา เรียกฟังก์ชัน time_out แทน
			time_out()
			return
			
	if not is_active: return
		
	#ลูกศรวิ่ง (ระบบเดิม)
	arrow.position.x += speed * delta * direction
	var max_x = bg_bar.size.x - arrow.size.x
	
	if arrow.position.x >= max_x:
		arrow.position.x = max_x
		direction = -1
	elif arrow.position.x <= 0:
		arrow.position.x = 0
		direction = 1
		
	if Input.is_action_just_pressed("ui_accept"):
		check_hit()

func check_hit():
	is_active = false
	var zone_left = target_zone.position.x
	var zone_right = target_zone.position.x + target_zone.size.x
	var arrow_center = arrow.position.x + (arrow.size.x / 2)
	
	if arrow_center >= zone_left and arrow_center <= zone_right:
		on_success()
	else:
		on_fail()

func on_success():
	# 🌟 ป้องกันกรณีคีบเกิน 6 ลูก
	if success_count >= win_condition: return
	
	var bar_center = bg_bar.global_position + (bg_bar.size / 2)
	spawn_floating_text("PERFECT!", Color.GREEN, bar_center)
	
	# 🌟 เลือกลูกทาโกะ และ จุดวาง ปัจจุบัน
	var current_tako = pan_takos[success_count]
	var target_marker = box_markers[success_count]
	
	status_label.text = "SUCCESS! (" + str(success_count + 1) + "/" + str(win_condition) + ")"
	status_label.modulate = Color.GREEN
	animate_status_label()
	
	# --- 🛠️ ตั้งค่าฉากก่อนเริ่ม Animation ---
	var pickup_height_offset = Vector2(0, -300) # ระยะลอยขึ้น (ใช้ global_position ดีกว่า)
	
	current_tako.z_index = tongs.z_index 
	
	# ตั้งค่าไม้คีบให้เกิด "เหนือ" ทาโกะลูกที่จะคีบ
	tongs.show()
	tongs.global_position = current_tako.global_position + pickup_height_offset
	tongs.rotation_degrees = 0

	# --- 🏗️ สร้างสายพาน Animation (Tween Chain) ---
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	# STEP 1: คีบลงไปหาลูกทาโกะ
	tween.tween_property(tongs, "global_position", current_tako.global_position , 0.3)
	
	# STEP 1.9: เปลี่ยนโหนดแม่ (Reparent) แบบรักษาตำแหน่งเดิมไว้เป๊ะๆ
	tween.tween_callback(func():
		current_tako.reparent(tongs, true) # true คือ keep_global_transform (สะดวกมาก!)
	)

	# STEP 2: คีบขึ้น
	var raised_pos = current_tako.global_position + pickup_height_offset
	tween.tween_property(tongs, "global_position", raised_pos, 0.3)

	# STEP 3: ลากไปอยู่เหนือจุดเป้าหมาย (target_marker) และหมุนโชว์
	var target_raised_pos = target_marker.global_position + pickup_height_offset
	tween.tween_property(tongs, "global_position", target_raised_pos, 0.8).set_trans(Tween.TRANS_SINE)
	

	# STEP 4: คีบลงจ่อที่ถาด
	tween.tween_property(tongs, "global_position", target_marker.global_position + Vector2(0, -20), 0.3)

	# STEP 5.9: ปล่อย Tako กลับคืน Scene หลัก
	tween.tween_callback(func():
		current_tako.reparent(get_node("."), true)
		current_tako.z_index = 0 # 🌟 ให้มันมุดอยู่หลัง Box_wall (สมมติ Box_wall z_index = 2)
	)

	# STEP 6: ทาโกะยากิลงถาด
	tween.tween_property(current_tako, "global_position", target_marker.global_position, 0.1)

	# STEP 7: เด้งดึ๋งในถาด
	tween.tween_callback(func():
		var bounce_tw = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		bounce_tw.tween_property(current_tako, "global_position:y", current_tako.global_position.y - 10, 0.15)
		bounce_tw.tween_property(current_tako, "global_position:y", current_tako.global_position.y, 0.15)
	)

	# STEP 8: ไม้คีบเลื่อนกลับไปด้านบนกระทะ
	var origin_raised_pos = pan_start_positions[success_count] + pickup_height_offset
	tween.tween_property(tongs, "global_position", origin_raised_pos, 0.5)
	tween.parallel().tween_property(tongs, "rotation_degrees", 0.0, 0.5)
	
	# STEP 9: ซ่อนไม้คีบ
	tween.tween_callback(tongs.hide)

	await tween.finished
	
	success_count += 1 # 🌟 นับความสำเร็จ
	
	# เช็คว่าครบ 6 ลูกหรือยัง
	if success_count >= win_condition:
		win_game()
	else:
		await get_tree().create_timer(0.5).timeout
		reset_game()

func on_fail():
	miss_count += 1
	status_label.text = "MISS! TRY AGAIN"
	status_label.modulate = Color.RED
	animate_status_label()
	screen_shake()
	
	var bar_center = bg_bar.global_position + (bg_bar.size / 2)
	spawn_floating_text("MISS!", Color.RED, bar_center)
	
	if miss_count >= max_misses:
		is_game_over = true
		await get_tree().create_timer(1.0).timeout
		trigger_game_over("I messed up too many times... Let's focus and try again!")
		return
	
	await get_tree().create_timer(1.0).timeout
	reset_game()
	
func time_out():
	is_game_over = true
	is_active = false
	timer_label.text = "Time: 0.00"
	
	# 🌟 ทาโกะที่ยังอยู่ในกระทะ (ยังไม่ได้คีบ) เปลี่ยนเป็นลูกไหม้
	for i in range(success_count, win_condition):
		if i < pan_takos.size():
			pan_takos[i].region_rect = burnt_tako_region
			
	trigger_game_over("I ran out of time... They are burned!")

func trigger_game_over(reason_text: String):
	is_active = false
	
	if InnerVoice:
		InnerVoice.speak(reason_text)
		
	await get_tree().create_timer(3.5).timeout
	
	if InnerVoice:
		InnerVoice.hide_text()
		
	reset_entire_game()

func win_game():
	is_game_over = true
	status_label.text = "ALL DONE! 🐙"
	status_label.modulate = Color.WHITE
	
	# 🌟 สร้าง Tween สำหรับ Effect ราดซอส
	var tween = create_tween()
	
	# 🌟 ทำ Effect ไล่ราดซอสทีละลูก
	for tako in pan_takos:
		var original_scale = tako.scale 
		
		tween.tween_property(tako, "scale", original_scale * Vector2(1.2, 0.8), 0.1)
		

		tween.tween_callback(func():
			tako.region_rect = sauce_tako_region
		)

		tween.tween_property(tako, "scale", original_scale, 0.3)\
			.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

		tween.tween_interval(0.1)
		
	await tween.finished
	
	await get_tree().create_timer(1.0).timeout
	
	Global.load_exact_pos = false
	Global.target_spawn_name = target_spawn_point_name
	Global.minigame_status["takoyaki"] = true
	
	LoadingScreen.transition_to_screenfunc("res://Asset/Screen/BG/Day3/park_in.tscn")
	queue_free()

# 🌟 เอาไว้รีเซ็ตเวลากดพลาด 3 ครั้ง หรือหมดเวลา
func reset_entire_game():
	success_count = 0
	miss_count = 0
	time_left = time_limit
	is_game_over = false
	tongs.hide()
	
	# จับทาโกะทุกตัววาร์ปกลับกระทะ และคืนร่างเป็นลูกธรรมดา
	for i in range(win_condition):
		if i < pan_takos.size():
			# ถอนตัวออกจากการเป็นลูกของ tongs เผื่อติดอยู่
			if pan_takos[i].get_parent() == tongs:
				pan_takos[i].reparent(get_node("."))
				
			pan_takos[i].global_position = pan_start_positions[i]
			pan_takos[i].region_rect = plain_tako_region
			pan_takos[i].z_index = 0
			pan_takos[i].rotation_degrees = 0
	
	status_label.text = "START"
	status_label.modulate = Color.WHITE
	
	reset_game()

# 🌟 เอาไว้สุ่มเป้าหมายใหม่ตอนคีบสำเร็จ 1 ลูก หรือพลาดไม่ถึง 3 ครั้ง
func reset_game():
	is_active = true
	speed = randf_range(350.0, 650.0)
	var max_target_pos = bg_bar.size.x - target_zone.size.x
	target_zone.position.x = randf_range(0, max_target_pos)
	arrow.position.x = 0

func animate_status_label():
	var tw = create_tween()
	tw.tween_property(status_label, "scale", Vector2(1.3, 1.3), 0.1)
	tw.tween_property(status_label, "scale", Vector2(1.0, 1.0), 0.1)

func screen_shake():
	var tw = create_tween()
	var op = position
	for i in range(4):
		tw.tween_property(self, "position", op + Vector2(randf_range(-5,5), randf_range(-5,5)), 0.05)
	tw.tween_property(self, "position", op, 0.05)
	
func spawn_floating_text(message: String, text_color: Color, spawn_pos: Vector2):
	var floating_label = Label.new()
	floating_label.text = message
	floating_label.modulate = text_color
	
	# ตั้งค่าให้ข้อความอยู่ตรงกลางจุดที่เกิด
	floating_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	floating_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	if custom_floating_font:
		floating_label.add_theme_font_override("font", custom_floating_font)
	
	# เพิ่มขนาดตัวอักษร (ถ้าอยากให้ใหญ่ขึ้น ปรับเลข 32 ได้เลย)
	floating_label.add_theme_font_size_override("font_size", 48)
	
	# เพิ่ม Label เข้าไปใน Scene ปัจจุบัน
	add_child(floating_label)
	
	# จัดตำแหน่งให้อยู่ตรงกลางของพิกัดที่ส่งมา
	floating_label.global_position = spawn_pos - (floating_label.size / 2)
	floating_label.z_index = 20 # ให้อยู่บนสุด
	
	# --- สร้าง Tween สำหรับ Effect เด้งและ Fade ---
	var tween = create_tween().set_parallel(true) # ให้ทำงานพร้อมกัน
	
	# 1. ลอยขึ้นไปด้านบน 50 พิกเซล ภายใน 0.6 วินาที
	tween.tween_property(floating_label, "global_position:y", floating_label.global_position.y - 100, 0.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	# 2. ค่อยๆ โปร่งใส (Fade out) จนค่า Alpha เป็น 0 ภายใน 0.6 วินาที
	tween.tween_property(floating_label, "modulate:a", 0.0, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	
	# 3. พอลอยและเฟดเสร็จ ให้ลบ Label นี้ทิ้งเพื่อไม่ให้กินหน่วยความจำ
	tween.chain().tween_callback(floating_label.queue_free)
