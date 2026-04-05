extends AudioStreamPlayer

# ฟังก์ชันสำหรับสั่งเปลี่ยนเพลง
func play_music(music_stream: AudioStream):
	# เช็คก่อนว่าเพลงที่สั่งให้เล่น คือเพลงเดียวกับที่กำลังเล่นอยู่หรือไม่
	# ถ้าเป็นเพลงเดียวกัน และกำลังเล่นอยู่ ให้ return ออกไปเลย (เพลงจะได้ไม่เริ่มใหม่)
	if stream == music_stream and playing:
		return 
	
	# ถ้าเป็นเพลงใหม่ ให้เปลี่ยนไฟล์เสียงแล้วกดเล่น
	stream = music_stream
	play()

# ฟังก์ชันสำหรับหยุดเพลง (เผื่ออยากให้บางฉากเงียบ)
func stop_music():
	stop()
