extends Node2D

export var charge_power = 1

onready var world = get_node("/root/World")

func _ready():
	set_process(true)

func _process(delta):
	if Input.is_action_just_pressed("recharge"):
		world.charge(charge_power)
