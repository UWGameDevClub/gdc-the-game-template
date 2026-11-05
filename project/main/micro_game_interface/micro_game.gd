extends Node
class_name MicroGame

@warning_ignore_start("unused_signal")
# Emit this signal when your game is done.
# Your game will still be visible during the frame this is called.
# If the player won your game, then won should be true, otherwise it should be false.
signal done(won : bool)
signal pause_music
signal resume_music
@warning_ignore_restore("unused_signal")



@export_group("Timing")
## The timer that runs your micro game
@export var timer : MicroGameTimer = null
@export var timer_type : MicroGameInfo.TimerType = MicroGameInfo.TimerType.DefaultWithUI
@export var auto_start_timer : bool = true

## How long the game lasts. Optionally you can start the timer in the _ready function
@export var default_game_duration : float = 10

## Time amount of time to after on_win/on_lose returns before the micro game done signal is emitted
@export var post_game_time : float = 0
@export var lose_on_timeout : bool
@export var post_game_time : float = 0

enum { Starting, Playing, Ending, Idle }
var _current_state : int = Idle
var current_state : int:
	get(): return _current_state

@export var info : MicroGameInfo
@export var audio_service : AudioService
@export var run_data : RunData
@export var micro_game_data : MicroGameData


func on_load():
	game_over = false
	game_timed_out = false
	current_state = Idle


func on_load():
	game_over = false
	game_timed_out = false
	current_state = Starting

func on_load(data : MicroGameData):
	game_data = data
	
	ready.connect(_start_timer_after_ready)


func _start_timer_after_ready():
	if timer != null:
		return
		
	if auto_start_timer:
		start_timer(info.default_game_duration)

func start_timer(duration : float):
	timer.start(duration)
		
	if not timer.timeout.is_connected(_handle_timeout):
		timer.timeout.connect(_handle_timeout)
	



func _handle_timeout():
	on_timeout()
	if current_state == Playing:
		if lose_on_timeout:
			on_win()
		else:
			on_lose()

func on_timeout():
	pass


func trigger_game_won():
	if current_state != Playing:
		return
	
	_current_state = Ending
	on_win()
	
	if post_game_time > 0:
		get_tree().create_timer(post_game_time).timeout.connect(_finish_game_won)
	
func _finish_game_won():
	_current_state = Idle
	done.emit(true)

func trigger_game_lost():
	if current_state != Playing:
		return
	
	_current_state = Ending
	on_lose()
	
	if post_game_time > 0:
		get_tree().create_timer(post_game_time).timeout.connect(_finish_game_lost)
		

func _finish_game_lost():
	_current_state = Idle
	done.emit(false)


func on_win():
	pass

func on_lose():
	pass
