extends Sprite
onready var world = get_node("/root/World")

func _ready():
	if world:
		world.connect('alarm', self, 'electricity_outage')
	on()
	
func electricity_outage(outage):
	if outage:
		off()
	else:
		on()

func on():
	$Light.modulate = Color("9bd320")
	
func off():
	$Light.modulate = Color("444444")
