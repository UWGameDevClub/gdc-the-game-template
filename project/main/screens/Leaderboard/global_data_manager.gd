extends Node

signal global_leaderboards_updated(daily_lb : Array[ScoreResource], alltime_lb : Array[ScoreResource], event_lb : Array[ScoreResource])

const TALO_alltime_leaderboard_name : String = "All Time Leaderboard"
const TALO_daily_leaderboard_name : String = "Daily Leaderboard"
const TALO_event_leaderboard_name : String = "Clubs Fair Leaderboard"


@onready var con_test := $ConnectionTest
@export var use_event_leaderboard : bool = false

func add_score(scr_res : ScoreResource):
	con_test.test_connection()
	await con_test.request_completed
	if con_test.most_recent_result:
		await Talo.players.identify("username", scr_res.player_name)
		var res_alltime := await Talo.leaderboards.add_entry(TALO_alltime_leaderboard_name, scr_res.score)
		var res_daily := await Talo.leaderboards.add_entry(TALO_daily_leaderboard_name, scr_res.score)
		if use_event_leaderboard:
			var res_event := await Talo.leaderboards.add_entry(TALO_event_leaderboard_name, scr_res.score)
	

func get_scores():
	con_test.test_connection()
	await con_test.request_completed
	if !con_test.most_recent_result:
		global_leaderboards_updated.emit(null, null)
		return
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
	
	if use_event_leaderboard:
		page = 0
		done = false
		while !done:
			var options := Talo.leaderboards.GetEntriesOptions.new()
			options.page = page
			var event_res := await Talo.leaderboards.get_entries(TALO_event_leaderboard_name, options)
			
			if event_res == null:
				print("ERROR LOADING event LEADERBOARD")
				break
			
			var is_last_page : bool = event_res.is_last_page
			if is_last_page:
				done = true
			page += 1
	
	var daily_list : Array[ScoreResource] = []
	var alltime_list : Array[ScoreResource] = []
	var event_list : Array[ScoreResource] = []
	for entry in Talo.leaderboards.get_cached_entries(TALO_alltime_leaderboard_name):
		alltime_list.append(_entry_to_score_res(entry))
	for entry in Talo.leaderboards.get_cached_entries(TALO_daily_leaderboard_name):
		daily_list.append(_entry_to_score_res(entry))
	if use_event_leaderboard:
		for entry in Talo.leaderboards.get_cached_entries(TALO_event_leaderboard_name):
			event_list.append(_entry_to_score_res(entry))
	
	global_leaderboards_updated.emit(daily_list, alltime_list, event_list)

func _entry_to_score_res(entry:TaloLeaderboardEntry) -> ScoreResource:
	var player_name : String = entry.player_alias.identifier
	var player_score : int = entry.score
	return ScoreResource.new(player_name, player_score)
