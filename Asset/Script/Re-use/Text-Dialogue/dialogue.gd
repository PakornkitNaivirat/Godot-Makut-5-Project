extends Area2D

@export_multiline var dialog_text: Array[String] = [
	""
]

@onready var speech_bubble = $speech
@onready var anim1 = $AnimationPlayer1
@onready var anim2 = $AnimationPlayer2
@onready var box = $box
@onready var dot = $dot

var player_start_pos: Vector2
var is_talking = false
var can_interact = false
var current_line = 0

#Check ว่ามีจริงไหม
func _ready():
	if speech_bubble:
		speech_bubble.hide()
	if box :
		box.hide()
	if dot :
		dot.hide()

func _process(delta):
	if can_interact and Input.is_action_just_pressed("interact"):
		
		var player = get_tree().get_first_node_in_group("Player")
		
		
		if not is_talking: #เริ่มคุย
			is_talking = true
			current_line = 0
			
			if player: 
				player.is_locked = true
				player_start_pos = player.global_position
				
				#Animation
				var sprite = player.get_node("Animaton/Sprite2D")
				var anim = player.get_node("Animaton/AnimationPlayer")
				
				#Calculate Distance
				var target_pos = $PlayerSpot.global_position
				var distance = player.global_position.distance_to(target_pos)
				var walk_speed = 200.0
				var duration = distance / walk_speed

				if sprite:
					sprite.flip_h = ($PlayerSpot.global_position.x < player.global_position.x)
				
				if anim:
					anim.play("move")
				
				var move_tween = create_tween()
				
				move_tween.tween_property(player, "global_position", target_pos, duration)\
					.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
				await move_tween.finished
				
				if anim:
					anim.play("idle")
				
				if sprite:
					sprite.flip_h = (global_position.x < player.global_position.x)
					
			box.hide()
			dot.hide()
			speech_bubble.show_dialogue(dialog_text[current_line])
		else:
			#ระบบคุยต่อไปเรื่อยๆ
			current_line += 1
			
			if current_line < dialog_text.size():
				speech_bubble.show_dialogue(dialog_text[current_line])
				
			else: #กรณีคุยเสร็จแล้ว แต่ยังไม่ขยับให้ show animation ต่อ
				if player:
					var sprite = player.get_node("Animaton/Sprite2D")
					var anim = player.get_node("Animaton/AnimationPlayer")
					
					#Calculate Distance
					var distance = player.global_position.distance_to(player_start_pos)
					var walk_speed = 200.0
					var duration = distance / walk_speed
					
					# Flip
					if sprite:
						sprite.flip_h = (player_start_pos.x < player.global_position.x)
					
					if anim:
						anim.play("move")
					
					# Go Back to old position
					var move_back_tween = create_tween()
					move_back_tween.tween_property(player, "global_position", player_start_pos, duration)\
						.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
					
					await move_back_tween.finished
				
					if anim:
						anim.play("idle")
						
					player.is_locked = false
					
				speech_bubble.hide_dialogue()
				is_talking = false
				box.show()
				dot.show()

#Check ตอนเข้า
func _on_body_entered(body):
	if body.name == "Player":
		can_interact = true
		box.show()
		anim2.play("glowing")
		dot.show()
		anim1.play("dot")
		
#Check ตอนออก
func _on_body_exited(body):
	if body.name == "Player":
		can_interact = false
		box.hide()
		dot.hide()
		anim1.stop()
		anim2.stop()
		
		if is_talking:
			is_talking = false
			speech_bubble.hide_dialogue()
