extends Resource
class_name RunData

enum Mode {
	Practice,
	Play,
	Developer
}

@export var mode : Mode

@export var runs_finished : int = 0

@export var difficulty_level : int = 0
@export var lives : int 
@export var score : int 

@export var speed_mult = 1
@export var speed_inc = 1
@export var speed_up_in = 19


func copy_from(other : RunData):
	mode = other.mode 
	runs_finished = other.runs_finished
	difficulty_level = other.difficulty_level
	lives = other.lives
	score = other.score
	speed_mult = other.speed_mult
	speed_inc = other.speed_inc
	speed_up_in = other.speed_up_in
