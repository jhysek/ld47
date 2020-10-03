extends ColorRect

var target_scene

func open():
	target_scene = null
	$AnimationPlayer.play_backwards("Transition")
	
func close(to_scene = null):
	target_scene = to_scene
	$AnimationPlayer.play("Transition")
	
func change_scene():
	if target_scene:
		get_tree().change_scene(target_scene)
