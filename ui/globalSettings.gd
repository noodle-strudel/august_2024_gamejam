extends Node

var save_path = "user://settings.save"
var volume: float
var music: float
var sfx: float
var resolution: int
var window: int
var difficulty: int #0 easy, 1 normal, 2 difficult

func _ready():
	pass
	
func save():
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_var(volume)
	file.store_var(music)
	file.store_var(sfx)
	file.store_var(resolution)
	file.store_var(window)
	file.store_var(difficulty)
	#print("saved Volume:", volume)
	#print("saved Music:", music)
	#print("saved SFX:", sfx)
	#print("saved Resolution:", resolution)
	#print("saved Window:", window,"\n\n")
	print("saved diff: ", difficulty, "\n\n")
	
func load_data():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		volume = file.get_var(volume)
		music = file.get_var(music)
		sfx = file.get_var(sfx)
		resolution = file.get_var(resolution)
		window = file.get_var(window)
		difficulty = file.get_var(difficulty)
	else:
		volume = 0.75
		music = 0.5
		sfx = 0.35
		resolution = 3
		window = 0
		difficulty = 0
	#print("loaded Volume:", volume)
	#print("loaded Music:", music)
	#print("loaded SFX:", sfx)
	#print("loaded Resolution:", resolution)
	#print("loaded Window:", window,"\n\n")
	print("loaded diff: ", difficulty, "\n\n")

func delete_save_file(): #for debagging
	if  FileAccess.file_exists(save_path):
		DirAccess.remove_absolute(save_path)

