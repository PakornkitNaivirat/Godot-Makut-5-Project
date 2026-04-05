extends Node2D
@export var room_bgm: AudioStream

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if room_bgm:
		BGM.play_music(room_bgm)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
