extends Node2D

@export var next_scene_path: String = ""
@export var target_spawn_point_name: String = "" 

#@onready var anim = $AnimationPlayer
@onready var speech_bubble = $speech 

@onready var pos_left = $PosLeft
@onready var pos_right = $PosRight

var cutscene_dialogue: Array[Dictionary] = [
	{"speaker": "friend", "text": "แม่: ตื่นได้แล้วลูก! สายแล้วนะ!"},
	{"speaker": "player", "text": "คุณ: งืมมม... ขออีก 5 นาทีครับแม่..."},
	{"speaker": "friend", "text": "ไม่ได้! ลุกไปล้างหน้าเดี๋ยวนี้เลย!"}
]

var current_line = 0
var is_talking = false

#func _ready():
	#anim.play("Cutscreen")

func _ready():
	# 🌟 พอเปิดฉากปุ๊บ สั่งให้เริ่มพูดทันทีเลย!
	start_talking()


func start_talking():
	is_talking = true
	current_line = 0
	update_dialogue() 

func _process(_delta):
	if is_talking and Input.is_action_just_pressed("interact"):
		current_line += 1
		
		if current_line < cutscene_dialogue.size():
			update_dialogue()
		else:
			is_talking = false
			speech_bubble.hide_dialogue()
			finish_cutscene()


func update_dialogue():
	var line_data = cutscene_dialogue[current_line]
	

	if line_data["speaker"] == "player":
		speech_bubble.global_position = pos_left.global_position
	elif line_data["speaker"] == "friend":
		speech_bubble.global_position = pos_right.global_position
		

	speech_bubble.show_dialogue(line_data["text"])

func finish_cutscene():
	print("คัตซีนจบแล้ว กำลังเปลี่ยนฉากกลับ...")
	
	Global.event_flags["washed_face"] = true 
	Global.load_exact_pos = false 
	Global.target_spawn_name = target_spawn_point_name
	
	if next_scene_path != "":
		LoadingScreen.transition_to_screenfunc(next_scene_path)
