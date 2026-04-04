extends Control

# --- ตั้งค่าเกม ---
@export var target_spawn_point_name: String = ""
@export var win_condition: int = 5
@export var time_limit: float = 30.0
@export var max_misses: int = 3

var time_left: float
var miss_count: int = 0
var success_count: int = 0
var total_attempts: int = 0
var speed: float = 400.0
var direction: int = 1

var is_active: bool = true
var is_game_over: bool = false

# --- อ้างอิง Node (อัปเดตใหม่) ---
@onready var bg_bar = $BackgroundBar
@onready var target_zone = $BackgroundBar/TargetZone
@onready var arrow = $BackgroundBar/Arrow
@onready var status_label = $StatusLabel
@onready var moving_tako = $MovingTakoyaki
@onready var box_loc = $BoxLocation # โหนดปลายทาง (ตอนนี้คือถาดที่มีรูปแล้ว)
@onready var tongs = $Tongs # 🌟 เพิ่มโหนดไม้คีบใหม่

@onready var timer_label = get_node_or_null("TimerLabel")

func _ready():
	#ตั้งค่าเริ่มต้น
	status_label.pivot_offset = status_label.size / 2 # ให้ขยายจากตรงกลาง
	time_left = time_limit
	miss_count = 0	
	
	# ปิดตาตัวทาโกะยากิที่เคลื่อนไหวทิ้งไว้ก่อน
	moving_tako.hide()
	
	# ตั้งค่า Z-index ให้ไม้คีบอยู่บนสุดเสมอ
	if tongs: tongs.z_index = 10
	if moving_tako: moving_tako.z_index = 9
	
	print("Global Takoyaki Status: ", Global.minigame_status["takoyaki"])
	reset_game()

func _process(delta):
	if not is_game_over:
		time_left -= delta
		if timer_label:
			timer_label.text = "Time: %.2f" % max(0.0, time_left)
			
		if time_left <= 0:
			trigger_game_over("I ran out of time... I need to be faster!")
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
		
	#กด Spacebar (ui_accept)
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
	success_count += 1
	status_label.text = "SUCCESS! (" + str(success_count) + "/" + str(win_condition) + ")"
	status_label.modulate = Color.GREEN
	
	is_game_over = success_count >= win_condition
	animate_status_label()
	
	# --- 🛠️ ตั้งค่าฉากก่อนเริ่ม Animation ---
	
	# สมมติว่าพิกัดที่ Tako ต้องเกิดคือตรงกลางจอฝั่งขวา (หน้าร้านทาโกะยากิ)
	# คุณปรับตัวเลขพิกัดนี้ (2000, 700) ให้ตรงกับฉากของคุณนะครับ
	var tako_spawn_in_pan = Vector2(1000, 500)
	
	# กำหนดความสูงที่เราจะ "คีบขึ้น" ไป (ให้พ้นขอบร้านก่อนลอยไปที่ถาด)
	var pickup_height_offset = Vector2(1000, 300)
	
	moving_tako.show()
	moving_tako.position = tako_spawn_in_pan
	moving_tako.rotation_degrees = 0
	moving_tako.z_index = tongs.z_index - 1 
	
	# ตั้งค่าไม้คีบให้เกิด "เหนือ" ตัวทาโกะยากิเล็กน้อยเพื่อเตรียมคีบลงมา
	tongs.show()
	tongs.position = moving_tako.position + Vector2(0, - pickup_height_offset.y * 1.5)
	tongs.rotation_degrees = 0
	# (ถ้าคุณทำ Animation ไม้คีบเปิด-ปิด ให้ตั้งเฟรม 'เปิด' ไว้ตรงนี้ครับ)

	# --- 🏗️ สร้างสายพาน Animation (Tween Chain) ---
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	# STEP 1: คีบลง (ไม้คีบเลื่อนลงมาทับทาโกะยากิ)
	tween.tween_property(tongs, "position", moving_tako.position, 0.3)
	
	# STEP 1.5: (ถ้ามี) สั่งเล่น Animation ไม้คีบ "หนีบ" 
	# ตัวอย่าง: tween.tween_callback(tongs_animation_player.play.bind("clamp"))
	
	# STEP 1.9: เปลี่ยนโหนดแม่ (Reparent)
	# 🌟 เทคนิคเด็ด: เพื่อให้ Tako ลอยไปกับไม้คีบได้เป๊ะๆ เราสั่งเอา Tako ไปใส่ในโหนด Tongs!
	# (ใช้ tween_callback เพื่อทำงานนี้ช่วงเสี้ยววินาทีที่ไม้คีบมาถึงตัว Tako พอดี)
	tween.tween_callback(func():
		var current_global_pos = moving_tako.global_position
		# ต้องเปลี่ยน parent เป็น tongs
		moving_tako.reparent(tongs)
		# ต้องบังคับ Global position ให้คงที่ช่วงที่เปลี่ยน parent ป้องกันภาพเด้ง
		moving_tako.global_position = current_global_pos
	)

	# STEP 2: คีบขึ้น (คีบ Tako ลอยขึ้นสูง)
	# ตอนนี้เราสั่งแค่โหนด Tongs เคลื่อนที่ Tako จะลอยตามไปเองโดยอัตโนมัติครับ!
	tween.tween_property(tongs, "position", pickup_height_offset, 0.3).as_relative()

	# STEP 3: ลากไป (ลากไปอยู่เหนือถาดปลายทาง - BoxLocation)
	# เรากำหนดปลายทางให้อยู่ "เหนือ" ถาดปลายทางเล็กน้อยก่อนปล่อย
	var tray_transport_height = box_loc.position + Vector2(0, - pickup_height_offset.y)
	tween.tween_property(tongs, "position", tray_transport_height, 0.8).set_trans(Tween.TRANS_SINE)
	# 🌟 Parallel: หมุน Tako ไปด้วยตอนลาก (ให้ดูขี้เล่น เหมือนในโค้ดเดิม)
	tween.parallel().tween_property(tongs, "rotation_degrees", 360.0 * 2.0, 0.8)

	# STEP 4: คีบลงใส่ถาด (คีบลงไปจ่อๆ บนช่องถาด)
	tween.tween_property(tongs, "position", box_loc.position + Vector2(0, -20), 0.3)

	# STEP 5: คีบเปิด (ไม้คีบ "เปิด" ปล่อยทาโกะยากิ)
	# (ถ้ามี) tween.tween_callback(tongs_animation_player.play.bind("open"))
	
	# STEP 5.9: ปล่อย Tako (Reparent คืน)
	# สั่งเปลี่ยน Tako กลับมาเป็นลูกของ Control Node หลัก ('.' หมายถึงโหนด MinigameTakoyaki)
	tween.tween_callback(func():
		moving_tako.reparent(get_node(".")) # เอากลับคืนแม่เดิม
	)

	# STEP 6: ทาโกะยากิลงถาด (Tako ค่อยๆ ลงไปวางในช่องถาดจนถึงจุด BoxLocation เป๊ะๆ)
	tween.tween_property(moving_tako, "position", box_loc.position, 0.1)

	# STEP 7: duplicate (ระบบเดิม: ทำแฝดเพื่อวางในถาดถาวร)
	tween.tween_callback(func():
		var landed_tako = moving_tako.duplicate()
		landed_tako.add_to_group("landed_takoyaki")
		add_child(landed_tako)
		# landed tako จะเกิดตรงพิกัด `moving_tako.position` เป๊ะๆ (ซึ่งคือ BoxLocation)
		landed_tako.rotation_degrees = moving_tako.rotation_degrees # ก็อปปี้หมุนไปด้วย
		
		# 🌟 เทคนิคแถม: ใส่แอนิเมชัน "เด้งดึ๋ง" ตอน Tako ลงถาดให้นุ่มๆ ครับ
		var bounce_tw = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		bounce_tw.tween_property(landed_tako, "position:y", landed_tako.position.y - 10, 0.15)
		bounce_tw.tween_property(landed_tako, "position:y", landed_tako.position.y, 0.15)
		
		moving_tako.hide() # ซ่อน active tako เพื่อรอเล่นรอบต่อไป
	)

	# STEP 8: ไม้คีบเลื่อนกลับ (ถอยหนีออกนอกจอไปแบบสวยๆ)
	# เราสั่งไม้คีบให้ถอยกลับไปทางเดิมที่มันโผล่มา
	tween.tween_property(tongs, "position", tako_spawn_in_pan + Vector2(0, - pickup_height_offset.y * 1.5), 0.5)
	# parallel: หมุนคืน
	tween.parallel().tween_property(tongs, "rotation_degrees", 0.0, 0.5)
	
	# STEP 9: ซ่อนไม้คีบตอนจบ
	tween.tween_callback(tongs.hide)

	# STEP 10: จบ Chain
	# Await ให้แอนิเมชันทั้งหมดด้านบนนี้รันเสร็จเรียบร้อยก่อน!
	await tween.finished
	
	# หน่วงเวลาเล็กน้อยก่อนรีเซ็ตระบบ
	await get_tree().create_timer(0.5).timeout
	reset_game()

