class_name LocalDataManager
extends Node

signal local_leaderboard_updated(local_lb : Array[ScoreResource])

@export var save_file_path : String

var _local_scores : ScoreArrayResource


func _ready():
	_load_scores()

func add_score(res : ScoreResource):
	_local_scores.append(res)
	_save_scores()

func emit_scores():
	local_leaderboard_updated.emit(get_scores())

func get_scores()->Array[ScoreResource]:
	if _local_scores != null:
		return _local_scores.score_array.duplicate_deep()
	return []

func _save_scores():
	ResourceSaver.save(_local_scores, save_file_path)

func _load_scores():
	if ResourceLoader.exists(save_file_path):
		_local_scores = ResourceLoader.load(save_file_path)
	else:
		_local_scores = ScoreArrayResource.new()

func _wipe_scores():
	_local_scores.score_array = []
	_save_scores()
