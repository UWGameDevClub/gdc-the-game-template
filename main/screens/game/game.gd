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
@export var game_loader : MicroGameCache 

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

func _input(event : InputEvent):
	if Input.is_action_just_pressed("early_exit"):
		requested_end = true
		
	elif Input.is_action_just_pressed("screenshot"):
		pass 
		# save_thumbnail()

func _set_time_scale(scale : float):
	Engine.time_scale = scale
	music_player.pitch_scale = lerp(1.0, 2.0, 1.0 - exp(1.0 - scale))
	
var current_game : MicroGame
var default_timer : MicroGameTimer
var game_timed_out : bool
var game_over : bool

var lives = 3
var score = 0
var speed_mult = 1
var speed_up_in = speed_up_frequency

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

	lives = 3
	score = 0
	speed_mult = 1
	speed_up_in = speed_up_frequency

	_set_time_scale(1)

	current_game = null
	default_timer = null
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

func setup_micro_game(micro_game : MicroGame, info : MicroGameInfo):
	if micro_game.timer == null:
		default_timer = null
		
		if micro_game.timer_type != MicroGame.DefaultTimerType.CustomTimer:
			default_timer = default_timers[micro_game.timer_type].instantiate()
			$GameLayer.add_child(default_timer)

		elif micro_game.timer == null:
			push_warning("a micro_game with a custom timer did not provide it!")
			default_timer = default_timer_no_UI.instantiate()
			$GameLayer.add_child(default_timer)
			
		micro_game.timer = default_timer
	
	if info.width > 0 and info.height > 0:
		game_viewport.size_2d_override.x = info.width
		game_viewport.size_2d_override.y = info.height
	
	else:
		game_viewport.size_2d_override.x = 0
		game_viewport.size_2d_override.y = 0
	
	current_game = micro_game
	game_timed_out = false

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

func play_instruction_sequence(info : MicroGameInfo):
	$GameLayer.visible = false
	$InfoLayer.visible = true 
		
	var inst = instructions.instantiate()	
	$InfoLayer.add_child(inst)
	
	if inst.has_method("display_controls"):
		await inst.display_controls(info)
	
	var tex2d = await capture_viewport()
	await get_tree().create_timer(1.5).timeout
	
	game_viewport.add_child(current_game)
	
	# some games set the value in on ready so i need to run this here
	if default_timer and default_timer.has_method("set_display_time"):
		default_timer.set_display_time(current_game.game_duration)
			
	await play_wipe(
		screen_wipe, tex2d,
		(
		func ():
		$GameLayer.visible = true
		$InfoLayer.visible = false 
		clear_info_layer()
		)
	)


func play_end_sequence(packed_scene, old, new):
	var tex2d = await capture_viewport()
	
	$GameLayer.visible = true
	$InfoLayer.visible = false 
	
	var win = packed_scene.instantiate()
	$InfoLayer.add_child(win)
	if win.has_method("set_initial_value"):
		win.set_initial_value(old)
	
	unload_game()
	if current_game:
		await get_tree().process_frame
	
	_reset_cursor()
	resume_music()
	_set_time_scale(speed_mult)
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		
	await play_wipe(
		screen_wipe, tex2d,
		(
		func ():
		$GameLayer.visible = false
		$InfoLayer.visible = true 
		)
	)
	
	
	if win.has_method("animate_value_change"):
		await win.animate_value_change(old, new)
	

func play_speedup_animation(packed_scene):
	$GameLayer.visible = false
	$InfoLayer.visible = true 
	
	var animation = packed_scene.instantiate()
	$InfoLayer.add_child(animation)
	
	if animation.has_method("play"):
		await animation.play()


func start_game():
	print("playing game: ", game_selector.current_game.title, " lives: ", lives, " score: ", score)
	
	game_over = false
	
	current_game.timer.timeout.connect(on_game_timeout)
	current_game.win.connect(on_game_end.bind(true))
	current_game.lose.connect(on_game_end.bind(false))
	
	current_game.pause_music.connect(pause_music)
	current_game.resume_music.connect(resume_music)
	
	print("playing instructions")
	await play_instruction_sequence(game_selector.current_game)
	
	if game_selector.current_game.start_with_music_paused:
		pause_music()
	else:
		resume_music()
	
	if not game_selector.current_game.force_hide_mouse and \
		game_selector.current_game.control_format != MicroGame.ControlFormat.KeyboardOnly:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
	_set_time_scale(speed_mult)
	
	if current_game.pre_game_time > 0.001:
		current_game.enter_animation.emit()
		await get_tree().create_timer(current_game.pre_game_time).timeout
	
	current_game.start.emit()
	current_game.timer.start(current_game.game_duration)

func on_game_timeout():
	if game_over:
		return
		
	game_timed_out = true
	if current_game.lose_on_timeout:
		current_game.lose.emit()
	else:
		current_game.win.emit()

func on_game_end(win: bool):
	if game_over:
		return
	print("ending game! ", win)
		
	game_over = true
	
	_set_time_scale(speed_mult)
	
	if current_game:
		current_game.timer.stop()
		await get_tree().create_timer(current_game.post_game_time).timeout
		
		print("playing end seq")
		if win:
			
			await play_end_sequence(score_up, score, score + 1)
			
			score += 1
			
			speed_up_in -= 1
			if speed_up_in <= 0:
				speed_mult += speed_inc
				speed_up_in = speed_up_frequency
				
				await get_tree().create_timer(1.5).timeout
				await play_speedup_animation(speed_up)
				await get_tree().create_timer(0.5).timeout
				_set_time_scale(speed_mult)
			
		else:
			await play_end_sequence(lives_down, lives, lives - 1)
			lives -= 1
			
		await get_tree().create_timer(1.5).timeout
		
	play_next_game()

func unload_game():
	if default_timer:
		default_timer.queue_free()
	
	if current_game:
		current_game.pause_music.disconnect(pause_music)
		current_game.resume_music.disconnect(resume_music)
		current_game.queue_free()
	
	game_viewport.size_2d_override.x = 0
	game_viewport.size_2d_override.y = 0

func play_next_game():
	if lives == 0 or requested_end:
		print("game done!")
		clear_info_layer()
		if !is_practice:
			GameManager.go_to_end()
			score_achieved.emit(score)
		else:
			GameManager.go_to_level_select()
		game_finished.emit()
		return
	
	var micro_game : MicroGame = \
		game_loader.load_game(
			game_selector.get_next_game())
	
	if micro_game == null:
		push_error("failed to load another game!")
		clear_info_layer()
		GameManager.go_to_end()

	else:
		setup_micro_game(micro_game, game_selector.current_game)
		start_game()

func make_transition_context():
	var context = TransitionContext.new()
	context.root = self
	context.background_layer = $Background
	context.game_layer = $GameLayer
	context.overlay_layer = $TransitionOverlay
	context.music_player = $MusicPlayer
	return context

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
	lives = 0
	play_next_game()
	
