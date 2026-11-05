extends Resource
class_name MicroGameBuilder 


@export var default_timer_no_UI : PackedScene
@export var default_timer_with_UI : PackedScene

var loaded_instance : Node
var loaded_default_timer : Node

var info : MicroGameInfo 
var audio_service : AudioService
var micro_game_data : MicroGameData
var run_data : RunData


func set_info(new_info):
	unload_instance()
	info = new_info
	
	micro_game_data = MicroGameData.new()
	if info.initial_custom_data != null:
		if info.deep_copy:
			micro_game_data.custom = info.initial_persistant_state.deepcopy()
		else:
			micro_game_data.custom = info.initial_persistant_state.copy()
	

func set_run_data(new_run_data : RunData):
	if not run_data:
		run_data = RunData.new()
		run_data.copy_from(new_run_data)
		
	run_data.copy_from(new_run_data)


func set_audio_service(new_audio_service):
	audio_service = new_audio_service



func load_instance(canvas_layer : CanvasLayer, viewport : SubViewport):
	loaded_instance = info.game_scene.instaniate()

	if load_instance == null: return null

	if info.timer_type != MicroGameInfo.TimerType.CustomTimer:
		loaded_default_timer = null
		var default_timers = [default_timer_no_UI, default_timer_with_UI]
		loaded_default_timer = default_timers[info.timer_type].instantiate()
		canvas_layer.add_child(loaded_default_timer)
		
		if "timer" in loaded_instance:
			loaded_instance.timer = loaded_default_timer
	
	if info.width > 0 and info.height > 0:
		viewport.size_2d_override.x = info.width
		viewport.size_2d_override.y = info.height
	
	else:
		viewport.size_2d_override.x = 0
		viewport.size_2d_override.y = 0

	if "micro_game_data" in loaded_instance:
		loaded_instance.micro_game_data = micro_game_data
	
	if "run_data" in loaded_instance:
		loaded_instance.run_data = run_data
	
	if "audio_service" in loaded_instance:
		loaded_instance.audio_service = audio_service

	if "info" in loaded_instance:
		loaded_instance.info = info

	if loaded_instance.has_method("on_load"):
		loaded_instance.on_load()
	
	viewport.add_child(loaded_instance)


func unload_instance():
	if loaded_instance and loaded_instance.has_method("on_unload"):
		loaded_instance.on_unload()
	
		loaded_instance.queue_free()
	if loaded_default_timer:
		loaded_default_timer.queue_free()

	loaded_instance = null
	loaded_default_timer = null
