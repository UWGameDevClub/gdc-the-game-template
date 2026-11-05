extends Control
class_name Game

signal score_achieved(_score: int)
signal game_finished

@export_group("Timers")

@export var default_timer_no_UI : PackedScene
@export var default_timer_with_UI : PackedScene

@onready var default_timers = [
	default_timer_no_UI, 
	default_timer_with_UI
]

@export_group("Transitions")

@export var start_screen : PackedScene
@export var screen_wipe : PackedScene
@export var score_up : PackedScene
@export var speed_up : PackedScene
@export var lives_down : PackedScene
@export var instructions : PackedScene


@export_group("Micro Games")
@export var selection : MicroGameSelection:
	set(new):
		selection = new
		if is_node_ready() and game_selector != null and new != null:
			print(new.selected_games)
			game_selector.reload(selection.selected_games)
			game_selector.reset()

@export var game_selector : GameSelector
## TODO: CLEANUP ## @export var game_loader : MicroGameCache 

@export_group("Speed Up")
@export var speed_up_frequency = 10
@export var speed_inc = 0.1


@onready var music_player : AudioStreamPlayer = $MusicPlayer

@onready var practice_mode_hint := $PracticeLayer/PracticeModeHint

var requested_end : bool = false

var is_practice : bool = false:
	set(new):
		practice_mode_hint.visible = new
		is_practice = new
		print("PRACTICE MODE: ", is_practice)

func _ready() -> void:
	GameManager.enter_screen.connect(on_screen_enter)
	GameManager.exit_screen.connect(on_screen_exit)
	GameManager.refresh_ui.connect(on_rebuild)


func _reset_cursor() -> void:
	for i in range(0, 17):
		Input.set_custom_mouse_cursor(null, i)
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _input(_event : InputEvent):
	if Input.is_action_just_pressed("early_exit"):
		requested_end = true
		
	elif Input.is_action_just_pressed("screenshot"):
		pass 
		# save_thumbnail()

func _set_time_scale(new_time_scale : float):
	Engine.time_scale = new_time_scale
	music_player.pitch_scale = lerp(1.0, 2.0, 1.0 - exp(1.0 - new_time_scale))


var loaded_games : Dictionary[MicroGameInfo, MicroGameBuilder] = {}

var game_over : bool

var run_data : RunData


func on_rebuild(screen):
	if screen != GameManager.Screen.Game:
		return
		
	game_selector.reload(selection.selected_games)
	resume_music()

func on_screen_enter(screen):
	requested_end = false
	
	if screen != GameManager.Screen.Game:
		if music_player.bus != "bgm_muffled":
			music_player.bus = "bgm_muffled"
		resume_music()
		_reset_cursor()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		clear_info_layer()
		return
	
	resume_music()
	music_player.bus = "bgm_clean"
	
	_reset_cursor()
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	start_new_run(selection)

func start_new_run(new_selection : MicroGameSelection):
	selection = new_selection
	game_selector.reload(selection.selected_games)
	run_data = RunData.new()
	run_data.lives = 3
	run_data.score = 0
	run_data.speed_mult = 1
	run_data.speed_up_in = speed_up_frequency

	_set_time_scale(1)

	play_next_game()

func on_screen_exit(screen):
	if screen != GameManager.Screen.Game:
		return
	music_player.stop()
	
	_reset_cursor()
	_set_time_scale(1)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func save_thumbnail():
	if game_selector.current_game != null:
		var img = game_viewport.get_texture().get_image()
		img.save_png("user://%s.png" % 
			game_selector.current_game.title.replace(" ", "_"))

@onready var game_viewport = %GameViewport
@onready var in_game_ui = "."



func play_wipe(wipe : PackedScene, tex2d : Texture2D, callback : Callable):
	var w = wipe.instantiate()
	$TransitionOverlay.add_child(w)
	if w.has_method("wipe"):
		await w.wipe(tex2d, callback)
	else:
		callback.call()
	w.queue_free()

func clear_info_layer():
	for c in $InfoLayer.get_children():
		c.queue_free()

func capture_viewport():
	await RenderingServer.frame_post_draw
	var img = get_tree().root.get_texture().get_image()
	var screenshot = ImageTexture.create_from_image(img)
	return screenshot






func play_next_game():
	if run_data.lives == 0 or requested_end:
		print("run over!")
		clear_info_layer()
		if !is_practice:
			GameManager.go_to_end()
			score_achieved.emit(run_data.score)
		else:
			GameManager.go_to_level_select()
		game_finished.emit()
		return
	
	var current_info = game_selector.get_next_game()
	if current_info == null:
		push_error("failed to load another game!")
		clear_info_layer()
		GameManager.go_to_end.call_deferred()
		return

	setup_micro_game()
	start_game()

