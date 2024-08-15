extends CharacterBody2D

@export var grav = -500
@export var speed = 750
@export var accel = 10

var input : Vector2
var playerInput : Vector2
var perpendicular : Vector2
var grounded = true
var rotationAngle = 0.0
var startPos = position

# Movement Input
func get_input():
	input.x = Input.get_action_strength("right") - Input.get_action_strength("left") 
	input.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	
	return input.normalized()

# Player Movement proccessing and collisions
func _process(delta):
# Player Input -> movement mapping
	playerInput = get_input()
	
	# Jump
	if Input.get_action_strength("jump") > 0:
		velocity = up_direction * speed
		grounded = false
	
	# Reset
	if playerInput == Vector2.ZERO:
		perpendicular = Vector2.ZERO
		
	# Left
	if playerInput.x < 0:
		perpendicular.x = up_direction.y 
		perpendicular.y = up_direction.x * playerInput.x
	
	# Right
	if playerInput.x > 0:
		perpendicular.x = -up_direction.y 
		perpendicular.y = -up_direction.x * -playerInput.x
		
	# Apply Movement + Gravity when on ground
	if grounded:
		velocity = lerp(velocity, perpendicular * speed, delta * accel)
		velocity += up_direction * grav
	
	# Check for wall and change gravity direction
	var collision = move_and_collide(velocity * delta)
	if collision:
		grounded = true
		rotation_degrees = rad_to_deg(atan2(up_direction.y, up_direction.x)) + 90
		up_direction = collision.get_normal()
		velocity += (up_direction * (speed / 1.2) )


func _on_ball_reset_round():
	position = startPos
	grounded = true
	perpendicular = Vector2(0, 0)
	up_direction = Vector2.UP
	rotationAngle = 0.0
