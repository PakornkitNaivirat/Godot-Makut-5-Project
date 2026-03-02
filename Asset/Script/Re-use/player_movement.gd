extends CharacterBody2D
class_name PlayerController

const SPEED = 300.0
var direction = 0
var is_locked = false

func _physics_process(delta: float) -> void:
	#Check Player is lock?
	if is_locked :
		return
	
	#Controll movement
	direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
