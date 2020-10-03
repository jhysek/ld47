extends StaticBody2D


onready var world = get_node("/root/World")


func _ready():
	if world:
		world.connect("alarm", self, "alarm_change")
	
func alarm_change(enabled):
	if enabled:
		$AnimationPlayer.play("Close")
	else:
		$AnimationPlayer.play_backwards("Close")
