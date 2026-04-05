extends Node2D

var score : int = 0
@onready var count_label = $CanvasLayer/CountLabel

func _ready():

	if has_node("SandBackground"):
		$SandBackground.z_index = -1
		$SandBackground.set_process_input(false)
	
	update_ui()
	
	await get_tree().create_timer(0.1).timeout
	var all_trash = get_tree().get_nodes_in_group("trash_group")
	for trash in all_trash:
		if trash.has_signal("trash_clicked"):
			if not trash.is_connected("trash_clicked", _on_trash_collected):
				trash.trash_clicked.connect(_on_trash_collected)

func _on_trash_collected():
	score += 1
	update_ui()
	
	# รอเช็กแป๊บนึงว่าขยะในกลุ่ม trash_group หมดหรือยัง
	await get_tree().create_timer(0.1).timeout
	
	if get_tree().get_nodes_in_group("trash_group").size() == 0:
		print("เก็บขยะหมดแล้ว! รอแป๊บนึงก่อนไปแยกขยะ...")
		
		await get_tree().create_timer(2.0).timeout 
		
	
		get_tree().change_scene_to_file("res://Asset/Screen/BG/Minigames/sorting_game.tscn")

func update_ui():
	if count_label:
		count_label.text = "ขยะที่เก็บได้: " + str(score)
