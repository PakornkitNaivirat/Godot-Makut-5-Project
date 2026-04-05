extends Node2D

@export var trash_scene : PackedScene 
@export var target_spawn_point_name = ""
@onready var timer_label = $CanvasLayer/TimerLabel


var time_left : float = 60.0
var game_over : bool = false
var is_won : bool = false

# 🌟 เพิ่ม Dictionary สำหรับเก็บรูปถังขยะ เอาไว้โชว์ใน Bubble
var bin_textures = {
	"wet": preload("res://Asset/Spirte/Prop/Trash_Prop/ถังขยะเปียก.png"),
	"toxic": preload("res://Asset/Spirte/Prop/Trash_Prop/ถังขยะอันตราย.png"),
	"recycle": preload("res://Asset/Spirte/Prop/Trash_Prop/ถังขยะรีไซเคิล.png"),
	"general": preload("res://Asset/Spirte/Prop/Trash_Prop/ถังขยะทั่วไป.png") 
}

var trash_data = [
	{"img": "res://Asset/Spirte/Prop/Trash_Prop/เปลือกกล้วย.png", "type": "wet"},
	{"img": "res://Asset/Spirte/Prop/Trash_Prop/ขวดน้ำ (1).png", "type": "recycle"},
	{"img": "res://Asset/Spirte/Prop/Trash_Prop/ถ่านไฟฉาย.png", "type": "toxic"},
	{"img": "res://Asset/Spirte/Prop/Trash_Prop/ขวดน้ำ.png", "type": "recycle"},
	{"img": "res://Asset/Spirte/Prop/Trash_Prop/กระดาษลัง.png", "type": "recycle"},
	{"img": "res://Asset/Spirte/Prop/Trash_Prop/ถุงพลาสติก.png", "type": "general"}
]

func _ready():
	randomize()
	spawn_random_trash(10)
	update_timer_display()

func _process(delta):
	if not game_over and not is_won:
		time_left -= delta
		update_timer_display()
		
		if time_left <= 0:
			time_left = 0
			# 🌟 เปลี่ยนไปเรียกฟังก์ชัน time_out แทนตอนเวลาหมด
			time_out()
		
		check_win_condition()

func spawn_random_trash(count):
	var pile_center = Vector2(576, 300) 
	
	for i in range(count):
		var new_trash = trash_scene.instantiate()
		var data = trash_data[randi() % trash_data.size()]
		new_trash.trash_type = data["type"]
		new_trash.add_to_group("current_trash")
		
		var random_offset = Vector2(randf_range(-60, 60), randf_range(-40, 40))
		new_trash.position = pile_center + random_offset
		new_trash.z_index = i 
		new_trash.placed_wrong.connect(_on_wrong_trash.bind(new_trash))
		# new_trash.placed_correct.connect(_on_correct_trash.bind(new_trash))
		
		add_child(new_trash)
		if new_trash.has_node("Sprite2D"):
			new_trash.get_node("Sprite2D").texture = load(data["img"])

func check_win_condition():
	var remaining_trash = get_tree().get_nodes_in_group("current_trash").size()
	
	if remaining_trash == 0 and not is_won:
		_on_win()

func _on_win():
	is_won = true 
	timer_label.modulate = Color.GREEN
	
	# 🌟 ชมผู้เล่นหน่อยตอนแยกขยะเสร็จ
	if InnerVoice:
		InnerVoice.speak("All sorted! Great job keeping the environment clean.")
		
	await get_tree().create_timer(3.0).timeout
	
	if InnerVoice:
		InnerVoice.hide_text()
	
	Global.load_exact_pos = false
	Global.target_spawn_name = target_spawn_point_name
	Global.minigame_status["ChangeTrash"] = true
	
	Global.dawn = true
	
	LoadingScreen.transition_to_screenfunc("res://Asset/Screen/BG/Day4/sea_shore.tscn")
	queue_free()

func _on_correct_trash(trash_node):
	spawn_floating_text("Great!", Color.GREEN, trash_node.global_position)

func _on_wrong_trash(trash_node):
	if not game_over and not is_won:
		time_left -= 3.0
		timer_label.modulate = Color.RED
		
		spawn_floating_text("-3 Sec!", Color.RED, trash_node.global_position)
		show_hint_bubble(trash_node.trash_type, trash_node.global_position)
		
		await get_tree().create_timer(0.2).timeout
		if not is_won: timer_label.modulate = Color.WHITE

func update_timer_display():
	if timer_label:
		# ใช้ max เพื่อไม่ให้เวลาติดลบเวลาโดนหักตอนทิ้งผิด
		timer_label.text = "Time : %.2f" % max(0.0, time_left)

# 🌟 เพิ่มฟังก์ชัน time_out รับจบตอนเวลาหมด (เหมือน Takoyaki)
func time_out():
	if game_over or is_won: return 
	game_over = true
	time_left = 0.0
	update_timer_display()
	
	timer_label.modulate = Color.RED
	timer_label.text = "GAME OVER!"
	
	trigger_game_over("I ran out of time... I need to sort them faster next time!")

# 🌟 ฟังก์ชันจัดการ Game Over โชว์ InnerVoice แล้วรีเซ็ตฉาก
func trigger_game_over(reason_text: String):
	# เรียก InnerVoice ขึ้นมาบ่น
	if InnerVoice:
		InnerVoice.speak(reason_text)
		
	# รอให้ผู้เล่นอ่าน 3.5 วินาที
	await get_tree().create_timer(3.5).timeout
	
	# ซ่อนข้อความ
	if InnerVoice:
		InnerVoice.hide_text()
		
	# รีโหลดด่านนี้ใหม่ให้ผู้เล่นแก้ตัว
	get_tree().reload_current_scene()

# ==========================================
# 🌟 ระบบ Effect ข้อความลอย และ Bubble โชว์รูปถัง
# ==========================================

func spawn_floating_text(message: String, text_color: Color, spawn_pos: Vector2):
	var label = Label.new()
	label.text = message
	label.modulate = text_color
	label.add_theme_font_size_override("font_size", 40)
	label.position = spawn_pos - Vector2(50, 20)
	label.z_index = 100
	add_child(label)
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 80, 0.8).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, 0.8).set_trans(Tween.TRANS_SINE)
	tween.chain().tween_callback(label.queue_free)

func show_hint_bubble(correct_type: String, spawn_pos: Vector2):
	if not bin_textures.has(correct_type): return
	
	var bubble = ColorRect.new()
	bubble.color = Color(1, 1, 1, 0.9)
	bubble.size = Vector2(80, 80)
	bubble.position = spawn_pos + Vector2(40, -80) 
	bubble.z_index = 100
	add_child(bubble)
	
	var icon = Sprite2D.new()
	icon.texture = bin_textures[correct_type]
	icon.position = bubble.size / 2 
	icon.scale = Vector2(0.4, 0.4) 
	bubble.add_child(icon)
	
	var tween = create_tween()
	bubble.scale = Vector2(0, 0)
	tween.tween_property(bubble, "scale", Vector2(1, 1), 0.2).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_interval(1.0) 
	tween.tween_property(bubble, "modulate:a", 0.0, 0.3)
	tween.tween_callback(bubble.queue_free)
