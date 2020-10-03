extends Node2D

signal alarm

### settings ########################################
export var CHARGE_COOLDOWN  = 0.1

### nodes ###########################################
onready var electricity = $CanvasLayer/Electricity

### run variables ###################################
var current_charge_cooldown = CHARGE_COOLDOWN
var alarm = false



func _ready():
	print("READY");
	$CanvasLayer/Transition.open()

func _process(delta):
	if electricity.value > 0:
		electricity.value -= delta

		if (alarm):
			stop_alarm()	
		
		if !alarm and electricity.value <= 0:
			fire_alarm()
		
	current_charge_cooldown -= delta	


func charge(value):
	if current_charge_cooldown <= 0:
		electricity.value += value
		current_charge_cooldown = CHARGE_COOLDOWN
		
func stop_alarm():
	emit_signal("alarm", false)
	$Alarm.stop()
	alarm = false

func fire_alarm():
	emit_signal("alarm", true)
	$Alarm.fire()
	alarm = true
