extends Node2D

@onready var panel = $PanelContainer
@onready var label = $PanelContainer/MarginContainer/Label

@export var typing_speed: float = 0.05 

func _ready():
	scale = Vector2.ZERO 

func show_dialogue(text_to_show: String):
	label.text = text_to_show
	
	panel.reset_size() 
	
	panel.position = Vector2(-panel.size.x / 2, -panel.size.y)
	panel.pivot_offset = Vector2(panel.size.x / 2, panel.size.y)
	
	label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	
	scale = Vector2.ZERO
	label.visible_ratio = 0.0
	show()
	
	var tween = create_tween().set_parallel(true)
	
	tween.tween_property(self, "scale", Vector2.ONE, 0.3)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		
	
	var total_typing_time = text_to_show.length() * typing_speed
	tween.tween_property(label, "visible_ratio", 1.0, total_typing_time)\
		.set_trans(Tween.TRANS_LINEAR)

func hide_dialogue():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.2)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await tween.finished
	hide()
