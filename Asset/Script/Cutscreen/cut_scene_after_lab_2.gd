extends CanvasLayer

@export var next_scene_path: String = ""
@export var target_spawn_point_name: String = "" 

@onready var anim = $AnimationPlayer
@onready var speech_bubble = $speech 

#Set บทพูด
var all_dialogues = {
	"part1": [
		{"speaker": "Narrator", "text": "After reading and replying to the messages,"},
		{"speaker": "Narrator", "text": "his friend standing nearby spoke up."},
		{"speaker": "B", "text": "Heh... looks like that 'good luck' I gave you earlier actually worked!"},
		{"speaker": "Me", "text": "Yeah, I really lucked out. I almost didn't make it in"},
		{"speaker": "B", "text": "But only two people joined, huh?"},
		{"speaker": "G", "text": "Well, outdoor activities and conservation work aren't exactly everyone's cup of tea."},
		{"speaker": "Narrator", "text": "The three of them chatted about what happened for a bit"},
		{"speaker": "B", "text": "Alright!! Now that your club situation is settled, let’s head to the cafe!!"},
		{"speaker": "G", "text": "You guys leaving already? You’re not even gonna eat first?"},
		{"speaker": "B", "text": "That’s not necessary!! \nWe can just find something to eat at the cafe"},
		{"speaker": "G", "text": "Fair enough. I guess grabbing a bite at the cafe isn't a bad idea."},
		{"speaker": "B", "text": "Alright then, let’s go!!"},
	],
	"part2": [
		{"speaker": "Narrator", "text": "As soon as the words were out, his friend dashed toward the elevator."},
		{"speaker": "G", "text": "That guy is a bit too hyper, don't you think?"},
		{"speaker": "Me", "text": "I think so..."},
		{"speaker": "Me", "text": "But since it’s come to this, I might as well just go with the flow."},
	],
	"part3": [
		{"speaker": "Narrator", "text": "He and his other friend quickly followed."},
	],
}

var current_dialogue_block: Array = []
var current_line = 0
var is_talking = false

func _ready():
	anim.play("part2")

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
			speech_bubble.force_skip_typing()
			
		elif is_inner_typing:
			InnerVoice.force_skip_typing()
			
		else:
			# ถ้าตัวหนังสือขึ้นเต็มแล้ว ค่อยบวกบรรทัดใหม่
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
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.is_locked = false 
		
	# 2. ปิด UI ข้อความทั้งหมด
	speech_bubble.hide_dialogue()
	InnerVoice.hide_text()
	is_talking = false
	self.visible = false
	
	Global.load_exact_pos = false 
	Global.target_spawn_name = target_spawn_point_name
	
	if next_scene_path != "":
		LoadingScreen.transition_to_screenfunc(next_scene_path)
	
	
