extends Node2D
@export var stage_bgm: AudioStream 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
