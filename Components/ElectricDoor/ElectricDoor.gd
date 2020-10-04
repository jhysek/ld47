extends Node2D


onready var world = get_node("/root/World")

# Called when the node enters the scene tree for the first time.
func _ready():
	world.connect("alarm", self, "alarm_fired")


func alarm_fired(enabled):
	if enabled:
		$StaticBody2D/CollisionShape2D.disabled = true
		$AnimatedSprite.hide()
	else:
		$StaticBody2D/CollisionShape2D.disabled = false
		$AnimatedSprite.show()
