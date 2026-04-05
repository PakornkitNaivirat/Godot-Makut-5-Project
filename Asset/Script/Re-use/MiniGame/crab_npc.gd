extends Area2D

@export var walk_speed: float = 300
@export var group_to_steal: String = "trash_group"

# ตัวแปรสำหรับตั้งค่าการโยกเยก
@export var wobble_angle: float = 15.0 # เอียงซ้าย-ขวากี่องศา
@export var wobble_speed: float = 5.0 # โยกเร็วแค่ไหน

@onready var sprite_node = $Sprite2D
@onready var sound_hit = $SoundEffect_Hit

var target_trash: Node2D = null
var is_carrying_trash: bool = false
var spawn_point: Vector2
var beach_game_node: Node2D
var current_state = "SEEKING"

func _ready():
	spawn_point = position
	# ค้นหาตัวเกมหลัก
	beach_game_node = get_node_or_null("/root/BeachGame") 
	if not beach_game_node:
		beach_game_node = get_parent().get_parent()

func _process(delta):
	match current_state:
		"SEEKING":
			find_and_walk_to_trash(delta)
		"RETURNING":
			walk_back_to_hole(delta)

# ฟังก์ชันเดินหาขยะ
func find_and_walk_to_trash(delta):
	if target_trash != null:
		# ถ้าขยะหายไปจากฉาก, กำลังจะโดนลบ, หรือโดนผู้เล่นกดซ่อนไปแล้ว ให้เลิกเล็งตัวนี้ทันที!
		if not is_instance_valid(target_trash) or target_trash.is_queued_for_deletion() or not target_trash.is_visible():
			target_trash = null 

	# 2. ถ้าไม่มีเป้าหมาย (อาจจะเพราะเพิ่งเกิด หรือเป้าหมายเพิ่งโดนผู้เล่นแย่งไปเมื่อกี้) ให้หาเป้าหมายใหม่
	if target_trash == null:
		var all_trash = get_tree().get_nodes_in_group(group_to_steal)
		var closest_distance = 99999.0
		
		for trash in all_trash:
			# เล็งเฉพาะขยะที่ยังอยู่ดีเท่านั้น
			if is_instance_valid(trash) and trash.is_visible() and not trash.is_queued_for_deletion():
				var dist = position.distance_to(trash.position)
				if dist < closest_distance:
					closest_distance = dist
					target_trash = trash
					
	# 3. ถ้ายืนยันว่ามีเป้าหมายที่ถูกต้องแล้ว ให้เดินไปหา
	if target_trash != null:
		move_towards(target_trash.position, delta)
		
		# ถ้าเดินถึงขยะแล้ว (ระยะห่างน้อยกว่า 20)
		if position.distance_to(target_trash.position) < 20.0:
			steal_trash()
			
	# 4. ถ้าหาดสะอาด ไม่มีเป้าหมายใหม่ให้เล็งแล้ว ให้กลับหลุม
	else:
		current_state = "RETURNING"

# ฟังก์ชันแบกขยะกลับหลุม
func walk_back_to_hole(delta):
	move_towards(spawn_point, delta)
	# ถ้าถึงจุดเกิดแล้ว
	if position.distance_to(spawn_point) < 20.0:
		# 🌟 เช็คว่ามันได้ขยะมาจริงๆ ค่อยแจ้งไปหักคะแนนเกมหลัก
		if is_carrying_trash:
			if beach_game_node and beach_game_node.has_method("_on_trash_stolen"):
				beach_game_node._on_trash_stolen() 
		queue_free() # ปูมุดรูหนีไป

# ฟังก์ชันใช้สำหรับเดินและหันหน้า
func move_towards(target_pos: Vector2, delta: float):
	var direction = (target_pos - position).normalized()
	position += direction * walk_speed * delta
	
	if sprite_node:
		# หันหน้าซ้าย-ขวา
		sprite_node.flip_h = direction.x > 0
		
		# ทำให้ปูโยกเยกไปมาตามเวลา (ใช้ฟังก์ชันคณิตศาสตร์ Sine)
		var time_sec = Time.get_ticks_msec() / 1000.0
		sprite_node.rotation_degrees = sin(time_sec * wobble_speed) * wobble_angle

# ฟังก์ชันตอนหยิบขยะได้
func steal_trash():
	is_carrying_trash = true
	
	# ทำลายขยะทิ้ง
	if is_instance_valid(target_trash):
		target_trash.queue_free() 
	target_trash = null
	
	if sprite_node:
		sprite_node.modulate = Color(1.0, 0.0, 0.0, 1.0) # เปลี่ยนตัวเป็นสีแดงให้รู้ว่าขโมยแล้ว
		
	current_state = "RETURNING"
	walk_speed = 400.0 # วิ่งหนีเร็วขึ้น!
	wobble_speed = 40.0 # โยกเยกเร็วขึ้นด้วยเพราะกำลังรีบหนี!

# ผู้เล่นคลิกตีปู!
func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		
		# ป้องกันการคลิกซ้ำตอนปูกำลังเล่นแอนิเมชันตาย
		if current_state == "DYING":
			return
			
		current_state = "DYING" # เปลี่ยนสถานะให้หยุดเดินทันที
		
		# ปิดการชนเพื่อไม่ให้คลิกโดนอีก
		if has_node("CollisionShape2D"):
			$CollisionShape2D.set_deferred("disabled", true)
		
		if is_carrying_trash:
			print("ตบปูสำเร็จ ได้ขยะคืน!")
			
		# เล่นเสียง
		if sound_hit and sound_hit.stream != null:
			sound_hit.play()
			
		# แอนิเมชัน Tween เด้งตาย (Pop Effect)
		var tween = get_tree().create_tween()
		var base_scale = sprite_node.scale
		
		# จังหวะ 1: เด้งตัวพองขึ้นมา 1.5 เท่า (ใช้เวลา 0.1 วิ)
		tween.tween_property(sprite_node, "scale", base_scale * 1.5, 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		# จังหวะ 2: หดตัวแฟบลงจนหายไป (ใช้เวลา 0.2 วิ)
		tween.tween_property(sprite_node, "scale", Vector2.ZERO, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		
		# รอจนแอนิเมชันเด้งจบ
		await tween.finished
		
		# ถ้ารอเด้งจบแล้วแต่เสียงยังไม่จบ ให้รอจนเสียงจบด้วย
		if sound_hit and sound_hit.playing:
			await sound_hit.finished
			
		queue_free() # ปูตายและลบตัวเองออกจากฉาก
