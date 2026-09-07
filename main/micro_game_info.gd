extends Resource
class_name MicroGameInfo

@export_group("Microgame Info")

@export var title: String
@export var authors: String
@export_multiline var description: String
@export var instruction: String

@export var thumbnail : Texture2D

@export var game_scene : PackedScene



@export_group("Rendering")
@export var width : int = -1
@export var height : int = -1


@export_group("Input")

@export var control_format : MicroGame.ControlFormat = MicroGame.ControlFormat.MouseAndKeyboard
@export var force_hide_mouse : bool = false

@export_group("Custom Transitions")
@export var micro_game_event : Transition = null

@export_group("Music")
@export var start_with_music_paused : bool = false

@export_group("Advanced")
@export var custom_credit_display : PackedScene = null
@export var custom_credit_settings : Resource = null
