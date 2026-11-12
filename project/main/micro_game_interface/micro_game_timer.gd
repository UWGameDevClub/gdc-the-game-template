extends Node
class_name MicroGameTimer


@warning_ignore_start("unused_signal")
## Emitted when the timer ends.
signal timeout

## Emitted at fixed intervals. See also tick_interval.
signal tick
@warning_ignore_restore("unused_signal")

## Time, in seconds, between times tick is emitted. See also tick.
@export var tick_interval : float


var _total_duration : float = 0.0
var _expired : bool = true
var _paused : bool = true
var _expire_timer : Timer
var _tick_timer : Timer

## The total time required for the timer to end, in seconds.
## This value is updated when start is called.
var total_duration: bool:
	get(): return _total_duration


var paused : bool:
	get(): return _paused
	set(value):
		if value:
			pause()
		else:
			resume()
	

## False if the timer is running, otherwise true.
var expired: bool:
	get(): return _expired

## Amount of time, in seconds, since the timer started.
func elasped_time():
	return _total_duration - _expire_timer.time_left

## The timer's remaining time in seconds. Always zero when the timer is expired.
func time_left():
	return _expire_timer.time_left

func _ready() -> void:
	_expired = true

	if not _expire_timer:
		_expire_timer = Timer.new()
		add_child(_expire_timer)
		_expire_timer.autostart = paused
		_expire_timer.paused = paused

	if not _tick_timer:
		_tick_timer = Timer.new()
		add_child(_tick_timer)
		_tick_timer.paused = paused

	_tick_timer.timeout.connect(_on_tick)
	_tick_timer.wait_time = tick_interval

	_expire_timer.timeout.connect(_on_timeout)
	

## Call this function to start the timer.
func start(wait_time : float):
	_total_duration = wait_time

	_expired = false
	
	_expire_timer.start(wait_time)
	_tick_timer.start()

func pause():
	if paused: return
	
	_paused = true
	_tick_timer.paused = true
	_expire_timer.paused = true
	
func resume():
	if not paused: return
	
	_paused = false
	_tick_timer.paused = false
	_expire_timer.paused = false

## Call this function to stop the timer.
## Does not emit the timeout signal.
func stop():
	_expire_timer.stop()
	_tick_timer.stop()
	_expired = true

func _on_tick():
	# catch any ticks that come in after the micro game ends
	if _expired:
		return

	tick.emit()
	_tick_timer.start()

func _on_timeout():
	_expired = true
	_tick_timer.stop()
	timeout.emit()
