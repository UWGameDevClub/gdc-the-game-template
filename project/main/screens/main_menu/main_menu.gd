extends Control


func _ready() -> void:
	GameManager.exit_screen.connect(on_screen_exit)
	GameManager.enter_screen.connect(on_screen_enter)

func on_screen_exit(screen):
	if screen == GameManager.Screen.MainMenu:
		visible = false
	
func on_screen_enter(screen):
	if screen == GameManager.Screen.MainMenu:
		visible = true
		$background_animation.play("default")
