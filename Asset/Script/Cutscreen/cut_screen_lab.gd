extends Node2D

@export var next_scene_path: String = ""
@export var target_spawn_point_name: String = "" 

@onready var anim = $AnimationPlayer
@onready var speech_bubble = $speech 

#Set บทพูด
var all_dialogues = {
	"part1": [
		{"speaker": "Friend", "text": "Hey… you look way too focused."},
		{"speaker": "Narrator", "text": "I flinched a little when someone tapped my shoulder."},
		{"speaker": "Narrator", "text": "But when I turned around, it was just my best friend."},
		{"speaker": "Me", "text": "Since when do you get here!?"},
		{"speaker": "Friend2", "text": "About… one minute, twelve seconds, and thirty-two milliseconds ago."},
		{"speaker": "Me2", "text": "Why are you being so specific?!"},
		{"speaker": "Friend", "text": "Hey, relax—it was just a joke."},
		{"speaker": "Friend", "text": "Anyway… did you end up signing up for the club?"},
		{"speaker": "Friend", "text": "Yesterday was the last day, right?"},
		{"speaker": "Narrator", "text": "I let out a small sigh."},
		{"speaker": "Me2", "text": "Uh… I mean, it said applications were open until 6 p.m., right?"},
		{"speaker": "Me2", "text": "But I submitted mine around 3…"},
		{"speaker": "Me2", "text": "and only realized afterward that the deadline had already passed."},
		{"speaker": "Me2", "text": "Now I’m kinda worried I won’t get in."},
		{"speaker": "Narrator", "text": "My friend looked at me, confused."},
		{"speaker": "Friend", "text": "Dude… why didn’t you double-check first?"},
		{"speaker": "Me2", "text": "Heh… I was planning to sign up right away,"},
		{"speaker": "Me2", "text": "but I got caught up doing something and kinda lost track of time."},
		{"speaker": "Me2", "text": "By the time I remembered, I had already finished everything…"},
		{"speaker": "Friend2", "text": "Well… I hope the application you sent still counts. Good luck."},
	],
	"part2": [
		{"speaker": "Narrator", "text": "The lab session started, and the room quickly filled with a lively atmosphere."},
		{"speaker": "Narrator", "text": "Some students looked stressed out, though—probably stuck on certain problems."},
		{"speaker": "Narrator", "text": "Even so, I managed to finish all the assigned tasks"},
		{"speaker": "Narrator", "text": "within the time limit without too much trouble"},
		{"speaker": "Narrator", "text": "thanks to the review I’d done earlier."},
		{"speaker": "Narrator", "text": "With time to spare, I went around helping a few classmates with their code,"},
		{"speaker": "Narrator", "text": "offering tips here and there… until the session finally came to an end."},
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
		
		var is_speech_typing = speech_bubble.visible and speech_bubble.label.visible_ratio < 0.99
		var is_inner_typing = InnerVoice.visible and InnerVoice.is_typing()
		
		if is_speech_typing:
			speech_bubble.force_skip_typing() # เร่งกล่องข้อความ
			
		elif is_inner_typing:
			InnerVoice.force_skip_typing() # เร่งบทบรรยาย
			
		else:

			current_line += 1
			
			if current_line < current_dialogue_block.size():
				update_dialogue()
			else:
				is_talking = false
				speech_bubble.hide_dialogue()
				InnerVoice.hide_text()
				anim.play()

func update_dialogue():
	var line_data = current_dialogue_block[current_line]
	var target_node_name = line_data["speaker"] 
	var text_content = line_data["text"]
	var spot_node = get_node_or_null(target_node_name)
	
	if target_node_name == "Narrator":
		speech_bubble.hide_dialogue() # ซ่อนกล่องคำพูดปกติ
		InnerVoice.speak(text_content) # ส่งข้อความไปให้เสียงในใจโชว์
		
	elif target_node_name != "Narrator":
		
		InnerVoice.hide_text() # ซ่อนเสียงในใจ (เผื่อประโยคก่อนหน้าเป็นบทบรรยาย)
		
		if spot_node:
			speech_bubble.global_position = spot_node.global_position
			
		speech_bubble.show_dialogue(text_content) # โชว์กล่องคำพูดปกติ

func finish_cutscene():
	
	Global.play_cutscene_after_lab = true
	InnerVoice.hide_text()
	Global.dawn = true
	Global.load_exact_pos = false 
	Global.target_spawn_name = target_spawn_point_name
	
	if next_scene_path != "":
		LoadingScreen.transition_to_screenfunc(next_scene_path)
