extends KinematicBody2D

export var GRAVITY = 70 * 70 
export var SPEED   = 30000
export var SHOOT_COOLDOWN = 0.5

onready var fov = $Visual/Fov
onready var world = get_node("/root/World")

const STATE_PATROL = 1
const STATE_ALERT  = 2

var dead = false
var motion = Vector2(0,0)
var state  = STATE_PATROL
var shoot_cooldown = 0.5

func _ready():
	world.connect("alarm", self, "alarm_enabled")
	set_physics_process(true)

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
		
		
	if dead:
		motion.x = lerp(motion.x, 0, 4 * delta)
	
	motion = move_and_slide(motion, Vector2(0, -1), 1, 4)
			
	

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
		state = STATE_PATROL
		$Visual/Body/Hand.show()
		$Visual/Body/Gun.hide()
		$Visual/Body/Hand/Flashlight/Light2D.enabled = true
		$Visual/Body/Gun/Hand2/Flashlight/Light2D.enabled = false

func alarm_mode():
	if !dead:
		$Visual/Body/Hand.hide()
		$Visual/Body/Gun.show()
		$Visual/Body/Hand/Flashlight/Light2D.enabled = false
		$Visual/Body/Gun/Hand2/Flashlight/Light2D.enabled = true
		state = STATE_ALERT
	
