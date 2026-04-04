
extends Area2D

@export var bin_type : String
var original_scale : Vector2 

func _ready():
	add_to_group("bins")
	original_scale = scale 

func play_bounce():
	var tween = create_tween()
	
	tween.tween_property(self, "scale", original_scale * 1.1, 0.1)
	
	tween.tween_property(self, "scale", original_scale, 0.1).set_trans(Tween.TRANS_BOUNCE)
