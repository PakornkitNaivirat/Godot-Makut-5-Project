extends Node2D


# ==========================================
# 1. ตั้งค่าตัวแปรอ้างอิง (แก้ไขชื่อ Node ให้ตรงกับของคุณ)
# ==========================================
@export var next_scene_path: String = ""
@export var target_spawn_point_name: String = ""

# อ้างอิง AnimationPlayer
@onready var anim = $AnimationPlayer # หรือ $Day4_Evening/Player

# อ้างอิงระบบข้อความแบบปกติ (เผื่อใช้)
@onready var speech_bubble = get_node_or_null("speech")
@onready var markers = {
	"me": get_node_or_null("Me"),
	"rin": get_node_or_null("Rin")
}

# ==========================================
# 2. ข้อมูลบทพูด
# ==========================================
var current_dialogue_block: Array = []
var current_line = 0
var is_talking = false

# 🌟 เพิ่ม/ลด บทพูดได้ตรงนี้เลย
var all_dialogues = {
	"part1": [
		{"speaker": "Narrator", "text": "I sat there for a long time before eventually pulling myself back together."},
		{"speaker": "Narrator", "text": "(But regardless of what happens, life has to go on, right?)"},
	],
}

# ==========================================
# 3. เริ่มฉาก
# ==========================================
func _ready():
	
	if InnerVoice: InnerVoice.hide_text()
	if speech_bubble: speech_bubble.hide()

	# รอ 1 วินาที (เพื่อให้จอดำเฟดสว่างก่อน หรือให้คนเล่นตั้งตัว)
	await get_tree().create_timer(1.0).timeout
	
	# เริ่มเล่น Animation ผู้กำกับ
	if anim:
		anim.play("THE_END")

# ==========================================
# 4. ถูกเรียกจาก AnimationPlayer เพื่อ "เริ่มคุย"
# ==========================================
func start_talking(dialogue_key: String):
	if anim:
		anim.pause()
		
	current_dialogue_block = all_dialogues[dialogue_key]
	is_talking = true
	current_line = 0
	update_dialogue() 

# ==========================================
# 5. ระบบกดอ่านข้อความ (Loop)
# ==========================================
func _process(_delta):
	if is_talking and Input.is_action_just_pressed("interact"):
		
		var is_inner_typing = InnerVoice and InnerVoice.visible and InnerVoice.is_typing()
		var is_speech_typing = speech_bubble and speech_bubble.visible and speech_bubble.label.visible_ratio < 0.99
		
		# ถ้ายึกยืออยู่ ให้เร่งให้เต็ม
		if is_inner_typing:
			InnerVoice.force_skip_typing()
		elif is_speech_typing:
			speech_bubble.force_skip_typing()
		else:
			# ถ้าข้อความเต็มแล้ว ให้ไปบรรทัดถัดไป
			current_line += 1
			
			if current_line < current_dialogue_block.size():
				update_dialogue()
			else:
				# 🌟 พอพูดจบพาร์ทนี้ ให้ซ่อนข้อความแล้ว "เล่น Animation ต่อ"
				end_talking()
				
# ==========================================
# 6. อัปเดตหน้าตา UI ข้อความ
# ==========================================
func update_dialogue():
	var line_data = current_dialogue_block[current_line]
	var target_node_name = line_data["speaker"] 
	var text_content = line_data["text"]
	
	# 🌟 แอบดูล่วงหน้า 1 บรรทัด ว่าประโยคต่อไปยังเป็น "Narrator" อยู่ไหม?
	var has_next_narrator = false
	if current_line + 1 < current_dialogue_block.size():
		if current_dialogue_block[current_line + 1]["speaker"] == "Narrator":
			has_next_narrator = true
	
	# แยกแสดงผลระหว่าง เสียงในใจ (Narrator) กับ คำพูดปกติ
	if target_node_name == "Narrator":
		if speech_bubble: speech_bubble.hide_dialogue()
		
		if InnerVoice:
			if has_next_narrator:
				InnerVoice.speak(text_content, false) 
			else:
				InnerVoice.speak(text_content, true) 
				
	else:
		# ถ้าเป็นคำพูดปกติของตัวละคร
		if InnerVoice: InnerVoice.hide_text() # ซ่อนฉากหลังของเสียงในใจ
		
		if speech_bubble and markers.has(target_node_name.to_lower()):
			speech_bubble.global_position = markers[target_node_name.to_lower()].global_position
			speech_bubble.show()
			speech_bubble.show_dialogue(text_content)

# ==========================================
# 7. จบบทสนทนา (พาร์ทนั้นๆ)
# ==========================================
func end_talking():
	is_talking = false
	if InnerVoice: InnerVoice.hide_text()
	if speech_bubble: speech_bubble.hide_dialogue()
	
	if anim:
		anim.play() # 🌟 สั่งให้ Animation ที่เรา Pause ไว้ เล่นต่อไป!

# ==========================================
# 8. จบ Cutscene และเปลี่ยนด่าน (โดนเรียกที่เฟรมสุดท้ายของ Animation)
# ==========================================
func finish_cutscene():
		
	# เปลี่ยนด่าน
	Global.load_exact_pos = false 
	Global.target_spawn_name = target_spawn_point_name
	
	if next_scene_path != "":
		LoadingScreen.transition_to_screenfunc(next_scene_path)
