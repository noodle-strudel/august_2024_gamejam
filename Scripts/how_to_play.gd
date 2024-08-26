extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	$Start_sfx.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_confirm_agreement_pressed():
	$AnimationPlayer.play_backwards("new_animation")
	$End_sfx.play()
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file("res://game.tscn")
