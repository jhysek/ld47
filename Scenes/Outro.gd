extends Node2D



# Called when the node enters the scene tree for the first time.
func _ready():
	$Girl/Visual.scale.x = 0.4
	$Girl/AnimationPlayer.play("RunRight")
	$Girl/Sfx/Run.play()

func girl_stop():
	$Girl/AnimationPlayer.play("Idle")
	$Girl/Sfx/Run.stop()

func play_roger():
	$Player/Sfx/Roger1.play()

func play_roger2():
	$Player/Sfx/Roger2.play()

	
func _on_Button_pressed():
	get_tree().change_scene("res://Scenes/Menu.tscn")
