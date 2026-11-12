extends MicroGame

var timeout : float
@onready var label: Label = $Label
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var current_score: Label = $current_score
@onready var current_lives: Label = $current_lives


func _ready():
	default_game_duration = 2
	label.text = "press space to win!"
	
	current_score.text = "score: " + str(run_data.score)
	current_lives.text = "lives: " + str(run_data.lives)


func _unhandled_input(event: InputEvent) -> void:
	# win the game if space is pressed
	if event.is_action("space"):
		trigger_game_won()
	
	# lose if any other key was pressed
	elif event is InputEventKey and event.is_pressed():
		trigger_game_lost()


func on_win():
	# add 1 to include the game that is currently ending
	var times_won = str(micro_game_data.times_won + 1)
	var times_played = str(micro_game_data.times_played + 1)
	
	label.text = "win!" + times_won + "/" + times_played


func on_lose():
	audio_service.paused = true
	
	# add 1 to include the game that is currently ending
	var times_lost = str(micro_game_data.times_lost + 1)
	var times_played = str(micro_game_data.times_played + 1)
	label.text = "lost! :( " + times_lost + "/"+ times_played
	sprite_2d.rotation_degrees = 180
