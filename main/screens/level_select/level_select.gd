extends ScreenRoot

@onready var game_select_scene : PackedScene = preload("res://main/screens/level_select/game_select_button.tscn")
@onready var game_list_container := $MarginContainer/HBoxContainer/GamesContainer/VBoxContainer/Control/MarginContainer/Control/GameListContainer/VBoxContainer
@onready var mouse_image := $MarginContainer/HBoxContainer/InfoContainer/VBoxContainer/HBoxContainer/ControlsInfoContainer/Mouse
@onready var keyboard_image := $MarginContainer/HBoxContainer/InfoContainer/VBoxContainer/HBoxContainer/ControlsInfoContainer/Keyboard
@onready var mouse_and_keyboard_image := $MarginContainer/HBoxContainer/InfoContainer/VBoxContainer/HBoxContainer/ControlsInfoContainer/MouseAndKeyboard
@onready var title_label := $MarginContainer/HBoxContainer/InfoContainer/VBoxContainer/HBoxContainer/GameNameLabel
@onready var thumbnail := $MarginContainer/HBoxContainer/InfoContainer/VBoxContainer/ImageContainer/MarginContainer/ThumbnailContainer/Thumbnail
@onready var description_label := $MarginContainer/HBoxContainer/InfoContainer/VBoxContainer/DescriptionContainer/VBoxContainer/DescriptionLabel
@onready var credit_label := $MarginContainer/HBoxContainer/InfoContainer/VBoxContainer/DescriptionContainer/VBoxContainer/HBoxContainer/CreditLabel
@onready var play_button := $MarginContainer/HBoxContainer/InfoContainer/VBoxContainer/Buttons/GoToGame

@export var game : Game

var last_selected_button : GameSelectButton
var game_list : MicroGameSelection
var game_info : MicroGameInfo:
	set(new):
		game_info = new
		if new != null:
			game.is_practice = true
			set_credits(new.authors)
			set_image(new.thumbnail)
			set_description(new.description)
			set_controls(new.control_format)
			set_title(new.title)
			play_button.disabled = false
			var selection := MicroGameSelection.new()
			selection.add(new)
			game.selection = selection
		else:
			set_credits("")
			set_image(null)
			set_description("")
			set_controls(-1)
			set_title("")
			play_button.disabled = true
			

func _ready() -> void:
	super()
	game.connect("game_finished", _practice_finished)
	game_list = game.selection
	game_info = null
	for info in game_list.selected_games:
		var new_button : GameSelectButton = game_select_scene.instantiate()
		game_list_container.add_child(new_button)
		new_button.game_info = info
		new_button.connect("game_selected", _select_game)



func _select_game(game_info : MicroGameInfo, button : GameSelectButton):
	if last_selected_button != null:
		last_selected_button.hide_highlight()
	last_selected_button = button
	self.game_info = game_info

func set_description(text : String):
	description_label.text = text

func set_image(image : Texture2D):
	thumbnail.texture = image

func set_credits(text : String):
	if len(text) == 0:
		credit_label.text = ""
	else:
		credit_label.text = "By " + text

func set_controls(type : MicroGame.ControlFormat):
	mouse_image.hide()
	keyboard_image.hide()
	mouse_and_keyboard_image.hide()
	match type:
		MicroGame.ControlFormat.MouseOnly:
			mouse_image.show()
		MicroGame.ControlFormat.KeyboardOnly:
			keyboard_image.show()
		MicroGame.ControlFormat.MouseAndKeyboard:
			mouse_and_keyboard_image.show()
		

func set_title(text : String):
	title_label.text = text.to_upper()


func _on_visibility_changed():
	if !is_node_ready():return
	if visible:
		game_info = null
		if last_selected_button != null:
			last_selected_button.hide_highlight()

func _practice_finished():
	game.is_practice = false
	


func _on_go_to_main_menu_pressed():
	game.is_practice = false
	game.selection = game_list
	
