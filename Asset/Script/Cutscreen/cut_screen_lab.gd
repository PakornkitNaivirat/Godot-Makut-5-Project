extends Node2D

@export var next_scene_path: String = ""
@export var target_spawn_point_name: String = "" 

@onready var anim = $AnimationPlayer
@onready var speech_bubble = $speech 

#Set บทพูด
var all_dialogues = {
	"part1": [
		{"speaker": "Friend", "text": "Hey… you look way too focused."},
		{"speaker": "Me", "text": "Since when do you get here!?"},
		{"speaker": "Friend2", "text": "About… one minute, twelve seconds, and thirty-two milliseconds ago."},
		{"speaker": "Me2", "text": "Why are you being so specific?!"},
		{"speaker": "Friend", "text": "Hey, relax—it was just a joke."},
		{"speaker": "Friend", "text": "Anyway… did you end up signing up for the club?"},
		{"speaker": "Friend", "text": "Yesterday was the last day, right?"},
		{"speaker": "Me2", "text": "Uh… I mean, it said applications were open until 6 p.m., right?"},
		{"speaker": "Me2", "text": "But I submitted mine around 3…"},
		{"speaker": "Me2", "text": "and only realized afterward that the deadline had already passed."},
		{"speaker": "Me2", "text": "Now I’m kinda worried I won’t get in."},
		{"speaker": "Friend", "text": "Dude… why didn’t you double-check first?"},
		{"speaker": "Me2", "text": "Heh… I was planning to sign up right away,"},
		{"speaker": "Me2", "text": "but I got caught up doing something and kinda lost track of time."},
		{"speaker": "Me2", "text": "By the time I remembered, I had already finished everything…"},
		{"speaker": "Friend2", "text": "Well… I hope the application you sent still counts. Good luck."},
	],
	
}

var current_dialogue_block: Array = []
var current_line = 0
var is_talking = false

func _ready():
	anim.play("Lab")

func start_talking(dialogue_key: String):
	anim.pause()
	
	#Check ว่า Part ตรงกับ Part ปัจจุบันไหม
	current_dialogue_block = all_dialogues[dialogue_key]
	
	is_talking = true
	current_line = 0
	update_dialogue() 

func _process(_delta):
	if is_talking and Input.is_action_just_pressed("interact"):
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
