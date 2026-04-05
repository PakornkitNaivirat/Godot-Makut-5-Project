extends Node2D

@export var stage_bgm: AudioStream 
@onready var anim = $AnimationPlayer
@export var next_scene_path: String = ""

func _ready():
	anim.play("Concert")
	play_stage_music()

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

func finish_cutscene():
	
	Global.load_exact_pos = false 
	Global.day_night = true
	
	if next_scene_path != "":
		LoadingScreen.transition_to_screenfunc(next_scene_path)
