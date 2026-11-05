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

var timer_type : TimerType = TimerType.DefaultWithUI
var default_game_duration : float = 10

var micro_game_event : Resource = null
var force_hide_mouse : bool = false
var custom_credit_display : PackedScene = null
var custom_credit_settings : Resource = null
var mouse_hidden : bool = false

### returns the micro game context
### buidls up a default context if a custom one is not provided
#func get_context() -> MicroGameContext:
	#if context == null:
		#context = MicroGameContext.new()
	#
	#if _initialized_context != context:
		##TODO: Set default values based on non advanced settings
		#context.initialize(self)
		#_initialized_context = context
	#
	#return context
