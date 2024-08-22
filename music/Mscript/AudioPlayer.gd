extends AudioStreamPlayer2D

var sfx_jump = []
var random = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	sfx_jump.append(load("res://music/sfx/jump1.ogg"))
	sfx_jump.append(load("res://music/sfx/jump2.ogg"))
	sfx_jump.append(load("res://music/sfx/jump3.ogg"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func play_random_sound():
	var sound_index = random.randi_range(0, sfx_jump.size() - 1)
	stream = sfx_jump[sound_index]
	play()
