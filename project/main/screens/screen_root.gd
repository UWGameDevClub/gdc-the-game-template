extends Control
class_name ScreenRoot

@export var this_screen : GameManager.Screen

func _ready() -> void:
	GameManager.exit_screen.connect(on_screen_exit)
	GameManager.enter_screen.connect(on_screen_enter)

func on_screen_exit(screen):
	if this_screen == screen:
		visible = false
	
func on_screen_enter(screen):
	if this_screen == screen:
		visible = true
