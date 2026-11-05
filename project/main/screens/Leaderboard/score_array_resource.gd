class_name ScoreArrayResource
extends Resource

@export var score_array : Array[ScoreResource]

func append(res:ScoreResource):
	score_array.append(res)
