extends Node2D

@onready var pause_menu = $"../inGameMenu"
var paused = false

@export var winsRequired = 5
var playerScore = 0
var aiScore = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("pause") && $"../inGameMenu".on_pause_menu:
		_pause_menu()
	elif  Input.is_action_just_pressed("pause") && $"../inGameMenu".on_setting_menu:
		$"../inGameMenu"._on_back_pressed()


func _on_ball_reset_round():
	print("You: ", playerScore, " | AI: ", aiScore)
	$"../Score/AILabelScore".text = str(aiScore)
	$"../Score/PlayerLabelScore".text = str(playerScore)
	if playerScore > winsRequired:
		# Do player win stuff here...
		print("You Win")
		pass
	elif aiScore > winsRequired:
		# Player lose here...
		print("You Lose")
		pass


func _pause_menu():
	if paused:
		pause_menu.hide()
		Engine.time_scale = 1
	else:
		pause_menu.show()
		Engine.time_scale = 0
	paused = !paused
