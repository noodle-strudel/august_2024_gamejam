extends RigidBody2D
signal resetRound

@export var hitForce = 5
var heldOwner = "none" # Unused from earlier Hold idea left in incase of remake
var appliedForce = Vector2(0, 0)
var startPos = position
var reset = true

# Physics Simulation
func _physics_process(delta):
	var collision = move_and_collide(appliedForce * delta)
	if collision:
		# Give score
		if collision.get_collider().name == "Goal":
			%GameManager.playerScore += 1
			reset = true
			return
		if collision.get_collider().name == "Enemy Goal":
			%GameManager.aiScore += 1
			reset = true
			return
		# Inital force on first hit
		if appliedForce == Vector2(0, 0):
			appliedForce = Vector2(position.x - collision.get_position().x, position.y - collision.get_position().y) * hitForce
			return
			
		# Wall Bounce (Player has ground group)
		if collision.get_collider().is_in_group("ground"):
			appliedForce = appliedForce.bounce(collision.get_normal())
			return
	
func _integrate_forces(state):
	if reset:
		emit_signal("resetRound")
		state.linear_velocity = Vector2.ZERO
		appliedForce = Vector2(0, 0)
		state.angular_velocity = 0
		state.transform.origin = startPos
		reset = false
		pass
