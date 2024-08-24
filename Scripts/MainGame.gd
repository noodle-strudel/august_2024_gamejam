extends Node2D

# handles round stuff
@onready var time_ui = $CanvasLayer/Score/TimerContainer/VBoxContainer/TimeLeft
@onready var round_time = $RoundTimer
@onready var ball = %Ball

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time_ui.text = str(ceil(round_time.time_left))
	if round_time.time_left <= 20:
		time_ui.set("theme_override_colors/font_color", Color.GOLD)
	else:
		time_ui.set("theme_override_colors/font_color", Color.WHITE)


func _on_round_timer_timeout():
	ball.reset = true


func _on_ball_reset_round():
	round_time.start()


func _on_ball_boundary_body_exited(body):
	if body.name == "Ball":
		body.position = Vector2.ZERO


func _on_crowd_finished():
	for sprite in get_tree().get_nodes_in_group("audience"):
		sprite.play("idle")
