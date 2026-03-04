extends CharacterBody2D
class_name PlayerController

const SPEED = 300.0
var direction = 0
var is_locked = false


func _ready() -> void:
	# Check old position
	if Global.load_exact_pos == true:
		global_position = Global.last_player_pos 
		Global.load_exact_pos = false
		
	elif Global.target_spawn_name != "":
		var spawn_point = get_tree().get_current_scene().find_child(Global.target_spawn_name, true, false)
		
		if spawn_point != null:
			global_position = spawn_point.global_position
		else:
			print("หาจุดเกิดชื่อ ", Global.target_spawn_name, " ไม่เจอ! ให้เกิดที่ default แทน")
			
		Global.target_spawn_name = ""
		
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
