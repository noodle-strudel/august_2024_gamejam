extends CharacterBody2D

var grav = -500
var speed = 1000
var accel = 10

# References children nodes once they exist in the scene
@onready var anim_tree = $AnimationTree
@onready var state_machine = anim_tree["parameters/playback"]

var playerInput : Vector2
var perpendicular : Vector2
var grounded = true
var rotationAngle = 0.0
var startPos = Vector2(480, 248)

var inputs : Array
var timeBeforeInputs : Array
@export var timeToSwapJump : Array

# index for the inputs array
var index = 0

# index for the timeBeforeInputs array
var inputTimeIndex = 0
var jumpIndex = 0
var isJumping = false

# determine if the round just started or not
var gameStart = true

# when initiateGhost is 2, then gameStart is false
var initiateGhost = 0

var timer : Timer = Timer.new()
var jumpTimer : Timer = Timer.new()

# keeps track of the current animation
var current_anim = ""

func _ready():
	# allow the GhostManager to pass the input arrays into self
	await get_tree().create_timer(0.5).timeout
	
	# initiate timer if there are any movement inputs
	if inputs.size():
		timer.one_shot = true
		timer.autostart = true
		timer.wait_time = 0.01
		timer.name = "InputTimer"
		timer.timeout.connect(_timer_Timeout)
		add_child(timer)
	
	jumpTimer.one_shot = true
	jumpTimer.autostart = true
	jumpTimer.wait_time = 0.01
	jumpTimer.name = "JumpTimer"
	jumpTimer.timeout.connect(_jumptimer_Timeout)
	add_child(jumpTimer)
	get_tree().current_scene.get_node("Ball").resetRound.connect(_on_reset_round)

	
# Player Movement proccessing and collisions
func _process(delta):
# Player Input -> movement mapping
		
	#if timeToSwapJump.size()-1 < jumpIndex:
	#	isJumping = false
	#	print("No More Jumps")
		
	#if index > timeBeforeInputs.size() - 1:
	#	perpendicular = Vector2.ZERO
		
	# Jump
	if isJumping and timeToSwapJump.size() > 0:
		velocity = up_direction * speed
		grounded = false
		change_anim("jump")
		isJumping = false
	
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
		isJumping = false
		change_anim("sliding")
		
		rotation_degrees = rad_to_deg(atan2(up_direction.y, up_direction.x)) + 90
		up_direction = collision.get_normal()
		velocity += (up_direction * (speed / 1.2) )


func _on_reset_round():
	index = 0
	jumpIndex = 0
	inputTimeIndex = 0
	position = startPos
	grounded = true
	perpendicular = Vector2(0, 0)
	up_direction = Vector2.UP
	rotationAngle = 0.0
	initiateGhost = 0
	gameStart = true
	$InputTimer.wait_time = 0.01
	$InputTimer.start()
	$JumpTimer.wait_time = 0.01
	$JumpTimer.start()
	

# changes current animation to a new animation
func change_anim(name):
	if name != current_anim:
		state_machine.travel(name)
		current_anim = name


func _timer_Timeout():
	#print("index: ", index, " size of input array: ", timeBeforeInputs.size())
	if is_initiated():
		if inputTimeIndex < timeBeforeInputs.size():
			playerInput = inputs[index]
			index += 1
			timer.wait_time = timeBeforeInputs[inputTimeIndex]
			#print(index, ": Change movement after ", timeBeforeInputs[inputTimeIndex])
			inputTimeIndex += 1
			timer.start()
			
		else:
			# modulate the sprite to become partially transparent
			$Sprite2D.self_modulate.a = 0.5
			playerInput = Vector2.ZERO
	else:
		timer.wait_time = timeBeforeInputs[inputTimeIndex]
		#print(inputTimeIndex, ": Change movement after ", timeBeforeInputs[inputTimeIndex])
		inputTimeIndex += 1
		timer.start()

func _jumptimer_Timeout():
	if timeToSwapJump.size() == 0:
		return
	
	# check if the ghost is ready to jump
	if is_initiated():
		print("jump")
		isJumping = true
		
	
	#print("jumpIndex: ", jumpIndex, "timeToSwapJump Size: ", timeToSwapJump.size())
	if jumpIndex < timeToSwapJump.size():
		jumpTimer.wait_time = timeToSwapJump[jumpIndex]
		jumpTimer.start()
		#print(jumpIndex, ": Jump after ", timeToSwapJump[jumpIndex])
		jumpIndex += 1
	else:
		print("ghost end of jumping")


func is_initiated() -> bool:
	if initiateGhost == 2:
		gameStart = false
		return true
	else:
		initiateGhost += 1
		return false
