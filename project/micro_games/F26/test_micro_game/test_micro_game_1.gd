extends Node2D

signal done(won : bool)

var timeout : float

func _ready():
	timeout = 2
	get_tree().create_timer(timeout).timeout.connect(func(): done.emit(true))
