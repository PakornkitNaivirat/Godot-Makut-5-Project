extends Node2D

@export var next_scene_path: String = ""
@export var target_spawn_point_name: String = "" 

@onready var black = $ColorRect
@onready var anim = $AnimationPlayer

var current_dialogue_block: Array = []
var current_line = 0
var is_talking = false

# 🌟 เพิ่มบทพูดได้ตามสบายเลย
var all_dialogues = {
	"part1": [
		{"speaker": "Narrator", "text": "On the morning of the meeting day, I woke up feeling a bit of a thrill"},
		{"speaker": "Narrator", "text": "Even though the market doesn't open until the evening,"},
		{"speaker": "Narrator", "text": "I found myself unable to do much besides lounge on my bed"},
		{"speaker": "Narrator", "text": "or find little things to do just to kill time."},
	],
	"part2": [
		{"speaker": "Narrator", "text": "......."},
		{"speaker": "Narrator", "text": "As the hours ticked by and the meeting time approached,"},
		{"speaker": "Narrator", "text": " I gotta ready and headed out to Park In Market."},
	],
}

func _ready():
	black.visible = true
	anim.play("chilling")

func start_talking(dialogue_key: String):
	anim.pause()
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
				is_talking = false
				InnerVoice.hide_text()
				anim.play()
				
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
