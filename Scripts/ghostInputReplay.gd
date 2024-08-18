extends CharacterBody2D

var grav = -500
var speed = 1000
var accel = 10

# References children nodes once they exist in the scene
@onready var anim_tree = $AnimationTree
@onready var state_machine = anim_tree["parameters/playback"]

var input : Vector2
var playerInput : Vector2
var perpendicular : Vector2
var grounded = true
var rotationAngle = 0.0
var startPos = position

var inputs : Array
var timeBeforeInputs : Array
@export var timeToSwapJump : Array
var timeElapsed = 0
var index = 0
var jumpIndex = 0
var isJumping = false
var gameStart = true

var timer : Timer = Timer.new()
var jumpTimer : Timer = Timer.new()

# keeps track of the current animation
var current_anim = ""

func _ready():
	timer.one_shot = true
	timer.autostart = true
	timer.wait_time = 0
	timer.timeout.connect(_timer_Timeout)
	add_child(timer)
	
	jumpTimer.one_shot = true
	jumpTimer.autostart = true
	jumpTimer.wait_time = 0
	jumpTimer.timeout.connect(_jumptimer_Timeout)
	add_child(jumpTimer)
	
	get_tree().current_scene.get_node("Ball").resetRound.connect(_on_reset_round)

	
# Player Movement proccessing and collisions
func _process(delta):
# Player Input -> movement mapping
	# Timer
	if inputs.size() == 0:
		return
		
	#if timeToSwapJump.size()-1 < jumpIndex:
	#	isJumping = false
	#	print("No More Jumps")
		
	#if index > timeBeforeInputs.size() - 1:
	#	perpendicular = Vector2.ZERO
		
	# Jump
	if isJumping && timeToSwapJump.size() > 0:
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
		velocity += (up_direction * (speed / 1.2) )


func _on_reset_round():
	index = 0
	jumpIndex = 0
	position = startPos
	grounded = true
	perpendicular = Vector2(0, 0)
	up_direction = Vector2.UP
	rotationAngle = 0.0

# changes current animation to a new animation
func change_anim(name):
	if name != current_anim:
		state_machine.travel(name)
		current_anim = name
		
func _timer_Timeout():
	if index > timeBeforeInputs.size() - 1:
		self.self_modulate.a = 0.5
		playerInput = Vector2.ZERO
		return
	playerInput = inputs[index]
	timer.wait_time = timeBeforeInputs[index]
	index += 1
	timer.start()
	
func _jumptimer_Timeout():
	if timeToSwapJump.size() == 0:
		return
		
	if isJumping:
		isJumping = false
	else:
		isJumping = true
	
	if jumpIndex < (timeToSwapJump.size()) -1:
		jumpTimer.wait_time = timeToSwapJump[jumpIndex]
		jumpTimer.start()
		jumpIndex += 1
		print("Start new timer")
	else:
		isJumping = false
		
		

