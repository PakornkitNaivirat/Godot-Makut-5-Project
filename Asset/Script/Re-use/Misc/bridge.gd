extends Node2D

# ==========================================
# 1. ตั้งค่าการเปลี่ยนฉาก
# ==========================================
@export var next_scene_path: String = ""
@export var target_spawn_point_name: String = ""

@onready var anim = $AnimationPlayer 
@onready var player = $Player # 🌟 อ้างอิง Player ตรงๆ เพื่อให้ล็อกตัวละครได้ชัวร์ๆ

# ==========================================
# 2. ข้อมูลบทพูด (เสียงในใจ)
# ==========================================
var current_dialogue_block: Array = []
var current_line = 0
var is_talking = false

var all_dialogues = {
	"part1": [
		{"speaker": "Narrator", "text": "I walked aimlessly until I reached a bridge. I crossed it slowly"},
		{"speaker": "Narrator", "text": "(Why did we have to see each other that day?)"},
		{"speaker": "Narrator", "text": "(Why was I in such a rush to say it?)"},
		{"speaker": "Narrator", "text": "(Why didn't I think it through or ask hermore before opening my heart?)"},
		{"speaker": "Narrator", "text": "(Why did I say it out loud when I knew it might end in pain?)"},
		{"speaker": "Narrator", "text": "(My head was spinning with questions.)"},
		{"speaker": "Narrator", "text": "(I reached the end of the bridge where no one else was around.)"},
		{"speaker": "Narrator", "text": "(Why did I say it out loud when I knew it might end in pain?)"},
		
	]
}

# ==========================================
# 3. เริ่มฉาก
# ==========================================
func _ready():
	if InnerVoice: InnerVoice.hide_text()

	# 🌟 ล็อกตัวละคร
	if player:
		player.set_physics_process(false) 
		player.set_process(false)
		player.set_process_input(false)
		player.set_process_unhandled_input(false)
		if "is_locked" in player:
			player.is_locked = true 

	await get_tree().create_timer(1.0).timeout
	
	if anim:
		anim.play("Walk_slow")
		
	start_talking("part1")

# ==========================================
# 4. ฟังก์ชันจัดการบทพูดแบบเล่นอัตโนมัติ (Auto-Play)
# ==========================================
func start_talking(dialogue_key: String):
	current_dialogue_block = all_dialogues[dialogue_key]
	is_talking = true
	current_line = 0
	play_auto_dialogue() # 🌟 เรียกใช้ระบบรันข้อความอัตโนมัติแทน

# 🌟 ฟังก์ชันใหม่: รันข้อความเองตามเวลา ไม่ต้องง้อปุ่มกด
func play_auto_dialogue():
	for i in range(current_dialogue_block.size()):
		current_line = i
		update_dialogue()
		
		# คำนวณเวลาที่จะให้แสดงข้อความค้างไว้ อิงจากความยาวของประโยค
		# (ตัวอักษรละ 0.05 วิ + เวลาให้อ่านเผื่ออีก 2 วิ)
		var text_length = current_dialogue_block[i]["text"].length()
		var delay_time = (text_length * 0.02) + 2.0 
		
		# ระบบจะหยุดรอตามเวลา delay_time ก่อนจะวนลูปไปบรรทัดถัดไป
		await get_tree().create_timer(delay_time).timeout
		
	# พอวนลูปแสดงข้อความครบทุกประโยค ก็ปิดกล่องข้อความ
	end_talking()

# ==========================================
# 5. อัปเดตหน้าตา UI ข้อความ 
# ==========================================
func update_dialogue():
	var line_data = current_dialogue_block[current_line]
	var text_content = line_data["text"]
	
	var has_next_narrator = false
	if current_line + 1 < current_dialogue_block.size():
		if current_dialogue_block[current_line + 1]["speaker"] == "Narrator":
			has_next_narrator = true
	
	if InnerVoice:
		if has_next_narrator:
			InnerVoice.speak(text_content, false) 
		else:
			InnerVoice.speak(text_content, true) 

# ==========================================
# 6. จบบทสนทนา
# ==========================================
func end_talking():
	is_talking = false
	if InnerVoice: InnerVoice.hide_text()

# ==========================================
# 7. เปลี่ยนด่าน
# ==========================================
func finish_cutscene():
	if player:
		player.set_physics_process(true)
		player.set_process(true)
		player.set_process_input(true)
		player.set_process_unhandled_input(true)
		if "is_locked" in player:
			player.is_locked = false 
		
	Global.load_exact_pos = false 
	Global.target_spawn_name = target_spawn_point_name
	
	if next_scene_path != "":
		LoadingScreen.transition_to_screenfunc(next_scene_path)
