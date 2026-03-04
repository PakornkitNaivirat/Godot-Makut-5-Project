extends Node2D # หรือ Area2D

@onready var anim = $AnimationPlayer

@export var full_texture: Texture2D 
@export var next_scene_path: String = ""

var collected_count = 0  
var max_items = 2

func _ready():
	if Global.minigame_status["backpack"] == true:
		print("มินิเกมนี้เคยเล่นผ่านแล้ว! ทำการข้ามฉากทันที...")
		anim.play("Full") 
		LoadingScreen.transition_to_screenfunc(next_scene_path)

func add_item():
	collected_count += 1
	print("เก็บของได้: ", collected_count, "/", max_items)
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
	
	if collected_count >= max_items:
		print("ของครบแล้ว! เปลี่ยนรูปกระเป๋า!")
		
		Global.minigame_status["backpack"] = true
		
		await tween.finished
		anim.play("Full")
		
		print("รอ 3 วินาที...")
		await get_tree().create_timer(1.0).timeout
		
		print("กำลังเปลี่ยนฉากไปที่: ", next_scene_path)
		LoadingScreen.transition_to_screenfunc(next_scene_path)
