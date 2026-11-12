## Stores stats about the state of a run.
extends Resource
class_name RunData

enum Mode { Practice, Play, Developer }

## How the game is being played. [br]
## [b]Play[/b]: The standard play mode. [br]
## [b]Practice[/b]: Practice mode (just running a single micro game). [br]
## [b]Developer[/b]: Coming soon. [br]
@export var mode : Mode

## The number of lives the player had when they started the current game.
## This values does not change until after your micro game ends.
@export var lives : int 

## The score the player had when they started the current game.
## This values does not change until after your micro game ends.
@export var score : int 

## The number of wins between speed ups.
@export var speed_up_frequency = 19

## The number of games the player needs to win before a speed up.
## This values does not change until after your micro game ends.
@export var speed_up_in = 19

## Used to set the engine timescale.
## This values does not change until after your micro game ends.
@export var speed_mult = 1

## The amount to speed up when the player reaches a speed up.
## Gets added to the current speed_mult.
@export var speed_inc = 1

## Copies the data from another RunData instance.
## Used to prevent differnt micro games from affecting eachother by modifying run data.
func copy_from(other : RunData):
	mode = other.mode 
	lives = other.lives
	score = other.score
	speed_mult = other.speed_mult
	speed_inc = other.speed_inc
	speed_up_in = other.speed_up_in
