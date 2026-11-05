extends Resource
class_name GameSelector

@export var randomize : bool = true
@export var play_all_before_repeat : bool = true


var all_games : Array[MicroGameInfo]

var to_play : Array[MicroGameInfo]

var current_game : MicroGameInfo


func get_next_game() -> MicroGameInfo:
	if not randomize:
		if to_play.is_empty():
			to_play.append_array(all_games)
		
		current_game = to_play.pop_front()
	
	else:
		if to_play.is_empty():
			to_play.append_array(all_games)
			to_play.shuffle()
			
		current_game = to_play.pop_front()
		
	return current_game


func reset():
	to_play.clear()
	current_game = null
	
func reload(games: Array[MicroGameInfo]):
	all_games.clear() 
	all_games.append_array(games)
