extends "res://Scripts/player.gd"


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready
var raycast = $RayCast2D
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var rng = RandomNumberGenerator.new()

@onready
var t = $MoveTimer
var t_max = 5
var t_min = 3

var x : int

func _ready():
	x = rng.randi_range(-1, 1)
	t.start(rng.randi_range(t_min, t_max))


func _on_move_timer_timeout():
	#print(t.wait_time)
	rng.randomize()
	x = rng.randi_range(-1, 1)
	
	
# Overriding the input for ai
func get_input():
	#print(t.time_left)
	
	#print(grounded)
	if(grounded):
		input.x = x
		#input.y = 0
	
	# Get the first collision object
	var raycast_collision = raycast.get_collider()
	
		
	# Jump if 
	if raycast_collision != null and raycast_collision.get_name() == "Ball":#.is_in_group("ball_type"):
		pressing_jump = 1
	else: 
		pressing_jump = 0
		
		
	return input.normalized()


