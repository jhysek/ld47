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

	if shoot_cooldown > 0:
		shoot_cooldown -= delta
	
	var see_player = false
	
	if fov.is_colliding():
		var collider = fov.get_collider()
		if collider.is_in_group("Player"):
			see_player = true
			seen_player()
		
	if state == STATE_ALERT and !see_player:
		if $AlarmTimeout.is_stopped():
			print("CANNOT SEE YOU!")
			$AlarmTimeout.wait_time = rand_range(3.0, 5.0)
			$AlarmTimeout.start()
		
	if dead:
		motion.x = lerp(motion.x, 0, 4 * delta)
			
	motion = move_and_slide(motion, Vector2(0, -1), 1, 4)


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
	shoot_cooldown = SHOOT_COOLDOWN
	player.die()
	
func _on_AlarmTimeout_timeout():
	state = STATE_PATROL
	$Visual/Body/Hand.show()
	$Visual/Body/Gun.hide()
	$Visual/Body/Hand/Flashlight/Light2D.enabled = true
	$Visual/Body/Gun/Hand2/Flashlight/Light2D.enabled = false

func alarm_mode():
	$Visual/Body/Hand.hide()
	$Visual/Body/Gun.show()
	$Visual/Body/Hand/Flashlight/Light2D.enabled = false
	$Visual/Body/Gun/Hand2/Flashlight/Light2D.enabled = true
	state = STATE_ALERT
	
