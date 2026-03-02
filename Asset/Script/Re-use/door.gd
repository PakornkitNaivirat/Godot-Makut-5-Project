extends Area2D

@onready var interact_icon = $interaction
@export var next_scene_path: String = ""

var can_interact = false

func _process(delta):
	if can_interact and Input.is_action_just_pressed("interact"):
		if next_scene_path != "":
			print("กำลังเปลี่ยนฉากไปที่: ", next_scene_path)
			LoadingScreen.transition_to_screenfunc(next_scene_path)
		else:
			print("ยังไม่ได้ใส่ที่อยู่ฉากใหม่ใน Inspector!")

func _on_body_entered(body):
	if body.name == "Player":
		can_interact = true
		interact_icon.show_icon()
		

func _on_body_exited(body):
	if body.name == "Player":
		can_interact = false
		interact_icon.hide_icon()
