extends AudioStreamPlayer2D

var fingers_volume_const
var jet_volume_const
var sfx_jump = []
var random = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	sfx_jump.append(load("res://music/sfx/jump1.ogg"))
	sfx_jump.append(load("res://music/sfx/jump2.ogg"))
	sfx_jump.append(load("res://music/sfx/jump3.ogg"))
	fingers_volume_const = $fingers.volume_db
	jet_volume_const = $jet.volume_db

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $"../../CanvasLayer/inGameMenu".visible || $"../../CanvasLayer/WinLoseMenu".visible:
		volume_db = -90
		$fingers.volume_db = -90
		$jet.volume_db = -90
	else:
		volume_db = 0
		$fingers.volume_db = fingers_volume_const
		$jet.volume_db = jet_volume_const


func play_random_sound():
	var sound_index = random.randi_range(0, sfx_jump.size() - 1)
	stream = sfx_jump[sound_index]
	play()
