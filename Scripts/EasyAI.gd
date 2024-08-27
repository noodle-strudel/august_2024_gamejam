extends "res://Scripts/AI.gd"



# Raycast for the ball detection
@onready var raycast = $RayCast2D
# The timer that triggers random jumpng
@onready var jumpTimer = $JumpTimer

const CHANCE_TO_CHASE_BALL = 100
const MIN_RANDOM_JUMP_TIME = 1
const MAX_RANDOM_JUMP_TIME = 5
const ERROR_CATCH_TIME = 0.3

# Randomly jumps when the timer runs out
func _on_jump_timer_timeout():
	pressing_jump = 1
	emit_signal("ai_jump", 1)

func _on_just_grounded():
	track_or_random_move(CHANCE_TO_CHASE_BALL)
	
	start_random_jump_timer(jumpTimer, MIN_RANDOM_JUMP_TIME, MAX_RANDOM_JUMP_TIME)

func _ready():	
	track_or_random_move(CHANCE_TO_CHASE_BALL)
	
	start_random_jump_timer(jumpTimer, MIN_RANDOM_JUMP_TIME, MAX_RANDOM_JUMP_TIME)
	jumpTimer.timeout.connect(_on_jump_timer_timeout)
	
	just_grounded.connect(_on_just_grounded)


# Overriding the input for ai
func get_input():
	if(grounded and !start_grounded):
		choose_movement(ball)
		var catchable = can_catch_target(ball, raycast, ERROR_CATCH_TIME)
		var aligned = aligned_towards_target(ball) 
		# Makes the player jump when it sees the ball ahead of it the even through walls 
		if(catchable or aligned):
			pressing_jump = 1
			emit_signal("ai_jump", 1)
			pass
	else:
		pressing_jump = 0
		emit_signal("ai_jump", 0)
	
	## Move if grounded
	#if(grounded):
		#input.x = inputAi.x
		##input.y = 0
	#else:
		#pressing_jump = 0
	#
	## Get the first collision object
	#var raycast_collision = raycast.get_collider()
	#
		#
	#rng.randomize() 
	## Detecting the ball in front to jump towards
	#if raycast_collision != null and raycast_collision.get_name() == "Ball":
		#pressing_jump = 1
		#
	#queue_redraw()
	#_draw()
	
	return input.normalized()


## Ran when the timer runs out, potentially changing AI movement
#func _on_move_timer_timeout():
	#move_and_restart()
	#
#func move_and_restart():
	#rng.randomize()
	#
	#inputAi.x = rng.randi_range(-1, 1) # randomly moves left, right or stays stills
	##pressing_jump = 1
	#
	#moveTimer.start(rng.randi_range(t_min, t_max))

