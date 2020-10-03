extends Timer

onready var cam = get_node("/root/World/Player/Camera2D")

func fire():
	#cam.shake(0.8, 200, 2, true)
	$Sfx.play()
	start()

func _on_Alarm_timeout():
	#cam.shake(0.8, 200, 2, true)
	$Sfx.play()
