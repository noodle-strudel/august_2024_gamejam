extends CharacterBody2D

@export var grav = -500
@export var speed = 750
@export var accel = 10

# References children nodes once they exist in the scene
@onready var anim_tree = $AnimationTree
@onready var state_machine = anim_tree["parameters/playback"]

var input : Vector2
var gravDir : Vector2
var playerInput : Vector2
var perpendicular : Vector2
var grounded = true
var rotationAngle = 0.0

# keeps track of the current animation
var current_anim = ""

# Movement Input
func get_input():
	input.x = Input.get_action_strength("right") - Input.get_action_strength("left") 
	input.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	
	return input.normalized()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
# Player Input -> movement mapping
	playerInput = get_input()
	
	# Jump
	if Input.get_action_strength("jump") > 0:
		velocity = up_direction * speed
		grounded = false
		change_anim("jump")
	
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
		change_anim("sliding")
		
		rotation_degrees = rad_to_deg(atan2(up_direction.y, up_direction.x)) + 90
		up_direction = collision.get_normal()
		
		velocity += (up_direction * (speed / 0.9) )

# changes current animation to a new animation
func change_anim(name):
	if name != current_anim:
		state_machine.travel(name)
		current_anim = name
