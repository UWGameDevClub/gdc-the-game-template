extends MicroGameTimer

@onready var digits : DigitDisplay = $MarginContainer/HBoxContainer/DigitDisplay

var display_time : int = 0

func set_display_time(time : float):
	display_time = floor(time)
	digits.set_number(display_time)

func start(wait_time : float):
	display_time = floor(wait_time)
	digits.set_number(display_time)
	super.start(wait_time)

func my_on_tick():
	display_time -= 1
	digits.set_number(display_time)

func my_on_timeout():
	digits.set_number(0)
