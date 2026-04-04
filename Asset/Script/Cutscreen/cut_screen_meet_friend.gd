extends Node2D

@export var next_scene_path: String = ""
@export var target_spawn_point_name: String = "" 

@onready var anim = $AnimationPlayer
@onready var speech_bubble = $speech 

#Set บทพูด
var all_dialogues = {
	"part1": [
		{"speaker": "Friend_A", "text": "Ahh, finally it's over."},
		{"speaker": "Friend_A", "text": "I barely understood anything from the lecture."},
		{"speaker": "Player_A", "text": "Dude, you were nodding off the whole time."},
		{"speaker": "Friend_A", "text": "Well, it was hard, okay?!"},
		{"speaker": "Player_A", "text": "Yeah, yeah~"},
	],
	"part2": [
		{"speaker": "Player_A2", "text": "Huh… what’s this?"},
		{"speaker": "Friend_A2", "text": "Oh, that’s the Marine Conservation Club."},
		{"speaker": "Player_A2", "text": "Marine Conservation Club?"},
		{"speaker": "Friend_A2", "text": "Yeah. They do activities related to protecting the ocean."},
		{"speaker": "Friend_A2", "text": "Sometimes they organize stuff like beach clean-ups and things like that."},
		{"speaker": "Friend_A2", "text": "I figured it might suit you."},
		{"speaker": "Player_A2", "text": "Really? Then I guess I’ll give it a shot. Doesn’t hurt to try."},
	],
	"part3": [
		{"speaker": "Friend_A3", "text": "Hey!! Don’t forget we promised to go to the café together after class."},
		{"speaker": "Player_A3", "text": "Don’t worry, I won’t."},
	]
}

var current_dialogue_block: Array = []
var current_line = 0
var is_talking = false

func _ready():
	anim.play("Lecture")

func start_talking(dialogue_key: String):
	anim.pause()
	
	#Check ว่า Part ตรงกับ Part ปัจจุบันไหม
	current_dialogue_block = all_dialogues[dialogue_key]
	
	is_talking = true
	current_line = 0
	update_dialogue() 

func _process(_delta):
	if is_talking and Input.is_action_just_pressed("interact"):
		# 1. เช็คก่อนว่า Speech Bubble กำลังพิมพ์อยู่ไหม?
		if speech_bubble.is_typing():
			speech_bubble.force_skip_typing()
		else:
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
	
	Global.day_night = true
	Global.load_exact_pos = false 
	Global.target_spawn_name = target_spawn_point_name
	
	if next_scene_path != "":
		LoadingScreen.transition_to_screenfunc(next_scene_path)
