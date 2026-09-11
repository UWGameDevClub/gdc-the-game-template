extends ScreenRoot

@onready var local_leaderboard := $MarginContainer/VBoxContainer/HBoxContainer/LocalLeaderboardList
@onready var today_leaderboard := $MarginContainer/VBoxContainer/HBoxContainer/TodayLeaderboardList
@onready var alltime_leaderboard := $MarginContainer/VBoxContainer/HBoxContainer/AllTimeLeaderboardList
@onready var http_request := $HTTPRequest
@onready var name_input := $MarginContainer/VBoxContainer/MarginContainer2/HBoxContainer/CenterContainer/NameInput

@export var local_data_manager : LocalDataManager

const TALO_alltime_leaderboard_name : String = "All Time Leaderboard"
const TALO_daily_leaderboard_name : String = "Daily Leaderboard"

func update_local(scores:Array[ScoreResource]):
	local_leaderboard.display_score_list(scores)

func update_today(scores:Array[ScoreResource]):
	today_leaderboard.display_score_list(scores)

func update_alltime(scores:Array[ScoreResource]):
	alltime_leaderboard.display_score_list(scores)

func _on_visibility_changed():
	if visible:
		_build_local_entries()
		http_request.test_connection()
		await http_request.request_completed
		if http_request.most_recent_result:
			_get_online_leaderboards()
		
		

func _get_online_leaderboards():
	var page := 0
	var done := false
	while !done:
		var options := Talo.leaderboards.GetEntriesOptions.new()
		options.page = page
		var alltime_res := await Talo.leaderboards.get_entries(TALO_alltime_leaderboard_name, options)
		
		if alltime_res == null:
			print("ERROR LOADING ALLTIME LEADERBOARD")
			break
		
		var is_last_page : bool = alltime_res.is_last_page
		if is_last_page:
			done = true
		page += 1
	
	page = 0
	done = false
	while !done:
		var options := Talo.leaderboards.GetEntriesOptions.new()
		options.page = page
		var daily_res := await Talo.leaderboards.get_entries(TALO_daily_leaderboard_name, options)
		
		if daily_res == null:
			print("ERROR LOADING DAILY LEADERBOARD")
			break
		
		var is_last_page : bool = daily_res.is_last_page
		if is_last_page:
			done = true
		page += 1
	
	_build_online_entries()

func _build_online_entries():
	var daily_list : Array[ScoreResource]
	var alltime_list : Array[ScoreResource]
	if http_request.most_recent_result:
		for entry in Talo.leaderboards.get_cached_entries(TALO_alltime_leaderboard_name):
			alltime_list.append(_entry_to_score_res(entry))
		for entry in Talo.leaderboards.get_cached_entries(TALO_daily_leaderboard_name):
			daily_list.append(_entry_to_score_res(entry))
	update_alltime(alltime_list)
	update_today(daily_list)
	alltime_leaderboard.highlight_name(name_input.text)
	today_leaderboard.highlight_name(name_input.text)

func _build_local_entries():
	if local_data_manager != null:
		update_local(local_data_manager.get_scores())
		local_leaderboard.highlight_name(name_input.text)

func _entry_to_score_res(entry:TaloLeaderboardEntry) -> ScoreResource:
	var player_name : String = entry.player_alias.identifier
	var player_score : int = entry.score
	return ScoreResource.new(player_name, player_score)

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
		http_request.test_connection()
		await http_request.request_completed
		if http_request.most_recent_result:
			_get_online_leaderboards()
	
