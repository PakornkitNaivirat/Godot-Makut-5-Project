extends Node2D

# 1. ช่องสำหรับใส่ไฟล์ Trash.tscn
@export var trash_scene: PackedScene

# 2. ช่องสำหรับใส่รูปขยะหลายๆ แบบ
@export var trash_textures: Array[Texture2D]
@export var crab_scene: PackedScene 

# 3. ขอบเขตหาดทรายที่ขยะสามารถลอยมาติดได้ 
@export var min_x: float = 150.0
@export var max_x: float = 1000.0
@export var min_y: float = 250.0
@export var max_y: float = 550.0

# 4. จำนวนขยะที่จะปล่อยมาในแต่ละระลอก 
@export var min_trash_per_wave: int = 2
@export var max_trash_per_wave: int = 4

@export var min_crabs_per_wave: int = 1
@export var max_crabs_per_wave: int = 3
@export var crab_spawn_chance: float = 0.7

# 🌟 ย้ายตัวแปรพวกนี้ขึ้นมาไว้ด้านบนสุด!
var base_color = Color(1, 1, 1, 0.4) # สีขาวโปร่งแสง (ฐาน)
var highlight_color = Color(1, 1, 1, 0.7) # สีขาวบริสุทธิ์ (ไฮไลท์)
var base_size = Vector2(80, 10) # ขนาดเริ่มต้น (ฐาน)
var highlight_size = Vector2(60, 8) # ขนาดเริ่มต้น (ไฮไลท์)

func _ready():
	randomize()
	# 1. เริ่มเกมปุ๊บ สุ่มวางขยะชุดแรกทันทีก่อนเลย (ไม่ให้หาดโล่ง)
	spawn_initial_trash()

	# 2. จากนั้นค่อยเริ่มจับเวลา เพื่อปล่อยระลอกต่อไป
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
	
	# แบ่งหน้าจอแกน X เป็นส่วนๆ (Segments) ขยะจะได้กระจายซ้าย-ขวา ไม่เกิดทับกัน
	var segment_width = (max_x - min_x) / trash_amount
	
	for i in range(trash_amount):
		# บังคับให้แต่ละชิ้นเกิดในโซนของตัวเอง
		var target_x = randf_range(min_x + (i * segment_width), min_x + ((i + 1) * segment_width))
		var target_y = randf_range(min_y, max_y)
		create_single_trash(Vector2(target_x, target_y))
	
	# --- 🌟 ส่วนที่แก้ไขเรื่องปู: สุ่มจำนวนและเกิดทีละหลายตัว ---
	if crab_scene != null and randf() < crab_spawn_chance:
		# สุ่มว่ารอบนี้จะมาหน้าหาดกี่ตัว
		var crab_amount = randi_range(min_crabs_per_wave, max_crabs_per_wave)
		var existing_crab_positions = [] # เก็บตำแหน่งปูที่เกิดไปแล้วในรอบนี้
		
		for c in range(crab_amount):
			var spawn_pos = Vector2.ZERO
			var valid_position_found = false
			var attempts = 0 # จำนวนรอบที่พยายามสุ่มหาที่ว่าง
			
			# ลองสุ่มตำแหน่งใหม่ไปเรื่อยๆ จนกว่าจะไม่ซ้อน (สูงสุด 10 ครั้งต่อตัวเพื่อป้องกันเกมค้าง)
			while not valid_position_found and attempts < 10:
				attempts += 1
				var spawn_side = randi() % 3
				
				if spawn_side == 0:
					# นอกจอซ้าย
					spawn_pos = Vector2(min_x - randf_range(200, 600), randf_range(min_y, max_y)) 
				elif spawn_side == 1:
					# นอกจอขวา
					spawn_pos = Vector2(max_x + randf_range(200, 600), randf_range(min_y, max_y)) 
				else:
					# นอกจอด้านล่าง
					spawn_pos = Vector2(randf_range(min_x, max_x), max_y + randf_range(400, 800)) 
				
				# ตรวจสอบว่าตำแหน่งที่สุ่มได้ ซ้อนทับกับปูตัวอื่นที่เพิ่งเกิดไหม (ห่างกันอย่างน้อย 150 px)
				valid_position_found = true
				for pos in existing_crab_positions:
					if spawn_pos.distance_to(pos) < 150.0: # ปรับระยะห่างตรงนี้ได้ (150 pixel)
						valid_position_found = false
						break
			
			# ถ้าพยายามสุ่มจนเจอที่ว่าง (หรือไม่ว่างแต่พยายามครบ 10 ครั้งแล้ว) ก็สร้างปูเลย
			var crab = crab_scene.instantiate()
			crab.position = spawn_pos
			add_child(crab)
			existing_crab_positions.append(spawn_pos) # บันทึกตำแหน่งไว้ให้ตัวต่อไปเช็ค

