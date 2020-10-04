extends Node2D

func _ready():
	$CanvasLayer/Transition.open()
	$SafeDoor/AnimationPlayer.play("Close")

func _on_Start_Game_pressed():
	$CanvasLayer/Transition.close("res://Scenes/Intro.tscn")
