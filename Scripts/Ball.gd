extends RigidBody2D
signal resetRound

@export var hitForce = 5
var heldOwner = "none" # Unused from earlier Hold idea left in incase of remake
var appliedForce = Vector2.ZERO
var startPos = position
var reset = true

# A collider that is drawn in the direction of ball's path for raycasting
@onready var frontPath = $"FrontPath"

# animation controls
@onready var anim_player = $AnimationPlayer
var current_anim = ""

# THe rotation value supplied to the ball every frame
var frontPathRotation : float

func _ready():
	linear_velocity = Vector2.ZERO
	appliedForce = Vector2(0, 0)
	angular_velocity = 0
	transform.origin = startPos
	current_anim = "idle"
	frontPathRotation = rad_to_deg(self.transform.get_rotation())
	linear_velocity = Vector2.ZERO
	appliedForce = Vector2(0, 0)
	angular_velocity = 0
	transform.origin = startPos

# Physics Simulation
func _physics_process(delta):
	var collision = move_and_collide(appliedForce * delta)
	# Constant change in rotation of the ball towards the movement directino
	global_rotation_degrees = frontPathRotation 
	if collision:
		$BallSFX.play()
		# Inital force on first hit
		if appliedForce == Vector2(0, 0):
			appliedForce = Vector2(position.x - collision.get_position().x, position.y - collision.get_position().y) * hitForce
			change_anim("roll")
		# Give score
		elif collision.get_collider().name == "Goal":
			$"../bgNoice/Crowd".play()
			%GameManager.playerScore += 1
			reset = true
		elif collision.get_collider().name == "Enemy Goal":
			$"../bgNoice/Crowd".play()
			%GameManager.aiScore += 1
			reset = true
		# Wall Bounce (Player has ground group)
		elif collision.get_collider().is_in_group("ground"):
			appliedForce = appliedForce.bounce(collision.get_normal())
			#print(appliedForce)
			
		change_direction(appliedForce.normalized())
		
# Changes the direction (rotation) of the ball	
func change_direction(direction):
		look_at(position + direction) # Change in looking direction towards the normalized applied force
		frontPathRotation = global_rotation_degrees - 90	
		global_rotation_degrees = frontPathRotation 
		
	
func _integrate_forces(state):
	if reset:
		emit_signal("resetRound")
		state.linear_velocity = Vector2.ZERO
		appliedForce = Vector2(0, 0)
		state.angular_velocity = 0
		state.transform.origin = startPos
		change_anim("idle")
		reset = false




func _on_reset_round():
	pass

# changes current animation to a new animation
func change_anim(name):
	if name != current_anim:
		anim_player.play(name)
		current_anim = name
