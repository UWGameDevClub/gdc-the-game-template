extends Node
class_name MicroGameTimer


@warning_ignore_start("unused_signal")
signal timeout
signal tick
@warning_ignore_restore("unused_signal")

@export var tick_interval : float


var _total_duration : float = 0.0
var _expired : bool = true
var expired: bool:
	get(): return expired

var _expire_timer : Timer
var _tick_timer : Timer

func elasped_time():
	return _total_duration - _expire_timer.time_left

func _ready() -> void:
	_expired = true

	if not _expire_timer:
		_expire_timer = Timer.new()
		add_child(_expire_timer)
		_expire_timer.autostart = false

	if not _tick_timer:
		_tick_timer = Timer.new()
		add_child(_tick_timer)

	_tick_timer.timeout.connect(_on_tick)
	_tick_timer.wait_time = tick_interval

	_expire_timer.timeout.connect(_on_timeout)
	

func start(wait_time : float):
	_total_duration = wait_time

	_expired = false
	
	_expire_timer.start(wait_time)
	_tick_timer.start()


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
