extends Node2D
@export var option_scene: PackedScene

func _on_start_pressed() -> void:
	LoadingScreen.transition_to_screenfunc("res://Asset/Screen/BG/Day1/Intro.tscn")


func _on_options_pressed() -> void:
	if option_scene:
		var option_instance = option_scene.instantiate()
		add_child(option_instance)

func _on_quit_pressed() -> void:
	get_tree().quit()
