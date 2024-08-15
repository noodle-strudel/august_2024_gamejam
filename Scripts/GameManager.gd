extends Node2D

@export var winsRequired = 5
var playerScore = 0
var aiScore = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_ball_reset_round():
	print("You: ", playerScore, " | AI: ", aiScore)
	if playerScore > winsRequired:
		# Do player win stuff here...
		print("You Win")
		pass
	elif aiScore > winsRequired:
		# Player lose here...
		print("You Lose")
		pass
