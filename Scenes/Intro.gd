extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$CanvasLayer/Transition.open()

func girl_bubble():
	$Wheel/Gorilla/Sfx/Roger1.play()
	
func boy_bubble():
	$Player/Sfx/Kill3.play()

func play_music():
	$AudioStreamPlayer.play()


func _on_Button_pressed():
	$CanvasLayer/Transition.close("res://Scenes/Game.tscn")
