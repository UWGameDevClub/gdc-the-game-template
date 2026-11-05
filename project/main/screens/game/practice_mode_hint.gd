extends Control
signal force_quit_game

@export var button_hold_time : float = 1.5

@onready var quit_progress_bar := $CenterContainer/QuitProgressBar

var time : float = 0.0:
	set(new):
		time = clamp(new, 0.0, button_hold_time)
		if !is_node_ready():return
		quit_progress_bar.value = time / button_hold_time
		quit_progress_bar.modulate.a = time / button_hold_time
		if new >= button_hold_time: quit_game()

func _process(delta):
	if !visible : return
	if Input.is_key_pressed(KEY_ESCAPE):
		time += delta
	else:
		time -= 2 * delta

func quit_game():
	if !visible : return
	force_quit_game.emit()


func _on_visibility_changed():
	time = 0.0
