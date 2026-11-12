## A base class for micro games.
## Provides access to external dependenciesa and handles lifetime callbacks.
extends Node
class_name MicroGame

## Emitted when the micro game should be unloaded.
signal done(won : bool)

@export_group("Timing")
## The type of timer your micro game needs
## Most most use cases you will need DefaultWithUI or DefaultNoUI
@export var timer_type : MicroGameInfo.TimerType = MicroGameInfo.TimerType.DefaultWithUI

## How long the game lasts. 
@export var default_game_duration : float = 10

## If this is true, the timer will start on its own after the _ready runs.
## Optionally, you can start the timer in the _ready function.
@export var auto_start_timer : bool = true

## Time between _ready returning and the count down starting. 
## If the pre_game_time > 0, then [member timer] will be paused for that amount of time.
@export var pre_game_time : float = 0

## Time between on_win/on_lose returning and the done signal being emitted.
@export var post_game_time : float = 0

## If true, then the trigger_game_won will run after the timer expries. 
## otherwise, tigger_game_lost.
@export var lose_on_timeout : bool


enum { Starting, Playing, Ending, Idle }
var _current_state : int = Idle:
	set(value): 
		_current_state = value

## The state that your micro game is in. 
## Use this to avoid running gameplay code when start up / ending animations are playing
var current_state : int:
	get(): return _current_state

## The timer that runs your micro game.
@export var timer : MicroGameTimer = null

## The info resource for your micro game.
@export var info : MicroGameInfo

## Provides functions to resume and play the background music.
@export var audio_service : AudioService

## Stats about the current run (lives, score, games played etc.)
@export var run_data : RunData

## Stats about your micro game and data that persists throughout a run.
@export var micro_game_data : MicroGameData

## Called before _ready when the game is loaded.
## Called right after the dependencies are injected by the MicroGameBuilder
func on_load() -> void:
	_current_state = Starting
	
	ready.connect(_start_timer_after_ready)

func _start_timer_after_ready():
	if timer == null:
		return
		
	if auto_start_timer and timer.expired:
		if post_game_time > 0:
			var t = get_tree().create_timer(pre_game_time)
			timer.start(default_game_duration)
			timer.pause()
			t.timeout.connect(_delayed_start)
		else:
			start_timer(default_game_duration)

func _delayed_start():
	if not timer.timeout.is_connected(_handle_timeout):
		timer.timeout.connect(_handle_timeout)
	
	if _current_state == Starting:
		_current_state = Playing
		timer.resume()


## Call this function when your micro game is Starting to start the micro game timer.
## Calling this function while the timer is running will reset the timer.
func start_timer(duration : float) -> void:
	if not timer.timeout.is_connected(_handle_timeout):
		timer.timeout.connect(_handle_timeout)
	
	if _current_state == Starting:
		timer.start(duration)
		timer.resume()
		_current_state = Playing


func _handle_timeout():
	if current_state == Playing:
		print("timed out ", current_state)
		on_timeout()
		if lose_on_timeout:
			trigger_game_lost()
		else:
			trigger_game_won()

## Call this function to end the game when the player wins.
func trigger_game_won() -> void:
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
	_emit_done.call_deferred(true)


## Call this function to end the game when the player loses.
func trigger_game_lost() -> void:
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
	_emit_done.call_deferred(false)

func _emit_done(won : bool):
	micro_game_data.times_played += 1
	if won:
		micro_game_data.times_won += 1
	
	done.emit(won)

## Called when the timer expired.
## This will only run once during each play of your micro game.
func on_timeout() -> void:
	pass

## Called when the game has been won.
## This will only run once during each play of your micro game.
func on_win() -> void:
	pass

## Called when the game has been lost.
## This will only run once during each play of your micro game.
func on_lose() -> void:
	pass
	
## Called before the game exits the scene tree.
## Called after done has beem emitted 
## when the system no longer needs your game to be displayed.
func on_unload() -> void:
	pass
