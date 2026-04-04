extends CharacterBody2D
class_name PlayerController

@onready var message_sound = $AudioStreamPlayer
@export var SPEED: float = 375.0

var direction = 0
@export var is_locked = false


func _ready() -> void:
	# Check old position
	if Global.load_exact_pos == true:
		global_position = Global.last_player_pos 
		Global.load_exact_pos = false
		
	elif Global.target_spawn_name != "":
		var spawn_point = get_tree().get_current_scene().find_child(Global.target_spawn_name, true, false)
		
		if spawn_point != null:
			global_position = spawn_point.global_position
			
		Global.target_spawn_name = ""
		
func _physics_process(delta: float) -> void:
	
	#Check Player is lock?
	if is_locked :
		return
	
	#Controll movement
	direction = Input.get_axis("move_left", "move_right")
	
	if direction:
		if not message_sound.playing:
			message_sound.play()
		velocity.x = direction * SPEED
	else:
		message_sound.stop()
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
