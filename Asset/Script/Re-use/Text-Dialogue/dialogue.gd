extends Area2D

@export var next_scene_path: String = ""
@export var target_spawn_point_name: String = ""
@export_multiline var dialog_text: Array[String] = [""]
@export_enum("ให้ขยับไปจุด", "ไม่ขยับไปจุด") var behavior: int = 0

@onready var speech_bubble = $speech
@onready var anim1 = $AnimationPlayer1
@onready var anim2 = $AnimationPlayer2
@onready var box = $box
@onready var dot = $dot
@onready var pos_npc = $PosNPC
@onready var pos_player = $PosPlayer

var player_start_pos: Vector2
var is_talking = false
var can_interact = false
var current_line = 0
var current_player: Node2D = null
var is_busy = false

func _ready():
	if speech_bubble: speech_bubble.hide()
	if box: box.hide()
	if dot: dot.hide()

func _process(_delta):
	if can_interact and not is_busy and Input.is_action_just_pressed("interact"):
		if not is_talking:
			start_dialogue()
		else:
			continue_dialogue()

#เริ่มบทพูด
func start_dialogue():
	is_talking = true
	current_line = 0
	box.hide()
	dot.hide()
	
	if current_player: 
		is_busy = true
		current_player.is_locked = true
		player_start_pos = current_player.global_position
		
		if behavior == 0 :
			await move_player(current_player, $PlayerSpot.global_position)
		
		# หันหน้าคุยกัน
		var sprite = current_player.get_node_or_null("Animaton/Sprite2D")
		if sprite:
			sprite.flip_h = (global_position.x < current_player.global_position.x)
			
		is_busy = false
		
	update_speech_bubble()

#คุยต่อ
func continue_dialogue():
	
	if InnerVoice and InnerVoice.visible and InnerVoice.is_typing():
		InnerVoice.force_skip_typing()
		return
		

	if speech_bubble.visible and speech_bubble.label.visible_ratio < 0.99:
		speech_bubble.force_skip_typing() # เร่งข้อความให้เต็ม
		return
		
	current_line += 1
	if current_line < dialog_text.size():
		update_speech_bubble()
	else:
		end_dialogue()

#จบบทพูด
func end_dialogue():
	is_busy = true
	speech_bubble.hide_dialogue()
	if InnerVoice: InnerVoice.hide_text() 
	
	if next_scene_path != "":
		print("กำลังเปลี่ยนฉากไปที่: ", next_scene_path)
		Global.load_exact_pos = false
		Global.target_spawn_name = target_spawn_point_name
		LoadingScreen.transition_to_screenfunc(next_scene_path)
	else:
		# ถ้าไม่ได้เปลี่ยนฉาก ให้เดินกลับที่เดิม
		if current_player:
			await move_player(current_player, player_start_pos)
			current_player.is_locked = false
			
		is_talking = false
		is_busy = false
		box.show()
		dot.show()

#สำหรับขยับตัวผู้เล่น
func move_player(player: Node2D, target_pos: Vector2):
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
	
	await move_tween.finished
	
	if anim:
		anim.play("idle")

# อัปเดตกล่องข้อความ
func update_speech_bubble():
	if current_line >= dialog_text.size(): return 
	
	var full_text = dialog_text[current_line]
	var parts = full_text.split(":", true, 1) 
	var display_text = full_text
	var is_inner_voice = false 
	
	if parts.size() > 1:
		var speaker = parts[0].strip_edges().to_lower() 
		display_text = parts[1].strip_edges() 
		
		if speaker in ["narrator", "innervoice", "inner"]:
			is_inner_voice = true
		elif speaker == "player" or speaker == "me":
			speech_bubble.global_position = pos_player.global_position
		else:
			speech_bubble.global_position = pos_npc.global_position
	else:
		speech_bubble.global_position = pos_npc.global_position


	if is_inner_voice:
		speech_bubble.hide()
		if InnerVoice: InnerVoice.speak(display_text)
	else:
		if InnerVoice: InnerVoice.hide_text() # ซ่อนเสียงในใจ
		speech_bubble.show()
		speech_bubble.show_dialogue(display_text)
	
#ตรวจจับการเข้าของผู้เล่น
func _on_body_entered(body):
	if body.name == "Player":
		can_interact = true
		current_player = body
		box.show()
		anim2.play("glowing")
		dot.show()
		anim1.play("dot")

#ตรวจจับการออกของผู้เล่น
func _on_body_exited(body):
	if body.name == "Player":
		can_interact = false
		current_player = null
		box.hide()
		dot.hide()
		anim1.stop()
		anim2.stop()
		
		if is_talking:
			is_talking = false
			speech_bubble.hide_dialogue()
			if InnerVoice: InnerVoice.hide_text()
