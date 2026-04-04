extends Node2D

@export var next_scene_path: String = ""
@export var target_spawn_point_name: String = "" 

@onready var black = $ColorRect

var current_dialogue_block: Array = []
var current_line = 0
var is_talking = false

# 🌟 เพิ่มบทพูดได้ตามสบายเลย
var all_dialogues = {
	"part1": [
		{"speaker": "Narrator", "text": "After getting back, he showered, did his homework, "},
		{"speaker": "Narrator", "text": " reviewed his lessons, and wound down for the night."},
		{"speaker": "Narrator", "text": "getting ready for bed, a notification sounded from his phone."},
		{"speaker": "Narrator", "text": "Hmm? From the club group?"},
	],
}

func _ready():
	black.visible = true
	
	var player = get_tree().get_first_node_in_group("player")
	 
	if Global.current_day == 2 and Global.day_night == true:
		if player:
			player.is_locked = true
		
	#if InnerVoice:
		#InnerVoice.hide_text()
	await get_tree().create_timer(1.0).timeout
		
	start_talking("part1")

func start_talking(dialogue_key: String):
	current_dialogue_block = all_dialogues[dialogue_key]
	is_talking = true
	current_line = 0
	update_dialogue() 

func _process(_delta):
	if is_talking and Input.is_action_just_pressed("interact"):

		var is_inner_typing = InnerVoice.visible and InnerVoice.is_typing()
		
		if is_inner_typing:
			InnerVoice.force_skip_typing()
		else:
			current_line += 1
			
			if current_line < current_dialogue_block.size():
				update_dialogue()
			else:
				# 🌟 พอพูดครบทุกประโยค ให้เรียกฟังก์ชันจบเพื่อปลดล็อกผู้เล่น!
				finish_cutscene()
				
func update_dialogue():
	var line_data = current_dialogue_block[current_line]
	var target_node_name = line_data["speaker"] 
	var text_content = line_data["text"]
	
	if target_node_name == "Narrator":
		InnerVoice.speak(text_content) 
	else:
		InnerVoice.hide_text() 

func finish_cutscene():
	# ปลดล็อกผู้เล่น
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.is_locked = false 
		
	# ปิด UI ข้อความ
	InnerVoice.hide_text()
	is_talking = false
	
	Global.load_exact_pos = false 
	Global.target_spawn_name = target_spawn_point_name
	
	if next_scene_path != "":
		LoadingScreen.transition_to_screenfunc(next_scene_path)
