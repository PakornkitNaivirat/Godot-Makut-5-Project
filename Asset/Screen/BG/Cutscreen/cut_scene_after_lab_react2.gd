extends "res://Asset/Script/Cutscreen/cut_scene_after_lab_2.gd"


var expressions: Dictionary = {
	"1": {
		"normal":    Rect2(723,   540,   554, 389),  # <- แก้ตามจริง
		"happy":     Rect2(89, 504,   572, 433),
		"tired":     Rect2(108, 38,   526, 402),
		"thinking":  Rect2(693,   47, 534, 408),
		"speaking":  Rect2(1294, 47, 536, 408),
		"annoyed":   Rect2(1294, 539, 538, 408),
	},
	"2": {
		"normal":    Rect2(1305,   533,   528, 389),  # <- แก้ตามจริง
		"happy":     Rect2(695, 48,   528, 395),
		"tired":     Rect2(107, 41,   528, 398),
		"thinking":  Rect2(99,   505, 549, 418),
		"speaking":  Rect2(717, 538, 552, 408),
		"annoyed":   Rect2(1293, 48, 538, 398),
	},
	"3": {
		"normal":    Rect2(1296,   54,   531, 395),  # <- แก้ตามจริง
		"happy":     Rect2(699, 51,   521, 393),
		"tired":     Rect2(718, 532,   556, 393),
		"thinking":  Rect2(112,   46, 527, 393),
		"speaking":  Rect2(1304, 533, 536, 398),
		"annoyed":   Rect2(102, 521, 552, 417),
	},
}

var reaction_data = {
	"part1": [
		{"speaker_sprite": "1", "expr": "normal"}, 
		{"speaker_sprite": "1", "expr": "normal"},   # line 0
		{"speaker_sprite": "2", "expr": "happy"},
		{"speaker_sprite": "1", "expr": "tired"},
		{"speaker_sprite": "2", "expr": "tired"},
		{"speaker_sprite": "3", "expr": "speaking"},
		{"speaker_sprite": "3", "expr": "speaking"},
		{"speaker_sprite": "2", "expr": "happy"},
		{"speaker_sprite": "3", "expr": "thinking"},
		{"speaker_sprite": "2", "expr": "speaking"},
		{"speaker_sprite": "3", "expr": "annoyed"},
		{"speaker_sprite": "2", "expr": "happy"},
	],
	"part2": [
		{"speaker_sprite": "3", "expr": "normal"},
		{"speaker_sprite": "3", "expr": "tired"},
		{"speaker_sprite": "1", "expr": "tired"},
		{"speaker_sprite": "1", "expr": "normal"},
	],
	"part3": [
		{"speaker_sprite": "3", "expr": "normal"},
	],
}


# -------------------------------------------------------
# Internal state
# -------------------------------------------------------
var _current_key: String = ""
var _is_reacting: bool = false

# -------------------------------------------------------
# จับ key ไว้ แล้วส่งต่อ parent ตามปกติ
# -------------------------------------------------------
func start_talking(dialogue_key: String):
	_current_key = dialogue_key
	super.start_talking(dialogue_key)
	
func update_dialogue():
	super.update_dialogue()  # แสดง dialogue ตามปกติก่อน

	# เปลี่ยน expression พร้อมกับ dialogue เลย
	var has_data = (
		reaction_data.has(_current_key) and
		current_line < reaction_data[_current_key].size()
	)
	if has_data:
		var data = reaction_data[_current_key][current_line]
		var speaker = get_node_or_null(data["speaker_sprite"])
		if speaker:
			speaker.region_enabled = true
			speaker.region_rect = expressions[data["speaker_sprite"]][data["expr"]]

# -------------------------------------------------------
# Override _process — ล็อคไม่ให้กดซ้ำระหว่าง react
# -------------------------------------------------------
func _process(_delta):
	if is_talking and not _is_reacting and Input.is_action_just_pressed("interact"):
		
		var is_speech_typing = speech_bubble.visible and speech_bubble.label.visible_ratio < 0.99
		var is_inner_typing = InnerVoice.visible and InnerVoice.is_typing()
		
		if is_speech_typing:
			speech_bubble.force_skip_typing()
			
		elif is_inner_typing:
			InnerVoice.force_skip_typing()
			
		else:
			_react_then_advance()

# -------------------------------------------------------
# Coroutine หลัก
# -------------------------------------------------------
func _react_then_advance():
	_is_reacting = true

	var has_data = (
		reaction_data.has(_current_key) and
		current_line < reaction_data[_current_key].size()
	)

	if has_data:
		var data = reaction_data[_current_key][current_line]
		var speaker = get_node_or_null(data["speaker_sprite"])

		if speaker:
			speaker.region_enabled = true
			speaker.region_rect = expressions[data["speaker_sprite"]][data["expr"]]

	_is_reacting = false

	# Advance line ตามปกติ
	current_line += 1
	if current_line < current_dialogue_block.size():
		update_dialogue()
	else:
		is_talking = false
		speech_bubble.hide_dialogue()
		InnerVoice.hide_text() 
		anim.play()
		
func fade():
	get_tree().call_group("after_lab", "walk_away")
