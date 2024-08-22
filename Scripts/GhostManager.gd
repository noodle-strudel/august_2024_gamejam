extends Node2D

@export var grav = -500
@export var speed = 750
@export var accel = 10

# References children nodes once they exist in the scene
# @onready var state_machine = anim_tree["parameters/playback"]

const ghostScene = preload("res://ghost.tscn")

var input : Vector2
var playerInput : Vector2
var perpendicular : Vector2
var grounded = true
var rotationAngle = 0.0
var startPos = Vector2(480, 248)
var inputs : Array
var timeBeforeInputs : Array
var timeElapsed = 0
var lastInput : Vector2
var timeSinceJumpChange : Array
var jumpTimeElapsed = 0
var isJumping = true
var numOfGhosts = 0
var gameStart = true

# keeps track of the current animation
var current_anim = ""
	
# Movement Input
func get_input():
	input.x = Input.get_action_strength("right") - Input.get_action_strength("left") 
	input.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	
	return input.normalized()

# Player Movement proccessing and collisions
func _physics_process(delta):
# Player Input -> movement mapping
	timeElapsed += delta
	jumpTimeElapsed += delta
	playerInput = get_input()
	if (playerInput != lastInput):
		#print("saved input: ", playerInput, " at ", timeElapsed)
		inputs.append(playerInput)
		#print(inputs.size() - 1)
		
		timeBeforeInputs.append(timeElapsed)
		timeElapsed = 0
		lastInput = playerInput
	
	# Jump
	if Input.get_action_strength("jump") and %Player.can_save_jump:
		print("saved jump input")
		timeSinceJumpChange.append(jumpTimeElapsed)
		isJumping = true
		jumpTimeElapsed = 0
		%Player.can_save_jump = false
	#elif isJumping == true:
		#timeSinceJumpChange.append(jumpTimeElapsed)
		#isJumping = false
		#jumpTimeElapsed = 0

func _on_ball_reset_round():
	# add no input at the end of the array
	inputs.append(Vector2.ZERO)
	
	# record the time
	timeBeforeInputs.append(timeElapsed)
	
	createGhost(inputs, timeBeforeInputs)
	timeElapsed = 0
	

# changes current animation to a new animation
func change_anim(name):
	if name != current_anim:
		# state_machine.travel(name)
		current_anim = name

func createGhost(ghostInputs: Array, timeSinceInputs: Array):
	numOfGhosts += 1
	var ghostInstance = ghostScene.instantiate()
	ghostInstance.position = Vector2(480, 248)
	
	# it cannot add the child until the tree has some idle time.
	call_deferred("add_child", ghostInstance)
	
	# wait until after the tree has added the child
	await get_tree().process_frame
	var lastChild = (get_child_count() - 1)
	var ghost = get_child(lastChild)

	var index = 0
	for i in ghostInputs:
		ghost.inputs.append(i)
		ghost.timeBeforeInputs.append(timeBeforeInputs[index])
		index += 1
		
	for i in timeSinceJumpChange:
		ghost.timeToSwapJump.append(i)
	print("Saved Input Timings", ghost.timeBeforeInputs)
	print("Saved Swap Jump timings", ghost.timeToSwapJump)
	ghost.set_collision_layer_value(numOfGhosts + 3, 1)
	
	inputs.clear()
	timeBeforeInputs.clear()
	timeSinceJumpChange.clear()
