extends "res://Scripts/player.gd"

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var left = 1
var right = -1
var landed = false

# determins if the offensive_timer is a child
var offensive_timer = false

# Raycast for the ball detection
@onready var raycast = $RayCast2D

@onready var ball = $"/root/MainGame/Ball" 
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

func _draw():
	return
	draw_set_transform_matrix(global_transform.affine_inverse())
	draw_line(Vector2.ZERO, up_direction * 100, Color.GREEN, 2.0)
	draw_line(Vector2.ZERO, ball.appliedForce, Color.BLUE, 2.0)
	draw_line(Vector2.ZERO, (ball.global_position - global_position), Color.DARK_MAGENTA, 2.0)

func _ready():
	ball.resetRound.connect(_on_ball_reset_round)

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
	
	return input.normalized()

func normal():
	#print("up direction: ", up_direction)
	if(grounded):
		ball = ball as Node
		if(ball != null):
			var angle
			if up_direction.y < 0:
				angle = int(rad_to_deg((up_direction * 100).angle_to(ball.global_position - global_position)))
				#print("on the ground")
				if angle > 0:
					left = 1
				else:
					right = -1
			else:
				angle = int(rad_to_deg((ball.global_position - global_position).angle_to(up_direction * 100)))
				#print("upside down")
				if angle > 0:
					left = -1
				else:
					right = 1
			
			#print(ball.global_position - global_position)
			#print("angle to ball: ", int(angle))
			
			# determine which way is "left" or "right" when initially landing on a surface
			if landed == false:
				
				landed = true
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
			
			# move toward the ball based on angle from the ball
			if angle > 0:
				input.x = left
			elif angle < 0:
				input.x = right
			else:
				# jump to try and move closer to the ball
				jump()
				landed = false

	
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
