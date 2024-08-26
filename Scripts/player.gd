extends CharacterBody2D

signal just_grounded

@export var grav : int
@export var speed : int
@export var accel : int
var startUpDirection = Vector2.LEFT

func _init():
	speed = 750
	accel = 10
	grav = -500

# References children nodes once they exist in the scene
@onready var anim_tree = $AnimationTree
@onready var state_machine = anim_tree["parameters/playback"]

var input : Vector2
var playerInput : Vector2
var perpendicular : Vector2
var grounded = true
var rotationAngle = 0.0
var startPos = position
var pressing_jump = 0

# determines if the GhostManager can save a jump the player does
var can_save_jump = true
# keeps track of the current animation
var current_anim = ""

var just_landed = false
	
func _ready():
	up_direction = startUpDirection
	
# Movement Input
func get_input():
	input.x = Input.get_action_strength("right") - Input.get_action_strength("left") 
	input.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	
	pressing_jump = Input.get_action_strength("jump")
	
	return input.normalized()

func jump():
	velocity = up_direction * speed
	grounded = false
	$AudioPlayer.play_random_sound()
	change_anim("jump")
	
# Player Movement proccessing and collisions
func _physics_process(delta):
# Player Input -> movement mapping
	playerInput = get_input()
	
	# Jump
	if pressing_jump > 0:
		$AudioPlayer/fingers.volume_db = -90
		if not $AudioPlayer/jet.is_playing():
			$AudioPlayer/jet.play()
		jump()
	
	# Reset
	if playerInput == Vector2.ZERO:
		perpendicular = Vector2.ZERO
		$AudioPlayer/fingers.volume_db = -90
	
	if !grounded:
		$AudioPlayer/fingers.volume_db = -90
	
	# Left
	if playerInput.x < 0:
		if not $AudioPlayer/fingers.is_playing():
			$AudioPlayer/fingers.volume_db = $AudioPlayer.fingers_volume_const
			$AudioPlayer/fingers.play()
		perpendicular.x = up_direction.y 
		perpendicular.y = up_direction.x * playerInput.x
	
	# Right
	if playerInput.x > 0:
		if not $AudioPlayer/fingers.is_playing():
			$AudioPlayer/fingers.play()
		perpendicular.x = -up_direction.y 
		perpendicular.y = -up_direction.x * -playerInput.x
		
	# Apply Movement + Gravity when on ground
	if grounded:
		$AudioPlayer/jet.stop()
		velocity = lerp(velocity, perpendicular * speed, delta * accel)
		velocity += up_direction * grav
	
	# Check for wall and change gravity direction
	handle_collisions(delta)

func handle_collisions(delta):
	var collision = move_and_collide(velocity * delta)
	if collision:
		if collision.get_collider().name.contains("AI"):
			velocity += collision.get_normal()
		else:
			# Just grounded
			if(!grounded):
				emit_signal("just_grounded")
			grounded = true
			can_save_jump = true
			change_anim("sliding")
			
			rotation_degrees = rad_to_deg(atan2(up_direction.y, up_direction.x)) + 90
			up_direction = collision.get_normal()
			velocity += (up_direction * (speed / 1.2) )

func _on_ball_reset_round():
	position = startPos
	grounded = true
	emit_signal("just_grounded")
	perpendicular = Vector2(0, 0)
	up_direction = startUpDirection
	rotationAngle = 0.0

# changes current animation to a new animation
func change_anim(name):
	if name != current_anim:
		state_machine.travel(name)
		current_anim = name
