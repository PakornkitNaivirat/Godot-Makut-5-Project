extends Node2D

func _on_start_pressed() -> void:
	LoadingScreen.transition_to_screenfunc("res://Asset/Screen/BG/Reuseable/bed_room.tscn")


func _on_options_pressed() -> void:
	pass


func _on_quit_pressed() -> void:
	get_tree().quit()
