extends VBoxContainer

var wave_amp = 20
var freq = 6

# Called when the node enters the scene tree for the first time.
func _ready():
	$ContainerNoodlestrudel/noodlestrudel.text = "[wave amp="+str(wave_amp)+" freq="+str(freq)+"]" + $ContainerNoodlestrudel/noodlestrudel.text + "[/wave]"
	$ContainerPalnex/palnex.text = "[wave amp="+str(wave_amp)+" freq="+str(freq)+"]" + $ContainerPalnex/palnex.text + "[/wave]"
	$ContainerLowercasewords/lowercasewords.text = "[wave amp="+str(wave_amp)+" freq="+str(freq)+"]" + $ContainerLowercasewords/lowercasewords.text+ "[/wave]"
	$ContainerMrSqueeg/MrSqueeg.text = "[wave amp="+str(wave_amp)+" freq="+str(freq)+"]" +$ContainerMrSqueeg/MrSqueeg.text+ "[/wave]"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
