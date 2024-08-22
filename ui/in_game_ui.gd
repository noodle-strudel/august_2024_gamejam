extends Control

@onready var GameManager = %GameManager

var on_pause_menu = true
var on_setting_menu = false
var is_loading_settings = false
var on_warning_menu = false

# Called when the node enters the scene tree for the first time.
func _ready():
	is_loading_settings = true
	GlobalSettings.load_data()
	
	$SettingsMenu/VolumeSlider.value = GlobalSettings.volume
	$SettingsMenu/MusicSlider.value = GlobalSettings.music
	$SettingsMenu/SFXSlider.value = GlobalSettings.sfx
	$SettingsMenu/Resolution.select(GlobalSettings.resolution)
	$SettingsMenu/Display.select(GlobalSettings.window)
	_on_resolution_item_selected(GlobalSettings.resolution)
	_on_display_item_selected(GlobalSettings.window)
	
	is_loading_settings = false


func _on_volume_slider_value_changed(value):
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Master"), 
		linear_to_db(value))
	GlobalSettings.volume = value


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_resolution_item_selected(index):
	if not is_loading_settings:
		$ClickSFX.play()
	match index:
		0:
			DisplayServer.window_set_size(Vector2i(2560, 1440))
		1:
			DisplayServer.window_set_size(Vector2i(1920, 1080))
		2:
			DisplayServer.window_set_size(Vector2i(1366, 768))
		3:
			DisplayServer.window_set_size(Vector2i(1280, 720))
	GlobalSettings.resolution = index


func _on_display_item_selected(index):
	if not is_loading_settings:
		$ClickSFX.play()
	match index:
		0: #Windowed
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		1: #Borderless Windowed
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		2: #Fullscreen
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		3: #Borderless Fullscreen
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
	GlobalSettings.window = index

func _on_back_pressed():
	GlobalSettings.save()
	$ClickSFX.play()
	$SettingsMenu.visible = !$SettingsMenu.visible
	$inGameOptions.visible = !$inGameOptions.visible
	on_pause_menu = true
	on_setting_menu = false

func _on_settings_pressed():
	$ClickSFX.play()
	$SettingsMenu.visible = !$SettingsMenu.visible
	$inGameOptions.visible = !$inGameOptions.visible
	on_pause_menu = false
	on_setting_menu = true


func _on_no_pressed():
	$ClickSFX.play()
	$inGameOptions.visible = !$inGameOptions.visible
	$WarningBackMenu.visible = !$WarningBackMenu.visible
	on_pause_menu = true
	on_warning_menu = false


func _on_yes_pressed():
	$ClickSFX.play()
	Engine.time_scale = 1
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://ui/start_ui.tscn")


func _on_back_menu_pressed():
	$ClickSFX.play()
	$inGameOptions.visible = !$inGameOptions.visible
	$WarningBackMenu.visible = !$WarningBackMenu.visible
	on_pause_menu = false
	on_warning_menu = true


func _on_music_slider_value_changed(value):
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("music"), 
		linear_to_db(value))
	GlobalSettings.music = value


func _on_sfx_slider_value_changed(value):
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("sfx"), 
		linear_to_db(value))
	GlobalSettings.sfx = value


func _on_about_to_quit():
	GlobalSettings.save()


func _on_resume_pressed():
	$ClickSFX.play()
	GameManager._pause_menu()
