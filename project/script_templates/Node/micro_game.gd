extends _BASE_

# Emit this signal when your game is done.
# Your game will still be visible during the frame this is called.
# If the player won your game, then won should be true, otherwise it should be false.
signal done(won : bool)

@export var timer : MicroGameTimer
@export var game_data : MicroGameData

func _setup(data : MicroGameData):
	game_data = data

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timeout():
	pass

func _on_win():
	pass

func _on_lose():
	pass
