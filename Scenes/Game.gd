extends Node2D

signal alarm
signal pause

### settings ########################################
export var CHARGE_COOLDOWN  = 0.1

### nodes ###########################################
onready var electricity = $CanvasLayer/Electricity

### run variables ###################################
var current_charge_cooldown = CHARGE_COOLDOWN
var alarm = false
var started = true
var paused = false
var generator = false

func _ready():
	$CanvasLayer/Transition.open()

func restart():
	$CanvasLayer/Transition.close("res://Scenes/Game.tscn")

func _process(delta):
	if Input.is_action_just_pressed("restart"):
		restart()
	
	if Input.is_action_just_pressed("pause"):
		if paused:
			unpause()
		else:
			pause()
	
	if paused:
		return
		
	if started and !generator and electricity.value > 0:
		electricity.value -= delta

		if (alarm):
			stop_alarm()	
		
		if !alarm and electricity.value <= 0:
			fire_alarm()
		
	current_charge_cooldown -= delta	


func generator_turned_on():
	electricity.value = 5
	generator = true
	if alarm:
		stop_alarm()
	$GameFinishedTimer.start()
	

func charge(value):
	if current_charge_cooldown <= 0:
		electricity.value += value
		current_charge_cooldown = CHARGE_COOLDOWN
		
func stop_alarm():
	$CanvasLayer/AlertLabel.hide()
	emit_signal("alarm", false)
	$Alarm.stop()
	alarm = false

func fire_alarm():
	$CanvasLayer/AlertLabel.show()
	emit_signal("alarm", true)
	$Alarm.fire()
	alarm = true

func player_died():
	$CanvasLayer/UI/Info/AnimationPlayer.play("Show")
	$RestartTimer.start()
	
func _on_RestartTimer_timeout():
	restart()

func pause():
	$CanvasLayer/UI/Pause.show()
	paused = true
	emit_signal("pause", true)
	
func unpause():
	$CanvasLayer/UI/Pause.hide()
	paused = false
	emit_signal("pause", false)

func _on_ButtonResume2_pressed():
	$CanvasLayer/Transition.close("res://Scenes/Menu.tscn")


func _on_GameFinishedTimer_timeout():
	$CanvasLayer/Transition.close("res://Scenes/Outro.tscn")
	print("GAME FINISHED!")
