extends ScreenRoot

signal request_online_leaderboards
signal request_local_leaderboards

@onready var local_leaderboard := $MarginContainer/VBoxContainer/HBoxContainer/LocalLeaderboardList
@onready var today_leaderboard := $MarginContainer/VBoxContainer/HBoxContainer/TodayLeaderboardList
@onready var alltime_leaderboard := $MarginContainer/VBoxContainer/HBoxContainer/AllTimeLeaderboardList
@onready var name_input := $MarginContainer/VBoxContainer/MarginContainer2/HBoxContainer/CenterContainer/NameInput


func update_local(scores:Array[ScoreResource]):
	local_leaderboard.display_score_list(scores)

func update_today(scores:Array[ScoreResource]):
	today_leaderboard.display_score_list(scores)

func update_alltime(scores:Array[ScoreResource]):
	alltime_leaderboard.display_score_list(scores)

func _on_visibility_changed():
	if visible:
		_get_local_leaderboards()
		_get_online_leaderboards()
		

func _get_online_leaderboards():
	request_online_leaderboards.emit()

func _get_local_leaderboards():
	request_local_leaderboards.emit()

func _build_online_entries(daily_list : Array[ScoreResource], alltime_list : Array[ScoreResource]):
	update_alltime(alltime_list)
	update_today(daily_list)
	alltime_leaderboard.highlight_name(name_input.text)
	today_leaderboard.highlight_name(name_input.text)

func _build_local_entries(local_list : Array[ScoreResource]):
	update_local(local_list)
	local_leaderboard.highlight_name(name_input.text)
	


func highlight_score(name:String):
	local_leaderboard.highlight_name(name)
	today_leaderboard.highlight_name(name)
	alltime_leaderboard.highlight_name(name)


func _on_name_input_name_created():
	highlight_score(name_input.text)


func _on_name_input_name_deleted():
	highlight_score(name_input.text)


func search_by_score_resource(scr_res : ScoreResource):
	if scr_res != null: name_input.text = scr_res.player_name


func _on_update_timer_timeout():
	if visible:
		_get_online_leaderboards()
