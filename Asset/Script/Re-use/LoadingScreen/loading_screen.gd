extends CanvasLayer

@onready var animation = $AnimationPlayer

func transition_to_screenfunc (target_scene_path: String):
	# 1. เล่นอนิเมชั่นจอมืดลง
	animation.play("Fade_to_black")
	
	# รอจนกว่าอนิเมชั่น fade_to_black จะเล่นจบ
	await animation.animation_finished
	
	# 2. ทำการเปลี่ยนฉากจริงๆ
	get_tree().change_scene_to_file(target_scene_path)
	
	# 3. เล่นอนิเมชั่นสว่างขึ้น
	animation.play("Fade_out")
