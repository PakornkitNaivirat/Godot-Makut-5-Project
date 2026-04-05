extends Node2D

@export var next_scene_path: String = ""
@export var target_spawn_point_name: String = "" 

var current_dialogue_block: Array = []
var current_line = 0
var is_talking = false

# 🌟 เพิ่มบทพูดได้ตามสบายเลย
var all_dialogues = {
	"part1": [
		{"speaker": "Narrator", "text": "On the appointed day, I arrived at Bang Saen Beach in the morning as scheduled."},
		{"speaker": "Narrator", "text": "Everyone should be here now"},
		{"speaker": "Narrator", "text": "I should go check at seashore"},
	],
}

func _ready():
	var player = get_tree().get_first_node_in_group("player")
	print(Global.current_day == 4)
	print(Global.day_night)
	 
	if Global.current_day == 4 and Global.day_night == false:
		if player:
			player.is_locked = true
		
	if InnerVoice:
		InnerVoice.hide_text()
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
	
	# 🌟 เช็คว่า "ประโยคต่อไป" ยังเป็น Narrator อยู่ไหม? (แอบดูล่วงหน้า 1 บรรทัด)
	var next_is_narrator = false
	if current_line + 1 < current_dialogue_block.size():
		if current_dialogue_block[current_line + 1]["speaker"] == "Narrator":
			next_is_narrator = true

	if target_node_name == "Narrator":
		InnerVoice.speak(text_content, false) 
	else:
		InnerVoice.hide_text() 

func finish_cutscene():
	# ปลดล็อกผู้เล่น
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.is_locked = false 
		
	# 🌟 พอจบ Cutscene เราค่อยสั่งปิด UI แบบบังคับปิด (จอดำและข้อความจะหายไปพร้อมกันแบบนุ่มนวล)
	InnerVoice.hide_text()
	is_talking = false
	
	Global.load_exact_pos = false 
	Global.target_spawn_name = target_spawn_point_name
	
	if next_scene_path != "":
		LoadingScreen.transition_to_screenfunc(next_scene_path)
