extends MicroGame

var timeout : float
@onready var label: Label = $Label
@onready var sprite_2d: Sprite2D = $Sprite2D


func _ready():
	default_game_duration = 2
	label.text = "press space to win!"
	#get_tree().create_timer(timeout).timeout.connect(func(): done.emit(true))

func _unhandled_input(event: InputEvent) -> void:
	if timer.elasped_time() < 1.0/4:
		return
		
	if event.is_action("space"):
		trigger_game_won()
	elif event is InputEventKey and event.is_pressed():
		trigger_game_lost()
	
func on_win():
	label.text = "win!"

func on_lose():
	audio_service.paused = true
	label.text = "lost! :("
	sprite_2d.rotation_degrees = 180
