extends Area2D

@onready var interact_icon = $interaction
@onready var speech_bubble = $speech

@export_group("Door Settings")
@export var next_scene_path: String = ""
@export var target_spawn_point_name: String = ""

@export_group("Condition Settings")
@export var required_minigame_id: String = "" 

@export_multiline var locked_dialogue: Array[String] = [
	""
]

var can_interact = false
var current_player: Node2D = null
var is_talking = false
var current_line = 0
var is_busy = false

func _process(_delta):
	if can_interact and not is_busy and Input.is_action_just_pressed("interact"):
		check_door_logic()

func check_door_logic():
	var is_minigame_done = false
	if required_minigame_id != "" and Global.minigame_status.has(required_minigame_id):
		is_minigame_done = Global.minigame_status[required_minigame_id]
	
	# --- กรณีที่ 1: มินิเกมเสร็จแล้ว -> ทำงานเป็นประตูข้ามฉาก ---
	if is_minigame_done or required_minigame_id == "":
		if next_scene_path != "":
			is_busy = true
			
			if current_player:
				current_player.is_locked = true
				current_player.velocity = Vector2.ZERO
				var anim = current_player.get_node_or_null("Animaton/AnimationPlayer")
				if anim:
					anim.play("idle")
					
			Global.load_exact_pos = false
			Global.target_spawn_name = target_spawn_point_name
			LoadingScreen.transition_to_screenfunc(next_scene_path)
			
	# --- กรณีที่ 2: มินิเกมยังไม่เสร็จ -> ทำงานเป็น Dialogue คุยกับตัวเอง ---
	else:
		handle_dialogue()

func handle_dialogue():
	if not is_talking:
		# เริ่มบทสนทนา และล็อคตัวละคร
		is_talking = true
		current_line = 0
		if current_player:
			current_player.is_locked = true # อย่าลืมไปตั้งตัวแปร is_locked ในสคริปต์ Player
			
			current_player.velocity = Vector2.ZERO
			var anim = current_player.get_node_or_null("Animaton/AnimationPlayer")
			if anim:
				anim.play("idle")
		
		interact_icon.hide_icon()
		speech_bubble.show_dialogue(locked_dialogue[current_line])
	else:
		if speech_bubble.visible and speech_bubble.label.visible_ratio < 0.99:
			speech_bubble.force_skip_typing()
			
		else:
			# ถ้าพิมพ์เสร็จแล้ว ค่อยกดเพื่อข้ามบรรทัดต่อไป
			current_line += 1
			if current_line < locked_dialogue.size():
				speech_bubble.show_dialogue(locked_dialogue[current_line])
			else:
				# คุยจบ ปลดล็อคตัวละคร
				is_talking = false
				speech_bubble.hide_dialogue()
				if current_player:
					current_player.is_locked = false
				interact_icon.show_icon()

func _on_body_entered(body):
	if body.name == "Player":
		can_interact = true
		current_player = body
		interact_icon.show_icon()

func _on_body_exited(body):
	if body.name == "Player":
		can_interact = false
		current_player = null
		interact_icon.hide_icon()
		is_busy = false
	
		if is_talking:
			is_talking = false
			speech_bubble.hide_dialogue()
