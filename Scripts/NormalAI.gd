extends "res://Scripts/player.gd"


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var ball = $"/root/MainGame/Ball"

# Overriding the input for ai
func get_input():
	if(grounded):
		print(ball)
		#input.x = x
		#input.y = 0
		
	else:
		pass
	
	
	# Get the first collision object
	#var raycast_collision = raycast.get_collider()
	
		
	## Jump if 
	#if raycast_collision != null and raycast_collision.get_name() == "Ball":#.is_in_group("ball_type"):
		#pressing_jump = 1
	#else: 
		#pressing_jump = 0
		
		
	return input.normalized()


