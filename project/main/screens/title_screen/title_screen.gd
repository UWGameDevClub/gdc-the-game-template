extends ScreenRoot

func _input(event: InputEvent) -> void:
	if not visible:
		return
		
	if event is InputEventMouseButton and event.is_pressed():
		GameManager.request_transition_to.emit(GameManager.Screen.MainMenu)
		
	if event is InputEventKey and event.is_pressed():
		GameManager.request_transition_to.emit(GameManager.Screen.MainMenu)
