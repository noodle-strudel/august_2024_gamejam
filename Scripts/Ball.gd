extends RigidBody2D

@export var hitForce = 6
var heldOwner = "none"
var appliedForce = Vector2(0, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var collision = move_and_collide(appliedForce * delta)
	if collision:
		if appliedForce == Vector2(0, 0):
			appliedForce = Vector2(position.x - collision.get_position().x, position.y - collision.get_position().y) * hitForce
			return
		if collision.get_collider().is_in_group("ground"):
			appliedForce = appliedForce.bounce(collision.get_normal())
			return
