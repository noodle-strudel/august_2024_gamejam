extends "res://Scripts/AI.gd"


var landed = false

# determins if the offensiveTimer is a child
var offensiveTimer = false

# Raycast for the ball detection
@onready var raycast = $RayCast2D
@onready var enemy_goal = $"/root/MainGame/Enemy Goal"
@onready var goal = $"/root/MainGame/Goal"
@onready var offense_jump_timer

enum STATE {
	OFFENSE,
	DEFENSE,
	NORMAL
}

var state = STATE.OFFENSE

func _process(delta):
	queue_redraw()

# Overriding the input for ai
func get_input():
	
	# Change the behavior of the AI based on the ball's global position
	if ball.global_position.x > 384: # close to the player's goal
		state = STATE.OFFENSE
	elif ball.global_position.x < -384: # close to the AI's goal
		state = STATE.NORMAL
	else: # in the middle
		state = STATE.NORMAL
	
	# change behavior based on the state of the AI
	match state:
		STATE.NORMAL:
			if offensiveTimer:
				for child in get_children():
					if child.name == "OffenseJumpTimer":
						child.queue_free()
						offensiveTimer = false
			normal()
			
		STATE.OFFENSE:
			if offensiveTimer == false:
				offense_jump_timer = Timer.new()
				offense_jump_timer.autostart = true
				offense_jump_timer.wait_time = 5
				offense_jump_timer.name = "OffenseJumpTimer"
				offense_jump_timer.timeout.connect(_offense_Timeout)
				add_child(offense_jump_timer)
				offensiveTimer = true
			normal()
	
	return input.normalized()

func normal():
	#print("up direction: ", up_direction)
	if(grounded):
		ball = ball as Node
		if(ball != null):
			ball_move()
			#var angle
			#if up_direction.y < 0:
				#angle = int(rad_to_deg((up_direction * 100).angle_to(ball.global_position - global_position)))
				##print("on the ground")
				#if angle > 0:
					#left = 1
				#else:
					#right = -1
			#else:
				#angle = int(rad_to_deg((ball.global_position - global_position).angle_to(up_direction * 100)))
				##print("upside down")
				#if angle > 0:
					#left = -1
				#else:
					#right = 
					
					
			##
			### determine which way is "left" or "right" when initially landing on a surface
			#if landed == false:
				#print('landed')
				#landed = true
				#if up_direction.y < 0:
					##print("on the ground")
					#if angle > 0:
						#left = -1
					#else:
						#right = 1
				#else:
					##print("upside down")
					#if angle > 0:
						#left = 1
					#else:
						#right = -1
			##
			# move toward the ball based on angle from the ball
			#if angle > 0:
				#input.x = left
			#elif angle < 0:
				#input.x = right
			#else:
				## jump to try and move closer to the ball
				#jump()
				#landed = false

	
	# Get the first collision object
	var raycast_collision = raycast.get_collider()
	#
	### Detecting the ball in front to jump towards
	if raycast_collision != null and raycast_collision.get_name() == "Ball":
		pressing_jump = 1
		landed = false
	else: 
		pressing_jump = 0

func defense():
	pass

func _offense_Timeout():
	jump()
	print("timer timed out, now must jump")
