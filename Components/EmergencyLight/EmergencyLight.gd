extends Light2D


onready var world = get_node("/root/World")

func _ready():
	world.connect("alarm", self, "alarm_fired")
	

func alarm_fired(fired):
	if fired:
		color = Color("ff0000")
	else:
		color = Color("ffffff")
