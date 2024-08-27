extends "res://Scripts/AI.gd"


const ERROR_CATCH_TIME = 0.1

# determins if the offensive_timer is a child
var offensive_timer = false

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

var state = STATE.NORMAL

func _ready():
	just_grounded.connect(_on_just_grounded)
	#up_direction = Vector2.RIGHT
	pass
	
#func focus_on(target : Node2D):
	#if up_direction.y < 0:
		#angle = int(rad_to_deg((up_direction * 100).angle_to(target.global_position - global_position)))
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
			#right = 1
	
	
# determine which way is "left" or "right" when initially landing on a surface
func _on_just_grounded():
	if up_direction.y < 0:
		#print("on the ground")
		if angle > 0:
			left = -1
		else:
			right = 1
	else:
		#print("upside down")
		if angle > 0:
			left = 1
		else:
			right = -1
	
	
# Overriding the input for ai
func get_input():
	
	# Change the behavior of the AI based on the ball's global position
	if ball.global_position.x > 384: # close to the player's goal
		state = STATE.OFFENSE
	elif ball.global_position.x < -384: # close to the AI's goal
		state = STATE.DEFENSE
	else: # in the middle
		state = STATE.NORMAL
	defense()
	## change behavior based on the state of the AI
	match state:
		STATE.NORMAL:
			if offensive_timer:
				for child in get_children():
					if child.name == "OffenseJumpTimer":
						child.queue_free()
						offensive_timer = false
			normal()
		STATE.OFFENSE:
			if offensive_timer == false:
				offense_jump_timer = Timer.new()
				offense_jump_timer.autostart = true
				offense_jump_timer.wait_time = 5
				offense_jump_timer.name = "OffenseJumpTimer"
				offense_jump_timer.timeout.connect(_offense_Timeout)
				add_child(offense_jump_timer)
				offensive_timer = true
			normal()
		STATE.DEFENSE:
			if offensive_timer:
				for child in get_children():
					if child.name == "OffenseJumpTimer":
						child.queue_free()
						offensive_timer = false
			defense()
	
	
	return input.normalized()

func normal():
	if(grounded):
		focus_on(ball)
		move(ball)
		print(angle)
			
		var catchable = can_catch_target(ball, raycast)
		var aligned = aligned_towards_target(ball)
		
		if (catchable or aligned):
			pressing_jump = 1
		else: 
			pressing_jump = 0
		
func defense():
	#print("up direction: ", up_direction)
	if(grounded):
		focus_on(ball)
		move(ball)
	
		var player_catchable = can_catch_target(player, raycast, 0.2)# and player.pressing_jump == 1
		var player_aligned = aligned_towards_target(player)
		var ball_aligned = aligned_towards_target(ball)
		#print(player.grounded)
		if ((player_catchable and !player.grounded) or ball_aligned or player_aligned):
			pressing_jump = 1
		else: 
			pressing_jump = 0

func _offense_Timeout():
	jump()
	print("timer timed out, now must jump")
