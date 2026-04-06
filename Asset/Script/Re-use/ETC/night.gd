extends Node2D

func _process(delta: float) -> void:
	if Global.day_night:
		show()
	else:
		hide()
