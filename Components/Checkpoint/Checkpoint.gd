extends Area2D

export var number = 1
onready var world = get_node("/root/World")

func _on_Checkpoint_body_entered(body):
	world.checkpoint_reached(self)
