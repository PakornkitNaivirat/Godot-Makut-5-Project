extends Node2D

# 1. ช่องสำหรับใส่ไฟล์ Trash.tscn
@export var trash_scene: PackedScene

# 2. ช่องสำหรับใส่รูปขยะหลายๆ แบบ
@export var trash_textures: Array[Texture2D]

# 3. ขอบเขตหาดทรายที่ขยะสามารถลอยมาติดได้ 
@export var min_x: float = 150.0
@export var max_x: float = 1000.0
@export var min_y: float = 250.0
@export var max_y: float = 550.0

# 4. จำนวนขยะที่จะปล่อยมาในแต่ละระลอก 
@export var min_trash_per_wave: int = 2
@export var max_trash_per_wave: int = 4

func _ready():
	randomize()
	# 🌟 1. เริ่มเกมปุ๊บ สุ่มวางขยะชุดแรกทันทีก่อนเลย (ไม่ให้หาดโล่ง)
	spawn_initial_trash()

	# 🌟 2. จากนั้นค่อยเริ่มจับเวลา เพื่อปล่อยระลอกต่อไป
	var timer = Timer.new()
	timer.wait_time = 3.0
	timer.autostart = true
	timer.timeout.connect(spawn_wave)
	add_child(timer)

# ฟังก์ชันเสกขยะชุดแรก (วางแหมะเลย ไม่มีแอนิเมชันคลื่น)
func spawn_initial_trash():
	var initial_amount = randi_range(4, 6)
	var segment_width = (max_x - min_x) / initial_amount
	
	for i in range(initial_amount):
		var target_x = randf_range(min_x + (i * segment_width), min_x + ((i + 1) * segment_width))
		var target_y = randf_range(min_y, max_y)
		
		var trash = trash_scene.instantiate()
		trash.position = Vector2(target_x, target_y)
		trash.rotation_degrees = randf_range(-180, 180)
		if trash_textures.size() > 0:
			trash.trash_texture = trash_textures.pick_random()
			
		add_child(trash)
		connect_trash_signal(trash)

# ฟังก์ชันปล่อยระลอกคลื่น
func spawn_wave():
	if trash_scene == null or trash_textures.size() == 0:
		return

	var trash_amount = randi_range(min_trash_per_wave, max_trash_per_wave)
	
	# 🌟 แบ่งหน้าจอแกน X เป็นส่วนๆ (Segments) ขยะจะได้กระจายซ้าย-ขวา ไม่เกิดทับกัน
	var segment_width = (max_x - min_x) / trash_amount
	
	for i in range(trash_amount):
		# บังคับให้แต่ละชิ้นเกิดในโซนของตัวเอง
		var target_x = randf_range(min_x + (i * segment_width), min_x + ((i + 1) * segment_width))
		var target_y = randf_range(min_y, max_y)
		create_single_trash(Vector2(target_x, target_y))

# ฟังก์ชันสร้างขยะ 1 ชิ้นพร้อมแอนิเมชันคลื่น
func create_single_trash(target_pos: Vector2):
	var trash = trash_scene.instantiate()
	
	# จุดเริ่มจากทะเลลึก (เลื่อนลงไปล่างจอ 250 px)
	var start_pos = target_pos + Vector2(0, 250)
	# 🌟 จุดพีคที่คลื่นซัดมา (เลยจุดหมายเป้าหมายไปนิดนึง)
	var peak_pos = target_pos - Vector2(0, 40)
	
	trash.position = start_pos
	trash.modulate.a = 0.0 
	trash.rotation_degrees = randf_range(-180, 180)
	trash.trash_texture = trash_textures.pick_random() 
	
	# สร้างฟองคลื่นก่อน (จะได้อยู่ใต้ขยะ)
	create_wave_effect(start_pos, peak_pos, target_pos)
	
	add_child(trash)
	connect_trash_signal(trash)

	# 🌊 แอนิเมชันคลื่นซัด (พุ่งมาแล้วไหลย้อนกลับนิดๆ เหมือนน้ำลด)
	var tween = get_tree().create_tween()
	var float_duration = randf_range(1.2, 1.6) # สุ่มความเร็วคลื่นนิดหน่อย
	
	# จังหวะ 1: คลื่นซัดขึ้นมาเร็วๆ
	tween.tween_property(trash, "position", peak_pos, float_duration * 0.6).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(trash, "modulate:a", 1.0, 0.5)
	
	# จังหวะ 2: น้ำลด ขยะไหลถอยหลังกลับลงไปที่เป้าหมายนิดนึง
	tween.tween_property(trash, "position", target_pos, float_duration * 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

# 🌊 ฟังก์ชันสร้างภาพฟองคลื่น (สร้างจากโค้ดเลย ไม่ต้องพึ่งรูปภาพ)
func create_wave_effect(start_pos: Vector2, peak_pos: Vector2, target_pos: Vector2):
	var foam = ColorRect.new()
	foam.color = Color(0.186, 0.404, 0.323, 0.702) # 🌟 ปรับความทึบขึ้นเป็น 0.7 จะได้เห็นชัดๆ
	foam.size = Vector2(80, 10) 
	foam.position = start_pos - Vector2(foam.size.x / 2.0, 0) 
	
	# 🌟 เพิ่มบรรทัดนี้! บังคับให้ฟองคลื่นอยู่หน้าพื้นหลังทราย แต่อยู่ใต้ขยะ (ขยะ z_index = 10)
	foam.z_index = 5 
	
	add_child(foam)
	
	var tween = get_tree().create_tween()
	var float_duration = 1.4
	
	# คลื่นพัดขึ้นมาพร้อมขยายร่าง
	tween.tween_property(foam, "position:y", peak_pos.y, float_duration * 0.6).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(foam, "size:x", 160.0, float_duration * 0.6)
	tween.parallel().tween_property(foam, "position:x", peak_pos.x - 80.0, float_duration * 0.6)
	
	# น้ำลด คลื่นถอยกลับพร้อมจางหายไป
	tween.tween_property(foam, "position:y", target_pos.y, float_duration * 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(foam, "modulate:a", 0.0, float_duration * 0.4)
	
	# ลบคลื่นทิ้งเมื่อจบ
	tween.tween_callback(foam.queue_free)

# ฟังก์ชันเชื่อมต่อสัญญาณคะแนนให้ขยะ
func connect_trash_signal(trash_node):
	var main_game = get_parent()
	if main_game.has_method("_on_trash_clicked") and not trash_node.trash_clicked.is_connected(main_game._on_trash_clicked):
		trash_node.trash_clicked.connect(main_game._on_trash_clicked)
	elif main_game.has_method("add_score") and not trash_node.trash_clicked.is_connected(main_game.add_score):
		trash_node.trash_clicked.connect(main_game.add_score)
