extends Resource
class_name ScoreResource

@export var player_name : String
@export var score : int

func _init(player_name : String = "", score : int = 0):
	self.player_name = player_name
	self.score = score
