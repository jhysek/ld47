extends Node2D

func _ready():
	$CanvasLayer/Transition.open()

func _on_Start_Game_pressed():
	$CanvasLayer/Transition.close("res://Scenes/Game.tscn")
