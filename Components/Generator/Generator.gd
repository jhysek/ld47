extends Sprite

onready var world = get_node("/root/World")

var on = false;

func power_on():
	if !on:
		on = true
		$Light2D.enabled = true
		$TurnOn.play()
		$HandleOff.hide()
		$HandleOn.show()
		$light.modulate = Color("7cb400")
		$bolt.show()
		world.generator_turned_on()


func _on_Area2D_body_entered(body):
	if body.is_in_group("Player"):
		power_on()
		$Area2D.monitorable = false
		$Area2D.monitoring = false
