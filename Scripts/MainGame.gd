extends Node2D

# handles round stuff
@onready var time_ui = $CanvasLayer/Score/TimerContainer/VBoxContainer/TimeLeft
@onready var round_time = $RoundTimer
@onready var ball = %Ball
@onready var player = %Player

# Called when the node enters the scene tree for the first time.
func _ready():
	start_game()

func start_game():
	var ai_object : CharacterBody2D
	var timer = Timer.new()
	var player_timer = Timer.new()
	
	match GlobalSettings.difficulty:
		0:
			ai_object = get_node("EasyAI")
			timer.wait_time = 2
		1:
			ai_object = get_node("NormalAI")
			timer.wait_time = 1.5
		2:
			ai_object = get_node("HardAI")
			timer.wait_time = 0.6
			
	ai_object.visible = true
	player.visible = true
	
	# Defines the timer after which AI will be enabled
	timer.name = ai_object.DELAY_TIMER_NAME
	timer.process_mode = Node.PROCESS_MODE_ALWAYS
	timer.one_shot = true
	ai_object.add_child(timer)
	ai_object.startUpDirection = Vector2.RIGHT
	timer.timeout.connect(ai_object._on_enabled_timeout)
	ai_object.round_delay(timer)
	
	# Defines the timer after which Player will be enabled
	player_timer.name = player.DELAY_TIMER_NAME
	player_timer.process_mode = Node.PROCESS_MODE_ALWAYS
	player_timer.one_shot = true
	player_timer.wait_time = 0.5
	player.add_child(player_timer)
	player.startUpDirection = Vector2.LEFT
	player_timer.timeout.connect(player._on_enabled_timeout)
	player.round_delay(player_timer)
	
	
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
