extends Node2D

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Asset/Screen/BG/Reuseable/bed_room.tscn")


func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://Asset/Screen/BG/Reuseable/sod_saiDay1 Dawn.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
