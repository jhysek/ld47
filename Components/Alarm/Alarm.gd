extends Timer

func fire():
	$Sfx.play()
	start()

func _on_Alarm_timeout():
	$Sfx.play()
