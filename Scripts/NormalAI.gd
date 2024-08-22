extends "res://Scripts/player.gd"


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Max and min time before the Ai would randomly jujmp
const MAX_JUMP_TIMER = 5.0
const MIN_JUMP_TIMER = 2.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var rng = RandomNumberGenerator.new()

# Raycast for the ball detection
@onready var ball = $"/root/MainGame/Ball" as RigidBody2D
@onready var player = $"/root/MainGame/Player" 

@onready var raycast = $RayCast2D
@onready var jumpTimer = $"JumpTimer"


func _ready():
	if(jumpTimer as Timer != null):
		#jump_and_restart(false)
		pass
	
# Ran when the timer runs out, potentially changing AI movement
func _on_jump_timer_timeout():
	jump_and_restart(true)
	
# Tells Ai to execute jump if specified and start timer for the random jump
func jump_and_restart(shouldJump : bool):
	if(shouldJump):
		pressing_jump = 1
	rng.randomize()
	jumpTimer.start(rng.randf_range(MIN_JUMP_TIMER, MAX_JUMP_TIMER))

func get_input():
	
	#While on the ground
	if(grounded):
		ball = ball as Node
		if(ball != null):
			var angle = rad_to_deg(ball.position.angle_to_point(position)) - 90 + rotation_degrees #rad_to_deg(position.angle_to(ball.position))
			
			#print(int(angle))
			if(angle > 0):
				input.x = 1
			else:
				input.x = -1
	else:
		pressing_jump = 0
		
	
	# Get the first collision object
	var raycast_collision = raycast.get_collider()
	
	
	if(ball.linear_velocity.length() == 0 and raycast_collision.get_name() == "Ball"):
		pressing_jump = 1
		
	
	### Detecting the ball in front to jump towards
	if raycast_collision != null and raycast_collision.get_name() == "FrontPath":
		# Distance between the AI and path of the ball
		var dist_to_intercept = self.position.distance_to(raycast.get_collision_point())
		# Jump speed of the AI to the path of the ball
		var jump_speed_to_intercept = speed
		# Time it would take for the AI to reach the path of the ball
		var time_to_intercept = dist_to_intercept / jump_speed_to_intercept
		
		var ball_dist = ball.position.distance_to(raycast.get_collision_point())
		var ball_speed = ball.linear_velocity.length()
		var ball_time = ball_dist / ball_speed 
		
		#if(int(time_to_intercept) == int(ball_time)):
		if(time_to_intercept == ball_time):
			pressing_jump = 1
			
		print(str("time 1: ", time_to_intercept))
		print(str("time 2: ", ball_time))
		
			
		#print(jump_speed_to_intercept)
		#print(str("time: ", time_to_intercept))
		#print(str("distance: ", dist_to_intercept))
		
		pass
		
	return input.normalized()


func _on_ball_force_applied(force):
	pass
	#print("hi")
	##position = force
	#var shape = CollisionShape2D.new()
	#add_child(shape)
	#shape.global_position = Vector2.ZERO 
