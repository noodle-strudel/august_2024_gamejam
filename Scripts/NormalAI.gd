extends "res://Scripts/player.gd"
signal aiJump(value)

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Raycast for the ball detection
@onready var raycast = $RayCast2D

@onready var ball = $"/root/MainGame/Ball" 

# Overriding the input for ai
func get_input():
	if(grounded):
		ball = ball as Node
		if(ball != null):
			var angle = rad_to_deg(ball.position.angle_to_point(position)) - 90 + rotation_degrees #rad_to_deg(position.angle_to(ball.position))
			if(angle > 0):
				input.x = 1
			else:
				input.x = -1
	
	# Get the first collision object
	var raycast_collision = raycast.get_collider()
	#
	### Detecting the ball in front to jump towards
	if raycast_collision != null and raycast_collision.get_name() == "Ball":
		pressing_jump = 1
		emit_signal("aiJump", 1)
	else: 
		pressing_jump = 0
		emit_signal("aiJump", 0)
		
	
	
	# Get the first collision object
	#var raycast_collision = raycast.get_collider()
	
		
	## Jump if 
	#if raycast_collision != null and raycast_collision.get_name() == "Ball":#.is_in_group("ball_type"):
		#pressing_jump = 1
	#else: 
		#pressing_jump = 0
		
		
	return input.normalized()


