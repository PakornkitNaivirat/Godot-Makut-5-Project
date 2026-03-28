extends Control

# --- ตั้งค่าเกม ---
@export var target_spawn_point_name: String = "" 
@export var win_condition: int = 5    # คีบให้ครบ 5 ลูกถึงจบ
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

# --- อ้างอิง Node ---
@onready var bg_bar = $BackgroundBar
@onready var target_zone = $BackgroundBar/TargetZone
@onready var arrow = $BackgroundBar/Arrow
@onready var status_label = $StatusLabel
@onready var moving_tako = $MovingTakoyaki
@onready var box_loc = $BoxLocation

@onready var timer_label = get_node_or_null("TimerLabel")

func _ready():
	#ตั้งค่าเริ่มต้น
	status_label.pivot_offset = status_label.size / 2 # ให้ขยายจากตรงกลาง
	time_left = time_limit
	miss_count = 0	
	reset_game()

func _process(delta):
	if not is_game_over:
		time_left -= delta
		if timer_label:
			timer_label.text = "Time: %.2f" % max(0.0, time_left)
			
		if time_left <= 0:
			trigger_game_over("I ran out of time... I need to be faster!") # ข้อความเวลาหมด
			return
			
	if not is_active: return
		
	#ลูกศรวิ่ง
	arrow.position.x += speed * delta * direction
	var max_x = bg_bar.size.x - arrow.size.x
	
	if arrow.position.x >= max_x:
		arrow.position.x = max_x
		direction = -1
	elif arrow.position.x <= 0:
		arrow.position.x = 0
		direction = 1
		
	#กด Spacebar
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
	
	if success_count >= win_condition:
		is_game_over = true
	
	animate_status_label()
	
	# เก็บตำแหน่งเริ่มไว้ก่อน
	var start_pos = moving_tako.position 
	moving_tako.show()
	
	var tween = create_tween()
	# ลอยไปที่กล่อง หรือ อะไรก็ได้ คิดไม่ออกจะเอาไรมาใส่
	tween.tween_property(moving_tako, "position", box_loc.position, 0.5).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(moving_tako, "rotation_degrees", 180.0, 0.5)
	
	await tween.finished
	 
	var landed_tako = moving_tako.duplicate()
	landed_tako.add_to_group("landed_takoyaki")
	add_child(landed_tako)
	landed_tako.position = box_loc.position
	
	# รีเซ็ตตัวหลักกลับ รอรอบใหม่
	moving_tako.hide()
	moving_tako.position = Vector2(1000, 500)
	moving_tako.rotation_degrees = 0
	
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
		trigger_game_over("I messed up too many times... Let's focus and try again!") # ข้อความพลาดเกิน
		return
	
	await get_tree().create_timer(1.0).timeout
	is_active = true # ให้เล่นต่อ ไม่รีตำแหน่ง
	
func trigger_game_over(reason_text: String):
	is_active = false
	
	if InnerVoice:
		InnerVoice.speak(reason_text)
		
	# รอประมาณ 3 วินาทีให้ผู้เล่นอ่าน (สามารถปรับตัวเลขได้ตามความเหมาะสม)
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
		
		Global.minigame_status["takoyaki"] = true
		
		LoadingScreen.transition_to_screenfunc("res://Asset/Screen/BG/Day3/park_in.tscn")
		queue_free()
		return

	is_active = true
	# สุ่มความเร็ว ตำแหน่งเป้าใหม่
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
