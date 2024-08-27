extends "res://Scripts/player.gd"

@onready var ball = $"/root/MainGame/Ball" as RigidBody2D
@onready var player = $"/root/MainGame/Player" as CharacterBody2D

enum MOVEMENT_STATE {
	RANDOM,
	BALL_TRACKING
}

var movementState : MOVEMENT_STATE

# The instance of hte randomizer
var rng = RandomNumberGenerator.new()

# Angle between AI's rotation and the Ball
var angle : float

# The current directions of right and left
var left = -1
var right = 1

# THe current random direction of AI's movement
var random_direction = 0

func _on_enabled_timeout():
	self.process_mode = Node.PROCESS_MODE_INHERIT
	up_direction = Vector2.RIGHT
	pass



#func _init():
	#start_delay.process_mode = Node.PROCESS_MODE_ALWAYS
	#self.add_child(start_delay)
	#start_delay.autostart = true
	#start_delay.one_shot = true
	#start_delay.timeout.connect(_on_enabled_timeout)
	#pass
	
# Runs when the Node with this script is put into the game
#func _ready():
	#print("HIIIII")
	#ball.resetRound.connect(_on_ball_reset_round)
	#grounded = true
	#visibility_changed.connect(_on_debug)
	#just_grounded.connect(_on_just_grounded)

#func _on_debug():
	#pass
	
func _process(delta):
	queue_redraw()
	
#func _on_just_grounded():
	#random_direction = 0
# Run when the class is instantiated

#func _init():
	#just_grounded.connect(_on_just_grounded)

	
func _draw():
	return
	draw_set_transform_matrix(global_transform.affine_inverse())
	draw_line(Vector2.ZERO, up_direction * 100, Color.GREEN, 2.0)
	draw_line(Vector2.ZERO, (%Player.global_position - global_position), Color.BLUE, 2.0)
	draw_line(Vector2.ZERO, (ball.global_position - global_position), Color.DARK_MAGENTA, 2.0)

#func _on_just_grounded():
	#print("just grounded !")
	#pass
	
## Ran when the timer runs out, potentially changing AI movement
#func _on_jump_timer_timeout():
	#jump_and_restart(true, )
	
	
# Determine which way is "left" or "right", as well as angle between the player's rotation and ball
func focus_on(target : Node2D):
	if up_direction.y < 0:
		angle = int(rad_to_deg((up_direction * 100).angle_to(target.global_position - global_position)))
		#print("on the ground")
		if angle > 0:
			left = 1
		else:
			right = -1
	else:
		angle = int(rad_to_deg((target.global_position - global_position).angle_to(up_direction * 100)))
		#print("upside down")
		if angle > 0:
			left = -1
		else:
			right = 1

#func round_delay(timer : Timer):
	## Make AI visible but disables on start
	#self.visible = true
	#self.process_mode = Node.PROCESS_MODE_DISABLED
	#timer.start(PROCESS_DELAY)
	#pass


# Moves AI towards the target
func move(target):
	focus_on(target)
	if angle > 0:
		input.x = left
	elif angle < 0:
		input.x = right


# Moves AI in the random direction
func random_move():
	if(random_direction != 0):
		input.x = random_direction
	else:
		rng.randomize()
		var num = rng.randi_range(1,2)
		if(num == 1):
			random_direction = 1
		else:
			random_direction = -1
		input.x = random_direction
		


# Moves the AI depending on the AI's movement type
func choose_movement(target):
	if(movementState == MOVEMENT_STATE.BALL_TRACKING):
		move(target) # Make movement towards the ball
	elif(movementState == MOVEMENT_STATE.RANDOM):
		random_move() # Make a random movement
	
	
# Move the AI either randomly or towards the ball depending on the chance
# Chance determines how likely the AI will go towards the ball, otherwise randomly
func track_or_random_move(chance_to_ball = 50):
	rng.randomize()
	var result_chance = rng.randi_range(0, 100)
	if(result_chance < chance_to_ball):
		movementState = MOVEMENT_STATE.BALL_TRACKING
	else:
		movementState == MOVEMENT_STATE.RANDOM
		

# Starts the random jump timer that sholud be handled in the child notes
func start_random_jump_timer(timer : Timer, min_time = 5.0, max_time = 7.0):
	if(timer != null):
		rng.randomize()
		timer.stop()
		timer.start(rng.randf_range(min_time, max_time))
		return timer.time_left
	return 0


# Returns whether the Ai looks straight towards the ball even through the obstacles 
# All angles are in degrees
func aligned_towards_target(target : Node2D, min_angle = -5, max_angle = 5):
	focus_on(target)
	return angle > min_angle and angle < max_angle


# Checks whether it is possible to catch the target while the ball is moving.
# Error times allow for AI a chance to slightly/largely miss for realism
func can_catch_target(target : Node2D, raycast : RayCast2D, time_error = 0.0):
	# Get the first collision object
	var raycast_collision = raycast.get_collider()
	
	#if(ball.linear_velocity.length() == 0 and raycast_collision.get_name() == "Ball"):
		#pressing_jump = 1
	
	#correct_direction()
	#if (angle == 0):
		#print("jump")
		
	### Detecting the target in front to jump towards
	if target != null and raycast_collision != null and raycast_collision.get_name() == "FrontPath":
		# Distance between the AI and path of the target
		var dist_to_intercept = self.position.distance_to(raycast.get_collision_point())
		# Jump speed of the AI to the path of the target
		var jump_speed_to_intercept = speed
		# Time it would take for the AI to reach the path of the target
		var time_to_intercept = dist_to_intercept / jump_speed_to_intercept
		
		# Distance between the target and the predicted AI position along target path
		var target_dist = target.position.distance_to(raycast.get_collision_point())
		# Speed for the target to reach the predicted AI position along target path
		var target_speed = 0  
		if((target as RigidBody2D) != null and (target as RigidBody2D).appliedForce != null): # If catch ball
			target_speed = target.appliedForce.length()
		elif(target.speed != 0): # If catch player
			target_speed = speed
		# Time the target will take to reach the predicted AI position along ball path
		var target_time = target_dist / target_speed 
		
		# Introducing randomness to the catching so that the AI might miss
		#rng.randomize()
		#ball_time = rng.randf_range(ball_time - time_error, ball_time + time_error)
		
		# Rounding the time values for easier comparison
		time_to_intercept = snappedf(time_to_intercept, 0.1)
		target_time = snappedf(target_time, 0.1)
		
		#print(str("dist 1: ", dist_to_intercept))
		#print(str("dist 2: ", target_dist))
				
		print(str("time 1: ", time_to_intercept))
		print(str("time 2: ", target_time))
		#
		#print(str("speed 1: ", jump_speed_to_intercept))
		#print(str("speed 2: ", target_speed))
		
		
		#print(jump_speed_to_intercept)
		#print(str("time: ", time_to_intercept))
		#print(str("distance: ", dist_to_intercept))
		
		# If both times match, notify that Ai can catch the ball
		#if(time_to_intercept == ball_time):
		if(time_to_intercept >= target_time - time_error and 
		time_to_intercept <= target_time + time_error):
			return true
			
	
	return false
		
