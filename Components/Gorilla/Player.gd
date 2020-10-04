extends KinematicBody2D

### settings ####################################
export var GRAVITY = 70 * 70 
export var SPEED   = 30000
export var JUMP_SPEED  = -1200
export var DASH_SPEED = 100000
export var DASH_DURATION = 0.08
export var PLAYER_SCALE = 0.4
export var PLAYER = true
export var GIRL = false

### nodes #######################################
onready var world = get_node("/root/World")

onready var anim = $AnimationPlayer
onready var cam  = $Camera2D
onready var sfx_run = $Sfx/Run
onready var attack_range = $Visual/AttackRange

### game variables ##############################
var dead = false
var motion = Vector2(0,0)
var in_air = false
var was_in_air = false
var dashing = false
var jump_timeout = 0
var dash_timeout = 0
var dash_cooldown = 0
var airtime = 0
var direction = 1

func _ready():
	if GIRL:
		$Visual/Body/Head.texture = load("res://Components/Gorilla/Assets/head_girl.png")

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
			airtime = 0
			in_air = true

	if in_air:
		airtime += delta

	if was_in_air and !in_air:
		if airtime >= 0.3:
			cam.shake(0.2, 50, 10)
			$Sfx/Jump.play()
		
	was_in_air = in_air
	
	if !dead:
		if not in_air and Input.is_action_just_pressed("ui_up"):
			start_world()
			in_air = true
			airtime = 0
			jump_timeout = 0
			anim.play("Jump")
			$Sfx/JumpStart.play()
			motion.y = JUMP_SPEED
			sfx_run.stop()
	
		if Input.is_action_pressed('ui_right'):
			start_world()
			if !in_air and anim.current_animation != "RunRight":
			  anim.play("RunRight")
			  direction = 1
			motion.x = min(motion.x + SPEED * delta, SPEED * delta)
			$Visual.scale.x = PLAYER_SCALE
			if sfx_run and !sfx_run.playing and !in_air:
				sfx_run.play()
				
		if Input.is_action_pressed('ui_left'):
			start_world()
			if not in_air and anim.current_animation != "RunLeft":
			  anim.play("RunLeft")
			  direction = -1
			motion.x = max(motion.x - SPEED * delta, -SPEED * delta)
			$Visual.scale.x = -PLAYER_SCALE
			if sfx_run and !sfx_run.playing and !in_air:
				 sfx_run.play()
			
		elif !Input.is_action_pressed('ui_right'):
			if !in_air and anim.current_animation != "Idle" and anim.current_animation != "Dash":
				anim.play("Idle")
				
			motion.x = 0
			if sfx_run and sfx_run.playing:
				sfx_run.stop()
				
	else:
		motion.x = 0


func start_world():
	if !world.started:
		world.started = true

func dash():
	anim.play("Dash")
	$Sfx.get_node("Kill" + str(randi() % 5 + 1)).play()
	dash_timeout = DASH_DURATION
	dashing = true

func dash_process(delta):
	if dash_timeout > 0:
		dash_timeout -= delta
		motion.x = DASH_SPEED * delta * direction
	else:
		dashing = false
		motion.x = 0
		
		
func player_physics_process(delta):
	motion.y += GRAVITY * delta

	if attack_range.is_colliding():
		var collider = attack_range.get_collider()
		if collider.is_in_group("Enemy"):
			collider.remove_from_group("Enemy")
			collider.die()
			dash()		
	
	if not dead:
		if dashing:
			dash_process(delta)
		else:
			controlled_process(delta)
	
	if dead:
		motion.x = lerp(motion.x, 0, 4 * delta)
			
	motion = move_and_slide(motion, Vector2(0, -1), 1, 4)


func die():
	if !dead:
		dashing = false
		dead = true
		anim.stop()
		anim.play("Die")
		world.player_died()

func hamster_physics_process(delta):
	pass

func _physics_process(delta):	
	if PLAYER: 
		player_physics_process(delta)
	else:
		hamster_physics_process(delta)


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Dash" or anim_name == "WheelStep":
		anim.play("Idle")
