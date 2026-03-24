extends Node2D

func _ready():
	setup_daily_events()

func setup_daily_events():
	var today = Global.current_day
	var is_night = Global.day_night
	
	# กำหนดคำต่อท้ายตามเวลา
	var time_suffix = "_Night" if is_night else "_Day"
	
	# ชื่อโหนดที่เราต้องการเก็บไว้ (เช่น "Day1_Day" หรือ "Day2_Night")
	var target_node_name = "Day" + str(today) + time_suffix
	
	
	# 1. จัดการลบโหนดเหตุการณ์ที่ไม่ใช่วัน/เวลานี้ทิ้ง
	for node in get_children():
		# เช็คว่าโหนดนี้ชื่อขึ้นต้นด้วย "Day" ไหม
		if node.name.begins_with("Day"):
			if node.name != target_node_name:
				node.queue_free() # ลบทิ้งไปเลย!
			else:
				node.visible = true # อันที่ตรงเงื่อนไขให้โชว์ขึ้นมา
				
