extends Node2D

const AI_PROCESS_DELAY = 1

# handles round stuff
@onready var time_ui = $CanvasLayer/Score/TimerContainer/VBoxContainer/TimeLeft
@onready var round_time = $RoundTimer
@onready var ball = %Ball

# Called when the node enters the scene tree for the first time.
func _ready():
	start_game()

func start_game():
	var ai_object : CharacterBody2D
	match GlobalSettings.difficulty:
		0:
			ai_object = get_node("EasyAI")
		1:
			ai_object = get_node("NormalAI")
		2:
			ai_object = get_node("HardAI")
	
	# Make AI visible but disables on start
	ai_object.visible = true
	ai_object.process_mode = Node.PROCESS_MODE_DISABLED
	
	# Start the timer after which AI will be enabled
	var timer = Timer.new()	
	ai_object.add_child(timer)
	timer.process_mode = Node.PROCESS_MODE_ALWAYS
	timer.one_shot = true
	timer.timeout.connect(ai_object._on_enabled_timeout)
	timer.start(AI_PROCESS_DELAY)
	pass
	
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
