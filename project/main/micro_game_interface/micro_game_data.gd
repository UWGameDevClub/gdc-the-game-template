extends Resource
class_name MicroGameData


#@export var results : Array[MicroGameResult]
#var times_played : int:
	#get():
		#return len(results)

@export var custom : Dictionary = {}
