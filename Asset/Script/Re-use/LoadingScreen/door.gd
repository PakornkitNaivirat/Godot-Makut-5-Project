extends Area2D

@onready var interact_icon = $interaction
@onready var message_sound = $AudioStreamPlayer
@onready var player_spot = $PlayerSpot # 🌟 ดึงตำแหน่งจุดที่จะให้เดินไป
@onready var Doorsound = $Door

@export_category("Scene Transition")
@export var next_scene_path: String = ""
@export var target_spawn_point_name: String = "" 
@export var disappear_after_event: String = ""
@export var sound: AudioStream

# 🌟 เพิ่มตัวเลือกให้เลือกว่าจะเดินไปที่จุดก่อนไหม (0 = เดิน, 1 = ไม่เดิน)
@export_enum("ให้ขยับไปจุด", "ไม่ขยับไปจุด") var behavior: int = 0

var can_interact = false
var current_player: Node2D = null 
var is_busy = false

# ==========================================
# 1. ฟังก์ชันเริ่มต้น
# ==========================================
func _ready():
	if interact_icon: interact_icon.hide()
	
	if disappear_after_event != "" and Global.event_flags.has(disappear_after_event):
		if Global.event_flags[disappear_after_event] == true:
			self.queue_free()
			return

# ==========================================
# 2. ระบบกดปุ่ม Interact
# ==========================================
func _process(_delta):
	# ถ้ากดปุ่ม และไม่ได้กำลังยุ่งอยู่ (กันกดซ้ำตอนตัวละครกำลังเดิน)
	if can_interact and not is_busy and Input.is_action_just_pressed("interact"):
		play_door_sound()
		is_busy = true
		start_door_transition()

func play_door_sound():
	if Doorsound:
		if sound:
			Doorsound.stream = sound # เอาไฟล์เสียงที่เลือกไว้มาใส่
			Doorsound.play()
		else:
			# ถ้าไม่ได้ใส่เสียงในช่อง door_close_sound ให้ลองเล่นเสียงที่ค้างอยู่ในโหนด Door
			Doorsound.play()
			
# ==========================================
# 3. ลำดับการเข้าประตู
# ==========================================
func start_door_transition():
	if current_player:
		current_player.is_locked = true # ล็อกผู้เล่นไม่ให้กดเดินเอง
		
		# ถ้าเลือก "ให้ขยับไปจุด" (behavior == 0) และมีโหนด PlayerSpot ให้เดินไปก่อน
		if behavior == 0 and player_spot:
			await move_player(current_player, player_spot.global_position)
	
	# พอเดินเสร็จ (หรือถ้าเลือกไม่เดิน) ก็ให้เปลี่ยนฉาก
	if next_scene_path != "":
		if message_sound:
			message_sound.play()
		
		Global.load_exact_pos = false
		Global.target_spawn_name = target_spawn_point_name
		LoadingScreen.transition_to_screenfunc(next_scene_path)
	else:
		# ถ้าไม่ได้ใส่ Path ฉากไว้ ให้ปลดล็อกผู้เล่น (เผื่อเทสต์)
		if current_player:
			current_player.is_locked = false
		is_busy = false

# ==========================================
# 4. ฟังก์ชันบังคับเดิน (เอามาจาก Dialogue)
# ==========================================
func move_player(player: Node2D, target_pos: Vector2):
	# ⚠️ ถ้า Player ของคุณไม่ได้ตั้งชื่อโหนดลูกว่า "Animaton" ให้แก้ให้ตรงด้วยนะครับ
	var sprite = player.get_node_or_null("Animaton/Sprite2D") 
	var anim = player.get_node_or_null("Animaton/AnimationPlayer")
	
	var walk_speed = 200.0
	var distance = player.global_position.distance_to(target_pos)
	var duration = distance / walk_speed

	if sprite:
		sprite.flip_h = (target_pos.x < player.global_position.x)
	if anim:
		anim.play("move")
	
	var move_tween = create_tween()
	move_tween.tween_property(player, "global_position", target_pos, duration)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	await move_tween.finished # รอจนกว่าจะเดินถึงจุด
	
	if anim:
		anim.play("idle")

# ==========================================
# 5. ตรวจจับการเข้า-ออก
# ==========================================
func _on_body_entered(body):
	if body.name == "Player":
		can_interact = true
		current_player = body 
		if interact_icon:
			
			interact_icon.show_icon()

func _on_body_exited(body):
	if body.name == "Player":
		can_interact = false
		current_player = null 
		if interact_icon:
			interact_icon.hide_icon()
