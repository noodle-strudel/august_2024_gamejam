extends Node2D
signal gamePaused

@onready var pause_menu = $"../CanvasLayer/inGameMenu"
var paused = false

@export var winsRequired = 5
var playerScore = 0
var aiScore = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("pause") && $"../CanvasLayer/inGameMenu".on_pause_menu && !$"../CanvasLayer/WinLoseMenu".visible:
		_pause_menu()
	elif  Input.is_action_just_pressed("pause") && $"../CanvasLayer/inGameMenu".on_setting_menu:
		$"../CanvasLayer/inGameMenu"._on_back_pressed()
	elif Input.is_action_just_pressed("pause") && $"../CanvasLayer/inGameMenu".on_warning_menu:
		$"../CanvasLayer/inGameMenu"._on_no_pressed()


func _on_ball_reset_round():
	print("You: ", playerScore, " | AI: ", aiScore)
	$"../CanvasLayer/Score/ScoreContainer/Score/AILabelScore".text = str(aiScore)
	$"../CanvasLayer/Score/ScoreContainer/Score/PlayerLabelScore".text = str(playerScore)
	if playerScore >= winsRequired:
		# Do player win stuff here...
		$WinSound.play()
		$"../CanvasLayer/WinLoseMenu"/inGameOptions/WinLose.text = "You WON!!!"
		$"../CanvasLayer/WinLoseMenu".visible = true
		print("You Win")
		pass
	elif aiScore >= winsRequired:
		# Player lose here...
		$LoseSound.play()
		$"../CanvasLayer/WinLoseMenu"/inGameOptions/WinLose.text = "You lose :("
		$"../CanvasLayer/WinLoseMenu".visible = true
		print("You Lose")
		pass


func _pause_menu():
	if paused:
		pause_menu.hide()
		Engine.time_scale = 1
		emit_signal("gamePaused")
	else:
		pause_menu.show()
		Engine.time_scale = 0
		emit_signal("gamePaused")
	paused = !paused