# ฟังก์ชันสร้างขยะ 1 ชิ้นพร้อมแอนิเมชันคลื่น
func create_single_trash(target_pos: Vector2):
	var trash = trash_scene.instantiate()
	
	# จุดเริ่มจากทะเลลึก (เลื่อนลงไปล่างจอ 250 px)
	var start_pos = target_pos + Vector2(0, 250)
	# จุดพีคที่คลื่นซัดมา (เลยจุดหมายเป้าหมายไปนิดนึง)
	var peak_pos = target_pos - Vector2(0, 40)
	
	trash.position = start_pos
	trash.modulate.a = 0.0 
	trash.rotation_degrees = randf_range(-180, 180)
	trash.trash_texture = trash_textures.pick_random() 
	
	# สร้างฟองคลื่นก่อน (จะได้อยู่ใต้ขยะ)
	create_wave_effect(start_pos, peak_pos, target_pos)
	
	add_child(trash)
	connect_trash_signal(trash)

	# แอนิเมชันคลื่นซัด (พุ่งมาแล้วไหลย้อนกลับนิดๆ เหมือนน้ำลด)
	var tween = get_tree().create_tween()
	var float_duration = randf_range(1.2, 1.6) # สุ่มความเร็วคลื่นนิดหน่อย
	
	# จังหวะ 1: คลื่นซัดขึ้นมาเร็วๆ
	tween.tween_property(trash, "position", peak_pos, float_duration * 0.6).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(trash, "modulate:a", 1.0, 0.5)
	
	# จังหวะ 2: น้ำลด ขยะไหลถอยหลังกลับลงไปที่เป้าหมายนิดนึง
	tween.tween_property(trash, "position", target_pos, float_duration * 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func create_wave_effect(start_pos: Vector2, peak_pos: Vector2, target_pos: Vector2):
	# 1. สร้าง Base Foam (ฐานคลื่น)
	var base_foam = ColorRect.new()
	base_foam.color = base_color
	base_foam.size = base_size
	base_foam.position = start_pos - Vector2(base_foam.size.x / 2.0, 0)
	base_foam.z_index = 5
	add_child(base_foam)

	# 2. สร้าง Highlight Foam (ไฮไลท์คลื่น)
	var highlight_foam = ColorRect.new()
	highlight_foam.color = highlight_color
	highlight_foam.size = highlight_size
	highlight_foam.position = start_pos - Vector2(highlight_foam.size.x / 2.0, 1) # เลื่อนขึ้นนิดหน่อย
	highlight_foam.z_index = 6 # อยู่เหนือฐานนิดหน่อย
	add_child(highlight_foam)

	# 3. แอนิเมชัน Tween
	var tween = get_tree().create_tween()
	var float_duration = 1.6 # ปรับเวลาให้นุ่มนวลขึ้น
	var alpha_duration = 1.0 # เวลาสำหรับจางหาย

	# พุ่งขึ้นพร้อมกัน (Cubic/Expo)
	tween.parallel().tween_property(base_foam, "position:y", peak_pos.y, float_duration * 0.5).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(highlight_foam, "position:y", peak_pos.y, float_duration * 0.5).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)

	# ขยายตัวพร้อมกัน (Cubic/Expo)
	tween.parallel().tween_property(base_foam, "size:x", 160.0, float_duration * 0.5)
	tween.parallel().tween_property(base_foam, "position:x", peak_pos.x - 80.0, float_duration * 0.5)
	tween.parallel().tween_property(highlight_foam, "size:x", 140.0, float_duration * 0.5)
	tween.parallel().tween_property(highlight_foam, "position:x", peak_pos.x - 70.0, float_duration * 0.5)

	# ถอยกลับพร้อมกัน (Sine)
	tween.parallel().tween_property(base_foam, "position:y", target_pos.y, float_duration * 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(highlight_foam, "position:y", target_pos.y, float_duration * 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# จางหายพร้อมกัน (Cubic/Expo, Highlight จางเร็วกว่านิดหน่อย)
	tween.parallel().tween_property(base_foam, "modulate:a", 0.0, alpha_duration * 0.8)
	tween.parallel().tween_property(highlight_foam, "modulate:a", 0.0, alpha_duration * 0.6) # จางเร็วกว่า

	# ลบออกเมื่อจบ
	tween.tween_callback(base_foam.queue_free)
	tween.tween_callback(highlight_foam.queue_free)

# ฟังก์ชันเชื่อมต่อสัญญาณคะแนนให้ขยะ
func connect_trash_signal(trash_node):
	var main_game = get_parent()
	if main_game.has_method("_on_trash_clicked") and not trash_node.trash_clicked.is_connected(main_game._on_trash_clicked):
		trash_node.trash_clicked.connect(main_game._on_trash_clicked)
	elif main_game.has_method("add_score") and not trash_node.trash_clicked.is_connected(main_game.add_score):
		trash_node.trash_clicked.connect(main_game.add_score)
