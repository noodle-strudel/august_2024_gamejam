extends "res://Scripts/AI.gd"

const CHANCE_TO_CHASE_BALL = 100
const CATCH_TIME_ERROR = 2.0

@onready var raycast = $RayCast2D
@onready var jumpTimer = $"JumpTimer"

func _ready():
	if(jumpTimer as Timer != null):
		#jump_and_restart(false)
		pass

func _on_just_grounded():
	track_or_random_move(CHANCE_TO_CHASE_BALL)
	
func get_input():
	#While on the ground
	if(grounded):
		move()
		var catchable = can_catch_ball(raycast, CATCH_TIME_ERROR)
		var aligned = aligned_towards_ball()
		
		if(catchable or aligned):
			pressing_jump = 1
		else:
			pressing_jump = 0
			
		#var angle = rad_to_deg(ball.position.angle_to_point(position)) - 90 + rotation_degrees #rad_to_deg(position.angle_to(ball.position))
		#
		##print(int(angle))
		#if(angle > 0):
			#input.x = 1
		#else:
			#input.x = -1
		
		
		#pathing_to_ball()
		pass
	else:
		pressing_jump = 0

	#try_catch_ball(raycast, MIN_CATCH_TIME_ERROR, MAX_CATCH_TIME_ERROR)
		
	return input.normalized()

func _on_ball_force_applied(force):
	pass
	#print("hi")
	##position = force
	#var shape = CollisionShape2D.new()
	#add_child(shape)
	#shape.global_position = Vector2.ZERO 
