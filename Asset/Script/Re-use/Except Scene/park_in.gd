extends Node2D
@export var stage_bgm: AudioStream 
@onready var takoyaki_node = $Takoyaki

func _ready():
	play_stage_music()
	
	print(Global.minigame_status["takoyaki"])
	setup_events()
	
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
	
func setup_events():
	var check = Global.minigame_status["takoyaki"]
	
	if takoyaki_node:
		
		if check == true:
			takoyaki_node.visible = check
		else :
			takoyaki_node.queue_free()
