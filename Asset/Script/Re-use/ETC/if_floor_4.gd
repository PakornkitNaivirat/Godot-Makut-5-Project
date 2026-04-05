extends Node2D
@export var stage_bgm: AudioStream 
# ==========================================
# 1. ประกาศตัวแปรทั้งหมดไว้ข้างบนสุด
# ==========================================
@onready var player = $Player
@onready var cutscene_after_lab = $cut_scene_after_lab 
@onready var cutscene_after_lab2 = $cut_scene_after_lab2

# ==========================================
# 2. ฟังก์ชัน _ready() ทำหน้าที่เป็น "ผู้จัดการใหญ่"
# คอยสั่งงานลูกน้องทีละแผนกตอนเริ่มฉาก
# ==========================================
func _ready():
	play_stage_music()
	print(Global.current_day)
	print(Global.day_night)
	print(Global.dawn)
	
	if InnerVoice:
		InnerVoice.visible = false
		
		if InnerVoice.has_method("force_skip_typing"):
			InnerVoice.force_skip_typing()
			
		if InnerVoice.get_node_or_null("Label"):
			InnerVoice.get_node("Label").text = ""
			

	setup_daily_events()
	check_and_play_cutscene()
		

func play_stage_music():
	# หาโหนด Autoload (เช็คทั้งชื่อ BGM หรือ BGMManager ตามที่คุณอาจจะตั้งไว้)
	var bgm_node = get_node_or_null("/root/BGM")
	if not bgm_node:
		bgm_node = get_node_or_null("/root/BGMManager")

	if bgm_node:
		if stage_bgm:
			# กรณีที่ 1: มีการใส่เพลงในช่อง Inspector -> ให้เล่นเพลงนั้น
			bgm_node.play_music(stage_bgm)
		else:
			# กรณีที่ 2: ช่อง Inspector ว่างเปล่า -> ให้หยุดเพลง (เงียบ)
			bgm_node.stop_music() 
	else:
		print("Warning: Autoload BGM/BGMManager not found!")

# ==========================================
# 3. แผนกจัดการ Asset (โหนดวันเวลา)
# ==========================================
func setup_daily_events():
	var today = Global.current_day
	var is_night = Global.day_night
	var is_dawn = Global.dawn
	
	var time_suffix = ""
	if is_dawn:
		time_suffix = "_Evening"    # ตอนเช้าตรู่
	elif is_night:
		time_suffix = "_Night"   # ตอนกลางคืน
	else:
		time_suffix = "_Day"     # กลางวัน
	
	var target_node_name = "Day" + str(today) + time_suffix
	
	# จัดการลบ/ซ่อนโหนด
	for node in get_children():
		if node.name.begins_with("Day"):
			if node.name != target_node_name:
				node.queue_free() # ลบทิ้งไปเลย!
			else:
				node.visible = true # อันที่ตรงเงื่อนไขให้โชว์ขึ้นมา


# ==========================================
# 4. แผนกจัดการคัตซีน
# ==========================================
func check_and_play_cutscene():

	if InnerVoice:
		InnerVoice.visible = false 

	# ---------------------------------------------------------
	# ขั้นตอนที่ 1: เช็คเงื่อนไขและ "ลบทิ้ง" คัตซีนที่ไม่ได้ใช้
	# ---------------------------------------------------------
	if Global.play_cutscene_after_lab == true:
		# ถ้าจะเล่นคัตซีน 1 -> ลบคัตซีน 2 ทิ้งเลย
		if cutscene_after_lab2:
			cutscene_after_lab2.queue_free()
			
	elif Global.play_cutscene_after_lab2 == true:
		# ถ้าจะเล่นคัตซีน 2 -> ลบคัตซีน 1 ทิ้งเลย
		if cutscene_after_lab:
			cutscene_after_lab.queue_free()
			
	else:
		# ถ้าไม่เล่นอะไรเลย -> ลบทิ้งทั้งคู่! หน้าจอจะได้สะอาด
		if cutscene_after_lab:
			cutscene_after_lab.queue_free()
		if cutscene_after_lab2:
			cutscene_after_lab2.queue_free()
			
	# ---------------------------------------------------------
	# ขั้นตอนที่ 2: ดำเนินการเล่นคัตซีนที่ "รอดชีวิต" มาได้
	# ---------------------------------------------------------
	if Global.play_cutscene_after_lab == true:
		
		# ล็อกผู้เล่นไม่ให้ขยับ
		if player:
			player.is_locked = true 
			
		Global.play_cutscene_after_lab = false
		
		# โชว์คัตซีนและเล่น
		# ใช้ is_instance_valid เพื่อความชัวร์ว่าโหนดยังไม่ถูกลบไป
		if is_instance_valid(cutscene_after_lab):
			cutscene_after_lab.visible = true
			if cutscene_after_lab.has_node("CanvasLayer"):
				cutscene_after_lab.get_node("CanvasLayer").visible = true
			
			# รอให้อนิเมชั่นเล่นจบก่อน
			await cutscene_after_lab.anim.animation_finished
			
			cutscene_after_lab.start_talking("part1")
			
	elif Global.play_cutscene_after_lab2 == true:
		
		if player:
			player.is_locked = true
			
		Global.play_cutscene_after_lab2 = false # ปิดสวิตช์ จะได้ไม่เล่นซ้ำ
		
		if is_instance_valid(cutscene_after_lab2):
			cutscene_after_lab2.visible = true
			if cutscene_after_lab2.has_node("CanvasLayer"):
				cutscene_after_lab2.get_node("CanvasLayer").visible = true
			
			# ถ้่ามี Animation ชื่อ anim ก็ให้รอเล่นให้จบก่อน
			var anim_node = cutscene_after_lab2.get_node_or_null("AnimationPlayer")
			if anim_node:
				await anim_node.animation_finished
			# เริ่มบทพูด
			cutscene_after_lab2.start_talking("part2")
