extends RigidBody2D

@export var hitForce = 5
var heldOwner = "none" # Unused from earlier Hold idea left in incase of remake
var appliedForce = Vector2(0, 0)

# Physics Simulation
func _process(delta):
	var collision = move_and_collide(appliedForce * delta)
	if collision:
		# Inital force on first hit
		if appliedForce == Vector2(0, 0):
			appliedForce = Vector2(position.x - collision.get_position().x, position.y - collision.get_position().y) * hitForce
			return
			
		# Wall Bounce (Player has ground group)
		if collision.get_collider().is_in_group("ground"):
			appliedForce = appliedForce.bounce(collision.get_normal())
			return
