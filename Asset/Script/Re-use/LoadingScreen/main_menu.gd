extends Node2D
@export var option_scene: PackedScene
@onready var click = $click
func _on_start_pressed() -> void:
	click.play()
	LoadingScreen.transition_to_screenfunc("res://Asset/Screen/BG/Day1/Intro.tscn")


func _on_options_pressed() -> void:
	click.play()
	if option_scene:
		var option_instance = option_scene.instantiate()
		add_child(option_instance)

func _on_quit_pressed() -> void:
	click.play()
	get_tree().quit()
