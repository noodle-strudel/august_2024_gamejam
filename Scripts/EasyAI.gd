extends "res://Scripts/player.gd"


const SPEED = 300.0
const JUMP_VELOCITY = -400.0


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Raycast for the ball detection
@onready var raycast = $RayCast2D

# The instance of hte randomizer
var rng = RandomNumberGenerator.new()

# The timer for the random movement
@onready var moveTimer = $MoveTimer
var t_max = 5
var t_min = 2

# The timer that triggers random jumpng
@onready var jumpTimer = $JumpTimerx

# The x input of the AI
var inputAi : Vector2

func _ready():	
	#inputAi.x = rng.randi_range(-1, 1)
	#moveTimer.start(rng.randi_range(t_min, t_max))
	_on_move_timer_timeout()

# Ran when the timer runs out, potentially changing AI movement
func _on_move_timer_timeout():
	rng.randomize()
	
	inputAi.x = rng.randi_range(-1, 1) # randomly moves left, right or stays stills
	pressing_jump = 1
	
	moveTimer.start(rng.randi_range(t_min, t_max))
	
# Overriding the input for ai
func get_input():
	
	# Move if grounded
	if(grounded):
		input.x = inputAi.x
		#input.y = 0
	else:
		pressing_jump = 0
	
	# Get the first collision object
	var raycast_collision = raycast.get_collider()
	
		
	rng.randomize() 
	# Detecting the ball in front to jump towards
	if raycast_collision != null and raycast_collision.get_name() == "Ball":
		pressing_jump = 1
		
		
	return input.normalized()


