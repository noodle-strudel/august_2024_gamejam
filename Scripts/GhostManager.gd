extends CharacterBody2D

@export var grav = -500
@export var speed = 750
@export var accel = 10

# References children nodes once they exist in the scene
@onready var anim_tree = $AnimationTree
# @onready var state_machine = anim_tree["parameters/playback"]

const ghostScene = preload("res://ghost.tscn")

var input : Vector2
var playerInput : Vector2
var perpendicular : Vector2
var grounded = true
var rotationAngle = 0.0
var startPos = position
var inputs : Array
var timeBeforeInputs : Array
var timeElapsed = 0
var lastInput : Vector2
var timeSinceJumpChange : Array
var jumpTimeElapsed = 0
var isJumping = false
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
		inputs.append(playerInput)
		timeBeforeInputs.append(timeElapsed)
		timeElapsed = 0
		lastInput = playerInput
	
	# Jump
	if Input.get_action_strength("jump") > 0 && isJumping == false:
		timeSinceJumpChange.append(jumpTimeElapsed)
		isJumping = true
		jumpTimeElapsed = 0
	elif isJumping == true:
		timeSinceJumpChange.append(jumpTimeElapsed)
		isJumping = false
		jumpTimeElapsed = 0

func _on_ball_reset_round():
	createGhost(inputs, timeBeforeInputs)
	timeElapsed = 0
	

# changes current animation to a new animation
func change_anim(name):
	if name != current_anim:
		# state_machine.travel(name)
		current_anim = name

func createGhost(ghostInputs: Array, timeSinceInputs: Array):
	if (gameStart == true):
		gameStart = false
		return
	print("Making Ghost!")
	numOfGhosts += 1
	add_child(ghostScene.instantiate())
	var lastChild = (get_child_count() - 1)
	var ghost = get_child(lastChild).get_child(0)

	var index = 0
	for i in ghostInputs:
		ghost.inputs.append(i)
		ghost.timeBeforeInputs.append(timeBeforeInputs[index])
		index += 1
		
	for i in timeSinceJumpChange:
		ghost.timeToSwapJump.append(i)
	
	ghost.set_collision_layer_value(numOfGhosts + 3, 1)
	
	inputs.clear()
	timeBeforeInputs.clear()
	timeSinceJumpChange.clear()
