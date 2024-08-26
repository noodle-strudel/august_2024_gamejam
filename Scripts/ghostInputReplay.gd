extends CharacterBody2D

var grav = -500
@export var speed = 1000
var accel = 10

# References children nodes once they exist in the scene
@onready var anim_tree = $AnimationTree
@onready var state_machine = anim_tree["parameters/playback"]

var playerInput : Vector2
var perpendicular : Vector2
var grounded = true
var rotationAngle = 0.0
var startPos
var paused = false
var startUpDirection : Vector2

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
	
	up_direction = startUpDirection
	
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
	get_tree().current_scene.get_node("GameManager").gamePaused.connect(_on_pause_toggle)

	
# Player Movement proccessing and collisions
func _process(delta):
# Player Input -> movement mapping
		
	#if timeToSwapJump.size()-1 < jumpIndex:
	#	isJumping = false
	#	print("No More Jumps")
		
	#if index > timeBeforeInputs.size() - 1:
	#	perpendicular = Vector2.ZERO
		
	# Jump
	if timeBeforeInputs.size() <= inputTimeIndex && timeToSwapJump.size() <= jumpIndex:
		self.visible = false
		position.y = -3000
	else:
		self.visible = true
		$Sprite2D.self_modulate.a = 0.5
	if isJumping and timeToSwapJump.size() > 0:
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
	inputTimeIndex = 0
	isJumping = false
	position = startPos
	grounded = true
	perpendicular = Vector2.ZERO
	playerInput = Vector2.ZERO
	up_direction = startUpDirection
	rotationAngle = 0.0
	initiateGhost = 0
	gameStart = true
	
	if timeToSwapJump.size() > 1:
		jumpTimer.wait_time = 0.01
		jumpTimer.start()
	
	if timeBeforeInputs.size() > 1:
		timer.wait_time = 0.01
		timer.start()

# changes current animation to a new animation
func change_anim(name):
	if name != current_anim:
		state_machine.travel(name)
		current_anim = name


func _timer_Timeout():
	if is_initiated() && inputs.size() > 1:
		if inputTimeIndex < timeBeforeInputs.size():
			playerInput = inputs[index]
			timer.wait_time = timeBeforeInputs[inputTimeIndex]
			inputTimeIndex += 1
			timer.start()
			index += 1
		else:
			playerInput = Vector2.ZERO
	elif timeBeforeInputs.size() > 0 && timeBeforeInputs.size() > 0 && timeBeforeInputs.size() > inputTimeIndex:
		timer.wait_time = timeBeforeInputs[inputTimeIndex]
		inputTimeIndex += 1
		timer.start()

func _jumptimer_Timeout():
	if timeToSwapJump.size() == 0:
		return
	
	# check if the ghost is ready to jump
	if is_initiated():
		if isJumping:
			isJumping = false
		else:
			isJumping = true
	
	#print("jumpIndex: ", jumpIndex, "timeToSwapJump Size: ", timeToSwapJump.size())
	if jumpIndex < timeToSwapJump.size():
		jumpTimer.wait_time = timeToSwapJump[jumpIndex]
		jumpTimer.start()
		#print(jumpIndex, ": Jump after ", timeToSwapJump[jumpIndex])
		jumpIndex += 1
	else:
		isJumping = false

func is_initiated() -> bool:
	if initiateGhost == 2:
		gameStart = false
		return true
	else:
		initiateGhost += 1
		return false

func _on_pause_toggle():
	if paused:
		paused = false
		timer.paused = false
		jumpTimer.paused = false
	else:
		paused = true
		timer.paused = true
		jumpTimer.paused = true
	
