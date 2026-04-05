extends Node2D

@export var arrow_scene : PackedScene
@onready var timer_label = $CanvasLayer/Label 

var time_left : float = 30.0
var score_to_win : int = 15
var current_score : int = 0
var game_over : bool = false

var directions = ["W", "A", "S", "D"]

# --- [ส่วนที่พี่ต้องมีเพื่อให้หายแดง] ---
var arrow_colors = {
	"W": Color.CYAN,
	"A": Color.YELLOW,
	"S": Color.GREEN,
	"D": Color.MAGENTA
}

var arrow_textures = {
	"W": "res://Asset/Spirte/Prop/Arrow/arrow_up.png",
	"A": "res://Asset/Spirte/Prop/Arrow/arrow_left.png",
	"S": "res://Asset/Spirte/Prop/Arrow/arrow_down.png",
	"D": "res://Asset/Spirte/Prop/Arrow/arrow_right.png"
}

func _ready():
	randomize()
	var spawn_timer = Timer.new()
	spawn_timer.wait_time = 0.8 
	spawn_timer.autostart = true
	spawn_timer.timeout.connect(_spawn_arrow)
	add_child(spawn_timer)
	update_ui_display()

func _process(delta):
	if not game_over:
		time_left -= delta
		update_ui_display()
		if time_left <= 0: _on_game_over()
		if current_score >= score_to_win: _on_win()

func update_ui_display():
	if timer_label:
		timer_label.text = "เวลา: %.2f | คะแนน: %d/%d" % [time_left, current_score, score_to_win]

func _spawn_arrow():
	if game_over: return
	var a = arrow_scene.instantiate()
	var dir = directions[randi() % directions.size()]
	a.direction = dir
	
	# พิกัดเกิด (ล่างจอ)
	a.position = Vector2(randf_range(300, 800), 700)
	
	# --- แก้ขนาดตรงนี้ ---
	# ถ้าลูกศรยังเล็กไป ให้เปลี่ยนจาก 1.5 เป็น 2.0 หรือ 3.0 จนกว่าจะพอใจครับ
	a.scale = Vector2(1.5, 1.5) 
	
	if a.has_node("Sprite2D"):
		var sprite = a.get_node("Sprite2D")
		if arrow_textures.has(dir):
			sprite.texture = load(arrow_textures[dir])
			# ใส่สีให้ตรงทิศทาง (Cyan, Yellow, Green, Magenta)
			if arrow_colors.has(dir):
				sprite.modulate = arrow_colors[dir]
	
	add_child(a)

func _input(event):
	if game_over: return
	if event.is_action_pressed(""): _check_hit("W")
	elif event.is_action_pressed("a"): _check_hit("A")
	elif event.is_action_pressed("s"): _check_hit("S")
	elif event.is_action_pressed("d"): _check_hit("D")

func _check_hit(pressed_dir):
	var hit = false
	var target_y = 100 # ตำแหน่งเส้นชัย
	var margin = 80 
	for arrow in get_tree().get_nodes_in_group("arrows"):
		if arrow.direction == pressed_dir:
			if abs(arrow.position.y - target_y) < margin:
				hit = true
				current_score += 1
				arrow.queue_free()
				_play_target_bounce()
				_flash_label(Color.GREEN)
				break
	if not hit:
		time_left -= 0.5
		_flash_label(Color.RED)

func _play_target_bounce():
	var target = get_node_or_null("TargetZone/Sprite2D")
	if target:
		var st = create_tween()
		st.tween_property(target, "scale", Vector2(1.2, 1.2), 0.05)
		st.tween_property(target, "scale", Vector2(1.0, 1.0), 0.05)

func _flash_label(flash_color):
	if timer_label:
		timer_label.modulate = flash_color
		var t = create_tween()
		t.tween_property(timer_label, "modulate", Color.WHITE, 0.2)

func _on_win():
	game_over = true
	timer_label.text = "WIN!"
	await get_tree().create_timer(2.0).timeout
	get_tree().quit()

func _on_game_over():
	game_over = true
	timer_label.text = "GAME OVER!"
	await get_tree().create_timer(1.5).timeout
	get_tree().quit()
