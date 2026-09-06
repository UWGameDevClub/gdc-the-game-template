class_name GameSelectButton
extends Control

signal game_selected(micro_game_info : MicroGameInfo, origin : GameSelectButton)

@onready var button := $Button
@onready var highlight_panel := $HighlightPanel

var game_info : MicroGameInfo:
	set(new):
		game_info = new
		if new != null:
			button.text = new.title.to_upper()
		else:
			button.text = "error: no game"

func _on_button_pressed():
	game_selected.emit(game_info, self)
	highlight_panel.show()

func hide_highlight():
	highlight_panel.hide()
