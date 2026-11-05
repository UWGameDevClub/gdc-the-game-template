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
		if info.make_deep_copy:
			micro_game_data.custom = info.initial_custom_data.duplicate_deep(info.deep_subresource_mode)
		else:
			micro_game_data.custom = info.initial_custom_data.duplicate()
	

func set_run_data(new_run_data : RunData):
	if not run_data:
		run_data = RunData.new()
		run_data.copy_from(new_run_data)
		
	run_data.copy_from(new_run_data)


func set_audio_service(new_audio_service):
	audio_service = new_audio_service



func validate() -> bool:
	return info.game_scene != null and info.game_scene.can_instantiate()

func add_instance_to_scene(canvas_layer : CanvasLayer, viewport : SubViewport):
	
	if info.start_with_mouse_hidden:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if loaded_default_timer:
		canvas_layer.add_child(loaded_default_timer)
	
	if info.width > 0 and info.height > 0:
		viewport.size_2d_override.x = info.width
		viewport.size_2d_override.y = info.height
	
	else:
		viewport.size_2d_override.x = 0
		viewport.size_2d_override.y = 0
		
	if loaded_instance:
		viewport.add_child(loaded_instance)
		

func load_instance():
	if info.game_scene == null or not info.game_scene.can_instantiate():
		return
	
	loaded_instance = info.game_scene.instantiate()

	if load_instance == null: 
		return

	if "timer_type" in loaded_instance and \
		loaded_instance.timer_type != MicroGameInfo.TimerType.CustomTimer:
		loaded_default_timer = null
		var default_timers = [default_timer_no_UI, default_timer_with_UI]
		loaded_default_timer = default_timers[info.timer_type].instantiate()
		
		if "timer" in loaded_instance:
			loaded_instance.timer = loaded_default_timer

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
	


func unload_instance():
	if loaded_instance: 
		if loaded_instance.has_method("on_unload"):
			loaded_instance.on_unload()
		loaded_instance.queue_free()
		
	if loaded_default_timer:
		loaded_default_timer.queue_free()

	loaded_instance = null
	loaded_default_timer = null
