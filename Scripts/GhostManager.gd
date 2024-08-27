extends Node2D

@export var grav = -500
@export var speed = 750
@export var accel = 10

# References children nodes once they exist in the scene
# @onready var state_machine = anim_tree["parameters/playback"]

const ghostScene = preload("res://ghost.tscn")
const AIghostScene = preload("res://AIghost.tscn")

var input : Vector2
var playerInput = Vector2.ZERO
var AIinput = Vector2.ZERO
var perpendicular : Vector2
var grounded = true
var rotationAngle = 0.0

var inputs : Array
var timeBeforeInputs : Array
var timeElapsed = 0
var lastInput = Vector2.ZERO
var timeSinceJumpChange : Array
var jumpTimeElapsed = 0
var isJumping = false

var AIinputs : Array
var AItimeBeforeInputs : Array
var AItimeElapsed = 0
var AIlastInput = Vector2.ZERO
var AItimeSinceJumpChange : Array
var AIjumpTimeElapsed = 0
var AIisJumping = false
var AI : Node2D

var ghostInstance

var numOfGhosts = 0
var gameStart = false

# keeps track of the current animation
var current_anim = ""

func _ready():
	get_node("../EasyAI").ai_jump.connect(_on_aiJump)
	get_node("../NormalAI").ai_jump.connect(_on_aiJump)
	get_node("../HardAI").ai_jump.connect(_on_aiJump)
	
# Movement Input
func get_input():
	input.x = Input.get_action_strength("right") - Input.get_action_strength("left") 
	input.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	
	return input.normalized()
	
func ai_get_input():
	if GlobalSettings.difficulty == 0:
		AI = get_node("../EasyAI")
		
	if GlobalSettings.difficulty == 1:
		AI = get_node("../NormalAI")
		
	if GlobalSettings.difficulty == 2:
		AI = get_node("../HardAI")
		
	AIinput = AI.input
		
	if (AIinput != AIlastInput) and AIinput != null:
		#print("saved input: ", AIinput, " at ", AItimeElapsed)
		#print("Ai current: ", AIinput, " AI Last ", AIlastInput)
		AIinputs.append(AIinput)
		AItimeBeforeInputs.append(AItimeElapsed)
		AItimeElapsed = 0
		AIlastInput = AIinput

# Player Movement proccessing and collisions
func _physics_process(delta):
# Player Input -> movement mapping
	timeElapsed += delta
	jumpTimeElapsed += delta
	AItimeElapsed += delta
	AIjumpTimeElapsed += delta
	playerInput = get_input()
	AIinput = ai_get_input()
	
	if (playerInput != lastInput):
		inputs.append(playerInput)
		timeBeforeInputs.append(timeElapsed)
		timeElapsed = 0
		lastInput = playerInput
	
	# Jump
	if Input.is_action_just_pressed("jump") && isJumping == false:
		timeSinceJumpChange.append(jumpTimeElapsed)
		isJumping = true
		jumpTimeElapsed = 0
	elif isJumping == true:
		timeSinceJumpChange.append(jumpTimeElapsed)
		isJumping = false
		jumpTimeElapsed = 0

func _on_ball_reset_round():
	# add no input at the end of the array
	inputs.append(Vector2.ZERO)
	AIinputs.append(Vector2.ZERO)
	
	if timeSinceJumpChange.size() % 2 != 0:
		timeSinceJumpChange.append(jumpTimeElapsed)
		
	if AItimeSinceJumpChange.size() % 2 != 0:
		AItimeSinceJumpChange.append(AIjumpTimeElapsed)
	
	#print("Reset ROund")
	# record the time
	timeBeforeInputs.append(timeElapsed)
	AItimeBeforeInputs.append(timeElapsed)
	
	#print("AI STUFF: ")
	#print(AItimeBeforeInputs)
	#print(AIinputs)
	
	createGhost(inputs, timeBeforeInputs, true)
	await get_tree().process_frame
	createGhost(AIinputs, AItimeBeforeInputs, false)
	timeElapsed = 0
	AItimeElapsed = 0
	

# changes current animation to a new animation
func change_anim(name):
	if name != current_anim:
		# state_machine.travel(name)
		current_anim = name

func createGhost(ghostInputs: Array, timeSinceInputs: Array, isPlayer: bool):
	numOfGhosts += 1
	
	if isPlayer:
		ghostInstance = ghostScene.instantiate()
	else:
		ghostInstance = AIghostScene.instantiate()
	
	# it cannot add the child until the tree has some idle time.
	call_deferred("add_child", ghostInstance)
	
	# wait until after the tree has added the child
	await get_tree().process_frame
	var lastChild = (get_child_count() - 1)
	var ghost = get_child(lastChild)
	var index = 0
	
	if isPlayer:
		ghost.startPos = %Player.startPos
		ghost.position = %Player.startPos
		ghost.startUpDirection = Vector2.LEFT
		for i in ghostInputs:
			ghost.inputs.append(i)
			ghost.timeBeforeInputs.append(timeBeforeInputs[index])
			index += 1
			
			
		for i in timeSinceJumpChange:
			ghost.timeToSwapJump.append(i)
			
		#print("Player Inputs Added")
		
		if numOfGhosts + 4 > 10:
			var collisionLayer = get_child(0).collision_layer
			#print("Too many ghosts deleting ", get_child(0))
			get_child(0).queue_free()
			ghost.set_collision_layer_value(collisionLayer, 1)
		else:
			ghost.set_collision_layer_value(numOfGhosts + 4, 1)
			
		inputs.clear()
		timeBeforeInputs.clear()
		timeSinceJumpChange.clear()
		
	else:
		ghost.startPos = AI.startPos
		ghost.position = AI.startPos
		ghost.startUpDirection = Vector2.RIGHT
		for i in ghostInputs:
			ghost.inputs.append(i)
			ghost.timeBeforeInputs.append(AItimeBeforeInputs[index])
			index += 1
			
		for i in AItimeSinceJumpChange:
			ghost.timeToSwapJump.append(i)
		
		#print("AI Inputs Added")
		
		if numOfGhosts + 4 > 10:
			var collisionLayer = get_child(0).collision_layer
			#print("Too many ghosts deleting ", get_child(0))
			get_child(0).queue_free()
			ghost.set_collision_layer_value(collisionLayer, 1)
		else:
			ghost.set_collision_layer_value(numOfGhosts + 4, 1)
	
		AIinputs.clear()
		AItimeBeforeInputs.clear()
		AItimeSinceJumpChange.clear()
	
	ghost.up_direction = ghost.startUpDirection
	
func _on_aiJump(value):
	if AI:
		if AI.pressing_jump && AIisJumping == false:
			AItimeSinceJumpChange.append(AIjumpTimeElapsed)
			AIisJumping = true
			AIjumpTimeElapsed = 0
		elif AI.pressing_jump == 0 && AIisJumping == true:
			AItimeSinceJumpChange.append(AIjumpTimeElapsed)
			AIisJumping = false
			AIjumpTimeElapsed = 0
