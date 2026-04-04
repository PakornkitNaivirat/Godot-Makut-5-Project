extends AudioStreamPlayer

func play_music(music_path: String):
	# ถ้าเพลงที่กำลังเล่นอยู่ไม่ใช่เพลงเดิม ค่อยเปลี่ยน
	if stream == null or stream.resource_path != music_path:
		stream = load(music_path)
		if stream is AudioStreamMP3:
			stream.loop = true
		volume_db = -30.0
		play()
