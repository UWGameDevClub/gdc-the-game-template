extends Node
class_name MicroGame

signal done(won : bool)

@export_group("Timing")
@export var timer_type : MicroGameInfo.TimerType = MicroGameInfo.TimerType.DefaultWithUI
@export var auto_start_timer : bool = true

## How long the game lasts. Optionally you can start the timer in the _ready function
@export var default_game_duration : float = 10

## Time after on_win/on_lose returns before the micro game done signal is emitted
@export var pre_game_time : float = 0
@export var post_game_time : float = 0
@export var lose_on_timeout : bool


enum { Starting, Playing, Ending, Idle }
var _current_state : int = Idle:
	set(value): 
		_current_state = value

var current_state : int:
	get(): return _current_state

## The timer that runs your micro game
@export var timer : MicroGameTimer = null
@export var info : MicroGameInfo
@export var audio_service : AudioService
@export var run_data : RunData
@export var micro_game_data : MicroGameData


func on_load():
	_current_state = Starting
	
	ready.connect(_start_timer_after_ready)

func _start_timer_after_ready():
	if timer == null:
		return
		
	if auto_start_timer:
		start_timer(default_game_duration)

func start_timer(duration : float):
	if not timer.timeout.is_connected(_handle_timeout):
		timer.timeout.connect(_handle_timeout)
	
	timer.start(duration)
	_current_state = Playing
	
	

func _handle_timeout():
	if current_state == Playing:
		print("timed out ", current_state)
		on_timeout()
		if lose_on_timeout:
			trigger_game_lost()
		else:
			trigger_game_won()

func trigger_game_won():
	if current_state != Playing:
		return
	_current_state = Ending
	
	if timer:
		timer.stop()
	
	_current_state = Ending
	on_win()
	
	if post_game_time > 0:
		get_tree().create_timer(post_game_time).timeout.connect(_finish_game_won)
	else:
		_finish_game_won()
	
func _finish_game_won():
	_current_state = Idle
	done.emit.call_deferred(true)

func trigger_game_lost():
	if current_state != Playing:
		return
	_current_state = Ending
	
	if timer:
		timer.stop()
	
	on_lose()
	
	if post_game_time > 0:
		get_tree().create_timer(post_game_time).timeout.connect(_finish_game_lost)
	else:
		_finish_game_lost()

func _finish_game_lost():
	_current_state = Idle
	done.emit.call_deferred(false)


func on_timeout():
	pass
	
func on_win():
	pass

func on_lose():
	pass
