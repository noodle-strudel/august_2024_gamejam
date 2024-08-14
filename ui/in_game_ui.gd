extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _on_volume_slider_value_changed(value):
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Master"), 
		linear_to_db(value))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_resolution_item_selected(index):
	match index:
		0:
			$ClickSFX.play()
			DisplayServer.window_set_size(Vector2i(2560, 1440))
		1:
			$ClickSFX.play()
			DisplayServer.window_set_size(Vector2i(1920, 1080))
		2:
			$ClickSFX.play()
			DisplayServer.window_set_size(Vector2i(1366, 768))
		3:
			$ClickSFX.play()
			DisplayServer.window_set_size(Vector2i(1280, 720))


func _on_display_item_selected(index):
	match index:
		0: #Windowed
			$ClickSFX.play()
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		1: #Borderless Windowed
			$ClickSFX.play()
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		2: #Fullscreen
			$ClickSFX.play()
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		3: #Borderless Fullscreen
			$ClickSFX.play()
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)

func _on_back_pressed():
	$ClickSFX.play()
	$SettingsMenu.visible = !$SettingsMenu.visible
	$inGameOptions.visible = !$inGameOptions.visible

func _on_settings_pressed():
	$ClickSFX.play()
	$SettingsMenu.visible = !$SettingsMenu.visible
	$inGameOptions.visible = !$inGameOptions.visible


func _on_no_pressed():
	$ClickSFX.play()
	$inGameOptions.visible = !$inGameOptions.visible
	$WarningBackMenu.visible = !$WarningBackMenu.visible


func _on_yes_pressed():
	$ClickSFX.play()
	#await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://ui/start_ui.tscn")


func _on_back_menu_pressed():
	$ClickSFX.play()
	$inGameOptions.visible = !$inGameOptions.visible
	$WarningBackMenu.visible = !$WarningBackMenu.visible


func _on_music_slider_value_changed(value):
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("music"), 
		linear_to_db(value))


func _on_sfx_slider_value_changed(value):
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("sfx"), 
		linear_to_db(value))
