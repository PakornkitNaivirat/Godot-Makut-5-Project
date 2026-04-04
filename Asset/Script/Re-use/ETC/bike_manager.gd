extends Node2D

@export var biker_scene: PackedScene 
@export var biker_textures: Array[Texture2D] 

@export_group("Settings")
@export var spawn_start_x: float = -300.0
@export var spawn_end_x: float = 1600.0
@export var direction: int = 1 # 1=ขวา, -1=ซ้าย

# 🌟 ตัวแปรเก็บรูปรถล่าสุดที่เพิ่งปล่อยไป
var last_picked_texture: Texture2D = null

func _ready():
	spawn_cycle()

func spawn_cycle():
	while true:
		var group_size = randi_range(1, 2)
		
		for i in range(group_size):
			create_biker()
			await get_tree().create_timer(randf_range(0.3, 2)).timeout
		
		await get_tree().create_timer(4.0).timeout # เว้นช่วง 4 วิ

func create_biker():
	if not biker_scene: return
	
	var new_biker = biker_scene.instantiate()
	add_child(new_biker)
	
	new_biker.global_position.x = spawn_start_x
	new_biker.global_position.y = global_position.y + randf_range(-5, 5)
	
	var speed = randf_range(1200, 1500.0)
	
	# === 🌟 ระบบสุ่มรูปไม่ให้ซ้ำกับคันก่อนหน้า ===
	var chosen_texture = get_unique_texture()
	
	# ส่ง "รูปที่เลือกแล้ว" 1 รูป ไปให้ตัวรถ (ไม่ได้ส่งไปทั้ง Array แล้ว)
	new_biker.setup(chosen_texture, speed, direction, spawn_end_x)

# ฟังก์ชันสุ่มรูปแบบไม่ซ้ำ
func get_unique_texture() -> Texture2D:
	if biker_textures.size() == 0: return null
	if biker_textures.size() == 1: return biker_textures[0]
	
	var available_textures = biker_textures.duplicate()
	
	# ถ้าจำรูปเก่าได้ ให้ดึงรูปเก่าออกจากการสุ่ม
	if last_picked_texture and last_picked_texture in available_textures:
		available_textures.erase(last_picked_texture)
		
	var new_texture = available_textures.pick_random()
	last_picked_texture = new_texture # จำไว้ใช้รอบหน้า
	
	return new_texture
