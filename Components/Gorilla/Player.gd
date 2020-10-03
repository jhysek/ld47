extends KinematicBody2D

### settings ####################################
export var GRAVITY = 70 * 70 
export var SPEED   = 30000
export var JUMP_SPEED  = -1200
export var PLAYER_SCALE = 0.4

### nodes #######################################
onready var anim = $AnimationPlayer
onready var cam  = $Camera2D
onready var sfx_run = $Sfx/Run

### game variables ##############################
var dead = false
var motion = Vector2(0,0)
var in_air = false
var was_in_air = false
var jump_timeout = 0
var airtime = 0

func _ready():
	$Visual
	set_physics_process(true)


func controlled_process(delta):
	var grounded = is_on_floor()
	
	if grounded:
		in_air = false
		jump_timeout = 0
		
	elif !in_air and jump_timeout <= 0:
		jump_timeout = 0.11
		
	if jump_timeout > 0:
		jump_timeout -= delta
		if jump_timeout <= 0:
			in_air = true

	if in_air:
		airtime += delta

	if was_in_air and !in_air:
		print("DUP: " + str(airtime))
		cam.shake(0.1, 50, 10)
		$Sfx/Jump.play()
		
	was_in_air = in_air
	
	if !dead:
		if not in_air and Input.is_action_just_pressed("ui_up"):
			in_air = true
			airtime = 0
			jump_timeout = 0
			anim.play("Jump")
			$Sfx/Jump.play()
			motion.y = JUMP_SPEED
			sfx_run.stop()
	
		if Input.is_action_pressed('ui_right'):
			if !in_air and anim.current_animation != "RunRight":
			  anim.play("RunRight")
			motion.x = min(motion.x + SPEED * delta, SPEED * delta)
			$Visual.scale.x = PLAYER_SCALE
			if sfx_run and !sfx_run.playing and !in_air:
				sfx_run.play()
				
		if Input.is_action_pressed('ui_left'):
			if not in_air and anim.current_animation != "RunLeft":
			  anim.play("RunLeft")
			motion.x = max(motion.x - SPEED * delta, -SPEED * delta)
			$Visual.scale.x = -PLAYER_SCALE
			if sfx_run and !sfx_run.playing and !in_air:
				 sfx_run.play()
			
		elif !Input.is_action_pressed('ui_right'):
			if !in_air and anim.current_animation != "Idle" :
				anim.play("Idle")
				
			motion.x = 0
			if sfx_run and sfx_run.playing:
				sfx_run.stop()
	else:
		motion.x = 0


func _physics_process(delta):
	motion.y += GRAVITY * delta
	
	if not dead:
		controlled_process(delta)
	
	if dead:
		motion.x = lerp(motion.x, 0, 4 * delta)
			
	motion = move_and_slide(motion, Vector2(0, -1), 1, 4)