func setup_micro_game():
	var current_info = game_selector.current_game
	if not loaded_games.has(current_info):
		loaded_games[current_info] = MicroGameBuilder.new()
		loaded_games[current_info].set_info(current_info)
		loaded_games[current_info].set_audio_service(AudioService.new(music_player))
		loaded_games[current_info].default_timer_no_UI = default_timer_no_UI
		loaded_games[current_info].default_timer_with_UI = default_timer_with_UI

	loaded_games[current_info].set_run_data(run_data)
	loaded_games[current_info].load_instance()


func unload_game():
	var current_info = game_selector.current_game
	loaded_games[current_info].unload_instance()
	
	game_viewport.size_2d_override.x = 0
	game_viewport.size_2d_override.y = 0


func start_game():
	print(
		"playing game: ", game_selector.current_game.title, 
		" lives: ", run_data.lives, 
		" score: ", run_data.score)
	
	game_over = false
	
	var current_info = game_selector.current_game
	var current_instance = loaded_games[current_info].loaded_instance
	if current_instance == null:
		unload_game()
		play_next_game()
		return
		
	var error = current_instance.connect("done", on_game_end)
	if error != OK:
		unload_game()
		play_next_game()
		return
	
	
	print("playing instructions")
	await play_instruction_sequence(game_selector.current_game)
	
	if game_selector.current_game.start_with_music_paused:
		pause_music()
	else:
		resume_music()
	
	if game_selector.current_game.start_with_mouse_hidden:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	_set_time_scale(run_data.speed_mult)
	
	#if current_game.pre_game_time > 0.001:
		#current_game.enter_animation.emit()
		#await get_tree().create_timer(current_game.pre_game_time).timeout
	
	#current_game.start.emit()
	#current_game.timer.start(current_game.game_duration)


func play_instruction_sequence(info : MicroGameInfo):
	$GameLayer.visible = false
	$InfoLayer.visible = true 
		
	var inst = instructions.instantiate()	
	$InfoLayer.add_child(inst)
	
	if inst.has_method("display_controls"):
		await inst.display_controls(info)
	
	var tex2d = await capture_viewport()
	await get_tree().create_timer(1.5).timeout
	
	loaded_games[game_selector.current_game].add_instance_to_scene($GameLayer, game_viewport)
	
	# some games set the value in on ready so i need to run this here
	#if default_timer and default_timer.has_method("set_display_time"):
		#default_timer.set_display_time(current_context.game_duration)
	var callback = func():
		$GameLayer.visible = true
		$InfoLayer.visible = false 
		clear_info_layer()
	
	await play_wipe(screen_wipe, tex2d, callback)


func play_end_sequence(packed_scene, old, new):
	var tex2d = await capture_viewport()
	
	$GameLayer.visible = true
	$InfoLayer.visible = false 
	
	var win = packed_scene.instantiate()
	$InfoLayer.add_child(win)
	if win.has_method("set_initial_value"):
		win.set_initial_value(old)
	
	unload_game()
	
	## why is this here?
	await get_tree().process_frame
	
	_reset_cursor()
	resume_music()
	_set_time_scale(run_data.speed_mult)
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
	var callback = func():
		$GameLayer.visible = false
		$InfoLayer.visible = true 
		
	await play_wipe(screen_wipe, tex2d, callback)
	
	
	if win.has_method("animate_value_change"):
		await win.animate_value_change(old, new)
	
	await get_tree().create_timer(1.5).timeout


func on_game_end(win: bool):
	if game_over:
		return
	print("ending game! ", win)
		
	game_over = true
	
	_set_time_scale(run_data.speed_mult)
	
	if game_selector.current_game != null:
		# this signal gets emitted when the context is ready for clean up
		# hence we no longer need this here
		#current_game.timer.stop()
		#await get_tree().create_timer(current_game.post_game_time).timeout
		
		print("playing end seq")
		if win:
			
			run_data.speed_up_in -= 1
			if run_data.speed_up_in <= 0:
				run_data.speed_mult += run_data.speed_inc
				run_data.speed_up_in = run_data.speed_up_frequency
			
			await play_end_sequence(score_up, run_data.score, run_data.score + 1)
			
			run_data.score += 1
			
			#await speed_up_transtion.execute(
				#make_transition_context(), 
				#SpeedUpEvent.new())
			
			
		else:
			await play_end_sequence(lives_down, run_data.lives, run_data.lives - 1)
			run_data.lives -= 1
			
		
	play_next_game()

func pause_music():
	if not music_player.stream_paused:
		music_player.stream_paused = true

func resume_music():
	if music_player.stream_paused:
		music_player.stream_paused = false
	
	if not music_player.playing:
		music_player.play()

# Used by level select to quit early, meant for practice mode
# doesn't currently work mid game-transition, leads to bugs and occasional crashes
func force_quit_game():
	return
	unload_game()
	run_data.lives = 0
	play_next_game()
	
