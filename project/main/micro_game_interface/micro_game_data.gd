## Stores stats about your micro game and data that persists throughout a run.
extends Resource
class_name MicroGameData


## The number of times the player has finished your game this run.
## This value is updated after the last frame of your micro game.
@export var times_played: int


## The number of times the player won your game this run.
## This value is updated after the last frame of your micro game.
@export var times_won: int

## The number of times the player lost your game this run.
## This value is updated after the last frame of your micro game.
var times_lost: int: 
	get(): return times_played - times_won


@export var custom : Dictionary = {}
