extends Control

var is_loading_settings = false
var on_setting_menu = false
var on_diff_menu = false
var on_creds_menu = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$SoccerArena/AnimationPlayer.play("new_animation")
	$SoccerSpaceTitle/AnimationPlayer.play("new_animation")
	$AudioStartMenu.play()
	
	
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
		if Input.is_action_just_pressed("pause") && on_setting_menu:
			_on_back_pressed()
		if Input.is_action_just_pressed("pause") && on_diff_menu:
			_on_back_diff_pressed()
		if Input.is_action_just_pressed("pause") && on_creds_menu:
			_on_back_creds_pressed()

func _on_volume_slider_value_changed(value):
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Master"), 
		linear_to_db(value))
	GlobalSettings.volume = value


func _on_settings_pressed():
	$ClickSFX.play()
	$StartMenu.visible = !$StartMenu.visible
	$SettingsMenu.visible = !$SettingsMenu.visible
	on_setting_menu = true


func _on_quit_pressed():
	get_tree().quit()


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
	$ClickSFX.play()
	$StartMenu.visible = !$StartMenu.visible
	$SettingsMenu.visible = !$SettingsMenu.visible
	GlobalSettings.save()
	on_setting_menu = false


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


func _on_start_pressed():
	$ClickSFX.play()
	$DiffMenu.visible = !$DiffMenu.visible
	$StartMenu.visible = !$StartMenu.visible
	on_diff_menu = true

func _on_difficult_pressed():
	$ClickSFX.play()
	GlobalSettings.difficulty = 2
	GlobalSettings.save()
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://ui/how_to_play.tscn")


func _on_normal_pressed():
	$ClickSFX.play()
	GlobalSettings.difficulty = 1
	GlobalSettings.save()
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://ui/how_to_play.tscn")


func _on_eazy_pressed():
	GlobalSettings.difficulty = 0
	GlobalSettings.save()
	$ClickSFX.play()
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://ui/how_to_play.tscn")


func _on_back_diff_pressed():
	$ClickSFX.play()
	$DiffMenu.visible = !$DiffMenu.visible
	$StartMenu.visible = !$StartMenu.visible
	on_diff_menu = false


func _on_credits_pressed():
	$ClickSFX.play()
	$StartMenu.visible = !$StartMenu.visible
	$Credist.visible = !$Credist.visible
	on_creds_menu = true


func _on_back_creds_pressed():
	$ClickSFX.play()
	$StartMenu.visible = !$StartMenu.visible
	$Credist.visible = !$Credist.visible
	on_creds_menu = false