func on_fail():
	miss_count += 1
	status_label.text = "MISS! TRY AGAIN"
	status_label.modulate = Color.RED
	animate_status_label()
	screen_shake()
	
	if miss_count >= max_misses:
		is_game_over = true
		await get_tree().create_timer(1.0).timeout
		trigger_game_over("I messed up too many times... Let's focus and try again!")
		return
	
	await get_tree().create_timer(1.0).timeout
	is_active = true
	
func trigger_game_over(reason_text: String):
	is_active = false
	
	if InnerVoice:
		InnerVoice.speak(reason_text)
		
	# รอประมาณ 3 วินาทีให้ผู้เล่นอ่าน
	await get_tree().create_timer(3.5).timeout
	
	if InnerVoice:
		InnerVoice.hide_text()
		
	reset_entire_game()

func reset_entire_game():
	success_count = 0
	miss_count = 0
	time_left = time_limit
	
	# ลบทาโกะยากิที่ลงกล่องไปแล้วออกให้หมด
	get_tree().call_group("landed_takoyaki", "queue_free")
	
	status_label.text = "TRY AGAIN!"
	status_label.modulate = Color.WHITE
	
	is_game_over = false
	reset_game()

func reset_game():
	if success_count >= win_condition:
		status_label.text = "ALL DONE! 🐙"
		await get_tree().create_timer(1.0).timeout
		
		Global.load_exact_pos = false
		Global.target_spawn_name = target_spawn_point_name
		
		# ✅ ปรับเป็นเท่ากับตัวเดียวเรียบร้อย
		Global.minigame_status["takoyaki"] = true
		
		LoadingScreen.transition_to_screenfunc("res://Asset/Screen/BG/Day3/park_in.tscn")
		queue_free()
		return

	is_active = true
	# สุ่มความเร็ว ตำแหน่งเป้าใหม่ (ระบบเดิม)
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
