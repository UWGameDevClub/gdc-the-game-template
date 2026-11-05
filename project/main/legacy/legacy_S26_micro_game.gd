extends Node2D
class_name LegacyS26MicroGame

@warning_ignore_start("unused_signal")
signal enter_animation

signal start
signal win
signal lose

signal pause_music
signal resume_music
@warning_ignore_restore("unused_signal")


@export_group("Input")

enum ControlFormat {
	MouseOnly,
	KeyboardOnly,
	MouseAndKeyboard
}

@export var control_format : ControlFormat = ControlFormat.MouseAndKeyboard

@export_group("Timing")

@export var lose_on_timeout : bool

enum DefaultTimerType {
	DefaultNoUI,
	DefaultWithUI,
	CustomTimer
}
@export var timer_type : DefaultTimerType = DefaultTimerType.DefaultWithUI

@export var timer : MicroGameTimer

@export_range(2, 10) var game_duration: float = 4

@export var pre_game_time : float = 0
@export var post_game_time : float = 2.5

@export_group("Loading")
@export var always_reload : bool = true
