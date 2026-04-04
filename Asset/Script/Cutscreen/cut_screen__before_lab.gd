extends Node2D

@export var next_scene_path: String = ""
@export var target_spawn_point_name: String = "" 

@onready var anim = $AnimationPlayer
@onready var speech_bubble = $speech 

#Set บทพูด
var all_dialogues = {
	"part1": [
		{"speaker": "right", "text": "(I hope I get in, even if I sent the form past the deadline.)"},
		{"speaker": "right", "text": "(But hey!! If the form was still open for submission.)"},
		{"speaker": "right", "text": "(it must mean they’re still accepting people. That has to be it!!.)"},
		{"speaker": "left", "text": "(Anyway… no use worrying about it now.)"},
		{"speaker": "left", "text": "(I should just focus on class.)"},
		{"speaker": "left", "text": "(Today’s lab is on the fourth floor, so I’ll head up now.)"},
		
	],
	
}

var current_dialogue_block: Array = []
var current_line = 0
var is_talking = false

func _ready():
	anim.play("Lift")

func start_talking(dialogue_key: String):
	anim.pause()
	
	#Check ว่า Part ตรงกับ Part ปัจจุบันไหม
	current_dialogue_block = all_dialogues[dialogue_key]
	
	is_talking = true
	current_line = 0
	update_dialogue() 

func _process(_delta):
	if is_talking and Input.is_action_just_pressed("interact"):
		# เช็คก่อนว่ากำลังพิมพ์ตัวหนังสืออยู่ไหม?
		if speech_bubble.is_typing():
			# ถ้ากำลังพิมพ์ -> กดแล้วให้แสดงข้อความทั้งหมดทันที (Skip)
			speech_bubble.force_skip_typing()
		else:
			# ถ้าพิมพ์จบแล้ว -> กดแล้วเปลี่ยนประโยคต่อไป
			current_line += 1
			
			if current_line < current_dialogue_block.size():
				update_dialogue()
			else:
				is_talking = false
				speech_bubble.hide_dialogue()
				anim.play()

func update_dialogue():
	var line_data = current_dialogue_block[current_line]
	var target_node_name = line_data["speaker"] 
	var spot_node = get_node_or_null(target_node_name)
	
	if spot_node:
		speech_bubble.global_position = spot_node.global_position
		
	speech_bubble.show_dialogue(line_data["text"])

func finish_cutscene():
	
	Global.load_exact_pos = false 
	Global.target_spawn_name = target_spawn_point_name
	
	if next_scene_path != "":
		LoadingScreen.transition_to_screenfunc(next_scene_path)
