extends CanvasLayer

@onready var animation = $AnimationPlayer

func transition_to_screenfunc (target_scene_path: String):
	animation.play("Fade_to_black")
	
	# รออนิเมชั่น
	await animation.animation_finished
	
	get_tree().change_scene_to_file(target_scene_path)
	
	animation.play("Fade_out")
