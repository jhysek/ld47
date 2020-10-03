extends Node2D

export var MAX_SPEED = 90
export var SLOWDOWN = 40
export var charge_power = 1
export var running = true

export var MENU = false

var speed = 0

onready var world = get_node("/root/World")
onready var anim = $Gorilla/AnimationPlayer

func _ready():
	if MENU:
		anim.play("WheelStep")
		speed = MAX_SPEED

	set_process(true)

func _process(delta):
	if MENU:
		menu_process(delta)
	else:
		game_process(delta)

func menu_process(delta):
	$SmallWheel.rotation_degrees -= speed * delta
	$Big.rotation_degrees -= speed * delta
	
	
func game_process(delta):
	speed = max(0, speed - delta * SLOWDOWN)
	
	if speed <= 15 and anim.current_animation == "WheelStep":
		anim.play("Idle")
		
	if Input.is_action_just_pressed("recharge"):
		if !world.started:
			world.started = true
		
		speed = min(MAX_SPEED, speed + charge_power * 40) 
		world.charge(charge_power)
		if anim.current_animation == "Idle":
			anim.play("WheelStep")

	if running:
		$SmallWheel.rotation_degrees -= speed * delta
		$Big.rotation_degrees -= speed * delta
	

func start():
	running = true
	
func stop():
	running = false
