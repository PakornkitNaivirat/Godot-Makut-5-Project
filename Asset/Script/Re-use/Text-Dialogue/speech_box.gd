extends Node2D

@onready var panel = $PanelContainer
@onready var label = $PanelContainer/MarginContainer/Label

@export var typing_speed: float = 0.05 

var current_tween: Tween # 🌟 เพิ่มตัวแปรเก็บแอนิเมชัน

func _ready():
	scale = Vector2.ZERO 

func show_dialogue(text_to_show: String):
	if current_tween and current_tween.is_valid():
		current_tween.kill()
		
	label.text = text_to_show
	panel.reset_size() 
	panel.position = Vector2(-panel.size.x / 2, -panel.size.y)
	panel.pivot_offset = Vector2(panel.size.x / 2, panel.size.y)
	label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	
	scale = Vector2.ZERO
	label.visible_ratio = 0.0 # เริ่มจาก 0
	show()
	
	current_tween = create_tween().set_parallel(true)
	current_tween.tween_property(self, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	var total_typing_time = text_to_show.length() * typing_speed
	current_tween.tween_property(label, "visible_ratio", 1.0, total_typing_time).set_trans(Tween.TRANS_LINEAR)

# 🌟 ฟังก์ชันใหม่: เอาไว้เช็คว่ากำลังพิมพ์อยู่ไหม?
func is_typing() -> bool:
	return label.visible_ratio < 1.0

# 🌟 ฟังก์ชันใหม่: สั่งให้ข้อความขึ้นเต็มทันที
func force_skip_typing():
	if current_tween and current_tween.is_valid():
		current_tween.kill() # สั่งหยุดการพิมพ์เดี๋ยวนี้!
		
	scale = Vector2.ONE
	label.visible_ratio = 1.0 # บังคับโชว์ข้อความ 100%
	
func hide_dialogue():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.2)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await tween.finished
	hide()
