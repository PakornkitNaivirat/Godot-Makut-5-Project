extends Node2D

@export var trash_scene : PackedScene 
@onready var timer_label = $CanvasLayer/TimerLabel

var time_left : float = 20.0 
var game_over : bool = false
var is_won : bool = false

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
			_on_game_over("เวลาหมด!")
		
		check_win_condition()

func spawn_random_trash(count):
	for i in range(count):
		var new_trash = trash_scene.instantiate()
		var data = trash_data[randi() % trash_data.size()]
		new_trash.trash_type = data["type"]
		new_trash.add_to_group("current_trash")
		new_trash.position = Vector2(randf_range(150, 1000), randf_range(80, 250))
		new_trash.placed_wrong.connect(_on_wrong_trash)
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
	
	await get_tree().create_timer(3.0).timeout
	
	get_tree().quit() 

func _on_wrong_trash():
	if not game_over and not is_won:
		time_left -= 3.0
		timer_label.modulate = Color.RED
		await get_tree().create_timer(0.2).timeout
		if not is_won: timer_label.modulate = Color.WHITE

func update_timer_display():
	if timer_label:
		timer_label.text = ("%.2f" % time_left)

func _on_game_over(reason):
	if game_over or is_won: return 
	game_over = true
	timer_label.modulate = Color.RED
	timer_label.text = "GAME OVER!"
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://Asset/Screen/BG/Minigames/beach_game.tscn")
