extends Node
class_name Main


# Scene Management

@export_group("Scene Management")

@export var main_menu_screen : Control
@export var level_select_screen : Control
@export var credits_screen : Control
@export var game_screen : Control
@export var end_screen : Control
@export var leaderboard_screen : Control

@onready var current_screen : GameManager.Screen = GameManager.Screen.Title

func _ready() -> void:
	
	for s in GameManager.Screen.values():
		if s != current_screen:
			GameManager.exit_screen.emit(s)
	
	GameManager.enter_screen.connect(enter_screen)
	GameManager.exit_screen.connect(exit_screen)
	GameManager.enter_screen.emit(current_screen)
	
	GameManager.request_transition_to.connect(change_screen)

func _input(event : InputEvent):
	if OS.has_feature("fullscreen"):
		if event.is_action_pressed("fullscreen"):
			if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			else:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func change_screen(next : GameManager.Screen): 
	if current_screen == next:
		return
	
	# trigger a ui rebuild while  the animation play out
	GameManager.refresh_ui.emit(next)
	
	# lookup and run the animations
	GameManager.exit_screen.emit(current_screen)
	current_screen = next
	GameManager.enter_screen.emit(current_screen)


func enter_screen(screen : GameManager.Screen):
	if screen == GameManager.Screen.Game:
		$UI/BaseColor.visible = false


func exit_screen(screen : GameManager.Screen):
	if screen == GameManager.Screen.Game:
		$UI/BaseColor.visible = true
