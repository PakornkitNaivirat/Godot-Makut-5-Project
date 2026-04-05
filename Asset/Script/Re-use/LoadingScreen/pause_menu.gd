extends CanvasLayer

@onready var resume_btn = $PanelContainer/VBoxContainer/Resume
@onready var options_btn = $PanelContainer/VBoxContainer/Options
@onready var quit_btn = $"PanelContainer/VBoxContainer/Quit Destop"
@onready var click = $click

@export var option_scene: PackedScene

func _ready():
	# ซ่อนหน้าเมนูนี้ไว้ก่อนตอนเริ่มเกม
	visible = false
	
	# ผูกสัญญาณ (Signal) เมื่อปุ่มถูกกดเข้ากับฟังก์ชัน
	resume_btn.pressed.connect(_on_resume_pressed)
	options_btn.pressed.connect(_on_options_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)

func _input(event):
	# เช็คว่าผู้เล่นกดปุ่ม Pause หรือเปล่า (ปุ่ม ESC) 
	if event.is_action_pressed("ui_cancel"):
		
		# เช็คชื่อฉากปัจจุบัน ถ้า "ไม่ใช่" หน้า Main Menu ถึงจะยอมให้ Pause
		if get_tree().current_scene.name != "Main Menu":
			toggle_pause()

func toggle_pause():
	# สลับสถานะของเกมระหว่าง Pause กับ เล่นปกติ
	var is_paused = not get_tree().paused
	get_tree().paused = is_paused
	
	# แสดง/ซ่อน หน้าต่าง Pause
	visible = is_paused

# --- ฟังก์ชันการทำงานของปุ่ม ---

func _on_resume_pressed():
	click.play()
	# กด Resume ก็แค่สั่งสลับสถานะ Pause กลับเป็นปกติ
	toggle_pause()

func _on_options_pressed():
	click.play()
	if option_scene:
		var option_instance = option_scene.instantiate()
		add_child(option_instance)

func _on_quit_pressed():
	click.play()
	# 1. สั่งซ่อนหน้าต่างเมนูตัวเองซะก่อน
	visible = false
	
	# 2. ปลด Pause เกม (อันนี้คุณทำไว้ถูกแล้ว สำคัญมาก!)
	get_tree().paused = false
	
	# 3. เปลี่ยนฉากกลับหน้าหลัก
	get_tree().change_scene_to_file("res://Asset/Screen/BG/Reuseable/loading/main_menu.tscn")
