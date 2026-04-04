extends Node2D # หรือ Area2D

@onready var anim = $AnimationPlayer

@export var full_texture: Texture2D
@export var next_scene_path: String = ""

var collected_count = 0
var max_items = 3

# UI nodes - ชี้ไปที่ CanvasLayer/UI ที่เพิ่มใน scene
@onready var progress_label = $"../UI/ProgressLabel"
@onready var bar_fill = $"../UI/ProgressBarFill"

const BAR_FULL_WIDTH: float = 300.0

func _ready():
	_update_ui()
	if Global.minigame_status["backpack"] == true:
		anim.play("Full")
		LoadingScreen.transition_to_screenfunc(next_scene_path)

func add_item():
	collected_count += 1
	_update_ui()

	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(1.4, 1.4), 0.1)
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1)

	if collected_count >= max_items:
		$AudioStreamPlayer.play()
		Global.minigame_status["backpack"] = true

		await tween.finished
		anim.play("Full")

		await get_tree().create_timer(1.0).timeout
		LoadingScreen.transition_to_screenfunc(next_scene_path)

func _update_ui():
	# อัพเดต label
	progress_label.text = "Items packed: %d / %d" % [collected_count, max_items]

	# อัพเดต progress bar ด้วย tween ให้ smooth
	var target_width = (float(collected_count) / float(max_items)) * BAR_FULL_WIDTH
	var tween = create_tween()
	tween.tween_property(bar_fill, "size:x", target_width, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)

	# เปลี่ยนสี bar ตามความคืบหน้า
	if collected_count == 1:
		bar_fill.color = Color(0.863, 0.659, 0.0, 1.0)
	elif collected_count == max_items:
		bar_fill.color = Color(0.4, 0.8, 0.3, 1)
