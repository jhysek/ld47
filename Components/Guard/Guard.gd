extends KinematicBody2D

### Settings ############################################
export var GRAVITY = 70 * 70 
export var SPEED   = 10000
export var SHOOT_COOLDOWN = 0.5

### Nodes ##############################################
onready var fov = $Visual/Fov
onready var world = get_node("/root/World")
onready var anim = $AnimationPlayer

### Run variables ######################################
const STATE_PATROL = 1
const STATE_ALERT  = 2

var dead = false
var motion = Vector2(0,0)
var patrol_motion = Vector2(0,0)
var state  = STATE_PATROL
var shoot_cooldown = 0.5
var patrol_route = []
var alarm_patrol_route = []
var current_route = []
var target = null
var next_patrol_point_idx = 0


func _ready():
	initialize_routes()
	world.connect("alarm", self, "alarm_enabled")
	set_physics_process(true)

func initialize_routes():
	if has_node("Patrol"):
		patrol_route = []
		for point in get_node("Patrol").get_children():
			patrol_route.push_front(point.global_position)
		if patrol_route.size() > 0:
			current_route = patrol_route
			get_next_patrol_point()
			
	if has_node("AlarmPatrol"):
		alarm_patrol_route = []
		for point in get_node("AlarmPatrol").get_children():
			alarm_patrol_route.push_front(point.global_position)
	
			
func alarm_enabled(enabled):
	if enabled:
		alarm_mode()
	else:
		disable_alarm_mode()


func disable_alarm_mode():
	$AlarmTimeout.wait_time = rand_range(2.0, 4.0)
	$AlarmTimeout.start()


func _physics_process(delta):
	motion.y += GRAVITY * delta

	if !dead:
		if shoot_cooldown > 0:
			shoot_cooldown -= delta
	
		var see_player = false
	
		if fov.is_colliding():
			var collider = fov.get_collider()
			if collider.is_in_group("Player"):
				see_player = true
				seen_player()
		
		if state == STATE_ALERT and !world.alarm and !see_player:
			if $AlarmTimeout.is_stopped():
				$AlarmTimeout.wait_time = rand_range(3.0, 5.0)
				$AlarmTimeout.start()
				
		if current_route != []:
			patrolling_process(delta)
			
	if dead:
		motion.x = lerp(motion.x, 0, 4 * delta)
	
	motion = move_and_slide(motion, Vector2(0, -1), 1, 4)
			
	
func patrolling_process(delta):
	motion.x = 0
	
	print("target: " + str(target.x) + " pos: " + str(position.x))
	
	if abs(target.x - position.x) < 20:
		get_next_patrol_point()		
	else:
		print(patrol_motion)
		motion.x = patrol_motion.x * delta


func get_next_patrol_point():
	next_patrol_point_idx = (next_patrol_point_idx + 1) % current_route.size()
	target = current_route[next_patrol_point_idx]
		
	if target.x >= position.x:
		patrol_motion = Vector2(SPEED, 0)
		anim.play("WalkRight")
				
	else:
		patrol_motion = Vector2(-SPEED, 0)
		anim.play("WalkLeft")
	

func die():
	$CPUParticles2D.emitting = true
	remove_from_group("Enemy")
	$AnimationPlayer.play("Die")
	$Sfx/Death.play()
	$Visual/Fov.enabled = false
	dead = true
	world.disconnect("alarm", self, "alarm_enabled")

func seen_player():
	$AlarmTimeout.stop()
	
	if state == STATE_PATROL:
		alarm_mode()	
		shoot_cooldown = SHOOT_COOLDOWN
		
	elif state == STATE_ALERT:
		if shoot_cooldown <= 0:
			if fov.is_colliding():
				var collider = fov.get_collider()
				if collider.is_in_group("Player") and !collider.dead:
					shoot(collider)

					
func shoot(player):
	$Sfx/Fire.play()
	$AnimationPlayer.play("Shoot")
	shoot_cooldown = SHOOT_COOLDOWN
	player.die()
	
func _on_AlarmTimeout_timeout():
	if !dead:
		current_route = patrol_route
		get_next_patrol_point()
		state = STATE_PATROL
		$Visual/Body/Hand.show()
		$Visual/Body/Gun.hide()
		$Visual/Body/Hand/Flashlight/Light2D.enabled = true
		$Visual/Body/Gun/Hand2/Flashlight/Light2D.enabled = false

func alarm_mode():
	if !dead:
		current_route = alarm_patrol_route
		get_next_patrol_point()
		$Visual/Body/Hand.hide()
		$Visual/Body/Gun.show()
		$Visual/Body/Hand/Flashlight/Light2D.enabled = false
		$Visual/Body/Gun/Hand2/Flashlight/Light2D.enabled = true
		state = STATE_ALERT
	
