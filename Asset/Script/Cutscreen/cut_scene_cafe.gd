extends Node2D

@export var next_scene_path: String = ""
@export var target_spawn_point_name: String = "" 

@onready var anim = $AnimationPlayer
@onready var speech_bubble = $speech 

#Set บทพูด
var all_dialogues = {
	"part1": [
		{"speaker": "Narrator", "text": "He and his friends arrived at the shop on a motorcycle"},
	],
}

var current_dialogue_block: Array = []
var current_line = 0
var is_talking = false

func _ready():
	anim.play("Pain2")

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
	
	
