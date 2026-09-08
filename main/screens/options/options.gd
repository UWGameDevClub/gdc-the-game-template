extends ScreenRoot

func _ready() -> void:
	super()


func _on_full_screen_check_button_toggled(toggled_on : bool):
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
