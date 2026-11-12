extends Resource
class_name MicroGameInfo

enum TimerType {
	DefaultNoUI,
	DefaultWithUI,
	CustomTimer
}

enum ControlFormat {
	MouseOnly,
	KeyboardOnly,
	MouseAndKeyboard
}


@export_group("Microgame Info")

@export var thumbnail : Texture2D

@export var title: String
@export var authors: String
@export_multiline var description: String
@export var instruction: String

@export var game_scene : PackedScene

#@export_group("Timers")

@export_group("Input")

@export var control_format : ControlFormat = ControlFormat.MouseAndKeyboard
@export var start_with_mouse_hidden : bool = false
@export var curser_settings : CursorSetting = null

@export_group("Rendering")
@export var width : int = -1
@export var height : int = -1

@export_group("Music")
@export var start_with_music_paused : bool = false

@export_group("Advanced")
#var _initialized_context : MicroGameContext = null
#@export var context : MicroGameContext = null

@export_category("Custom Data")
@export var initial_custom_data : Dictionary
@export var make_deep_copy : bool = true
@export var deep_subresource_mode : Resource.DeepDuplicateMode = DEEP_DUPLICATE_INTERNAL


#@export_group("Deprecated")

## @deprecated: Set this value in MicroGame
var timer_type : TimerType = TimerType.DefaultWithUI

## @deprecated: Set this value in MicroGame
var default_game_duration : float = 10

## @deprecated: Use [member start_with_mouse_hidden] instead.
var force_hide_mouse : bool = false

## @deprecated: This is a surprise tool that will help us later.
var custom_credit_display : PackedScene = null

## @deprecated: So is this. See also [member custom_credit_display]
var custom_credit_settings : Resource = null

## @deprecated: Use [property start_with_mouse_hidden] instead.
## I know I made three of these. What are you gonna do about it?
var mouse_hidden : bool = false
