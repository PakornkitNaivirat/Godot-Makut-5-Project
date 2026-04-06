extends Node2D

@export var stage_bgm: AudioStream 

func _ready():
	play_stage_music()
	setup_daily_events()

# ฟังก์ชันสำหรับจัดการเพลง
func play_stage_music():
	
	var bgm_node = get_node_or_null("/root/BGM")
	if not bgm_node:
		bgm_node = get_node_or_null("/root/BGMManager")

	if bgm_node:
		if stage_bgm:
			bgm_node.play_music(stage_bgm)
		else:
			bgm_node.stop_music() 
	else:
		print("Warning: Autoload BGM/BGMManager not found!")

# ฟังก์ชันจัดการ Event 
func setup_daily_events():
	var today = Global.current_day
	var is_night = Global.day_night
	var is_dawn = Global.dawn
	
	var time_suffix = ""
	
	if is_dawn:
		time_suffix = "_Evening"
	elif is_night:
		time_suffix = "_Night"
	else:
		time_suffix = "_Day"
	
	var target_node_name = "Day" + str(today) + time_suffix
	
	for node in get_children():
		if node.name.begins_with("Day"):
			if node.name != target_node_name:
				node.queue_free()
			else:
				node.visible = true
