extends Resource
class_name MicroGameSelection

@export var selected_games : Array[MicroGameInfo]

func add(info : MicroGameInfo):
	if selected_games.has(info):
		return
		
	selected_games.append(info)

func remove(info : MicroGameInfo):
	selected_games.erase(info)
