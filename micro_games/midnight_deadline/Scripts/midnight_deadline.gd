extends MicroGame
class_name MidnightDeadline

const GameSFX = preload("res://micro_games/midnight_deadline/Scripts/game_sfx.gd")
#const AdPopupSmall := preload("res://micro_games/midnight_deadline/ad_popup_small.tscn")
#const AdPopupMedium := preload("res://micro_games/midnight_deadline/ad_popup_medium.tscn")
#const AdPopupLarge := preload("res://micro_games/midnight_deadline/ad_popup_large.tscn")
#const AD_POPUP_SCENES: Array[PackedScene] = [AdPopupSmall, AdPopupMedium, AdPopupLarge]

## Drag the essay into the browser's dropzone and hit Submit before the
## taskbar clock hits 12:00:00. Logic only - visuals live in the .tscn,
## referenced here via scene-unique names (%DropZone, %SubmitButton,
## %ClockLabel). Win/lose is decided by asking the dropzone whether the
## currently held file is the correct one.
##
## Gets slightly harder each time it's played (see `play_count`): from the
## 2nd play on, file_explorer_grid.gd adds extra filler files; from the 3rd
## play on, 3 fixed-size pop-up ads appear on startup - once closed, they
## stay closed for the rest of the round.

## How many times this microgame has been played in the current game
## session. A plain static var, not saved to disk - resets to 0 whenever
## GameManager returns to the main menu/title (see _install_reset_hook),
## which is what actually starts a "new run" - not just process restart,
## since a static var alone would otherwise keep climbing across every
## session for as long as the game stays open. Bumped in _init() (before
## any child's _ready()) so file_explorer_grid.gd sees the up-to-date count
## in time to use it while populating.
static var play_count := 0
static var _reset_hook_installed := false

@onready var dropzone = %DropZone
@onready var submit_button: BaseButton = %SubmitButton
@onready var clock_label: Label = %ClockLabel

var file_dropped := false
var game_ended := false
var countdown_active := false
var elapsed_time := 0.0
var seconds_ticked := 0

var _clock_default_color: Color


func _init() -> void:
	play_count += 1
	_install_reset_hook()


## Connects a STATIC callback (not bound to this instance, so it survives
## this instance being freed at round end) to GameManager's global screen
## signal exactly once, the first time this microgame is ever played.
## Hooked to exit_screen(Game) - the minigames going back to the menu -
## rather than any enter/exit of the menu screens themselves.
static func _install_reset_hook() -> void:
	if _reset_hook_installed:
		return
	_reset_hook_installed = true
	GameManager.exit_screen.connect(_on_global_screen_exited)


static func _on_global_screen_exited(screen: GameManager.Screen) -> void:
	if screen == GameManager.Screen.Game:
		play_count = 0


func _ready() -> void:
	set_process(false)
	_setup_cursors()
	_add_black_backdrop()
	# so the urgent-red pulse can restore it later instead of falling back to theme white
	_clock_default_color = clock_label.get_theme_color("font_color")

	dropzone.file_received.connect(_on_file_dropped)
	submit_button.disabled = true
	submit_button.pressed.connect(_on_submit_pressed)

	start.connect(_on_start)
	win.connect(_on_win)
	lose.connect(_on_lose)


## Godot's default viewport clear is grey, not black - this covers whatever
## the CRT shutoff reveals behind the shrinking picture.
func _add_black_backdrop() -> void:
	var backdrop := ColorRect.new()
	backdrop.name = "Backdrop"
	backdrop.color = Color.BLACK
	backdrop.size = get_viewport_rect().size
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	backdrop.z_index = -100
	add_child(backdrop)
	move_child(backdrop, 0)


func _on_start() -> void:
	elapsed_time = 0.0
	seconds_ticked = 0
	countdown_active = true
	set_process(true)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	clock_label.add_theme_color_override("font_color", _clock_default_color)
	_update_clock_label()
	_play_window_intro()
	_start_ads()


## From the 3rd play on, all 3 fixed-size ads appear together right as the
## round starts. No re-spawning - once closed, an ad is gone for the rest
## of the round.
func _start_ads() -> void:
	if play_count < 3:
		return
	#for scene in AD_POPUP_SCENES:
	#	_spawn_ad(scene)


## Positions the ad won't overlap - the two things you can't finish the
## round without touching. Ads are still allowed to cover the file grid
## (extra difficulty), just not these.
const AD_NO_SPAWN_PATHS := ["UI/BrowserWindow/DropZone", "UI/BrowserWindow/SubmitButton"]
const AD_PLACEMENT_ATTEMPTS := 20

func _spawn_ad(scene: PackedScene) -> void:
	var ad: Control = scene.instantiate()
	add_child(ad)
	var viewport_size := get_viewport_rect().size
	var max_x: float = maxf(10.0, viewport_size.x - ad.custom_minimum_size.x - 10.0)
	var max_y: float = maxf(60.0, viewport_size.y - ad.custom_minimum_size.y - 160.0)

	var no_spawn_rects: Array[Rect2] = []
	for path in AD_NO_SPAWN_PATHS:
		var node := get_node_or_null(path)
		if node:
			no_spawn_rects.append((node as Control).get_global_rect())

	var chosen_position := Vector2(randf_range(10.0, max_x), randf_range(60.0, max_y))
	for attempt in range(AD_PLACEMENT_ATTEMPTS):
		var candidate := Vector2(randf_range(10.0, max_x), randf_range(60.0, max_y))
		var candidate_rect := Rect2(candidate, ad.custom_minimum_size)
		var overlaps_protected_area := false
		for r in no_spawn_rects:
			if candidate_rect.intersects(r):
				overlaps_protected_area = true
				break
		if not overlaps_protected_area:
			chosen_position = candidate
			break

	ad.position = chosen_position
	ad.z_index = 250


func _process(delta: float) -> void:
	if not countdown_active:
		return

	elapsed_time += delta
	var whole_seconds := int(floor(elapsed_time))
	if whole_seconds > seconds_ticked:
		seconds_ticked = whole_seconds
		_update_clock_label()
		if seconds_ticked >= int(game_duration):
			countdown_active = false


func _update_clock_label() -> void:
	var duration := int(game_duration)
	var urgent := false
	if seconds_ticked >= duration:
		clock_label.text = "12:00:00"
		urgent = true
	else:
		var seconds_before_midnight := duration - seconds_ticked
		clock_label.text = "11:59:%02d" % (60 - seconds_before_midnight)
		urgent = seconds_before_midnight <= 2
	_pulse_clock(urgent)


## Per-second pulse, sharper and red-tinted in the last couple seconds.
func _pulse_clock(urgent: bool) -> void:
	clock_label.pivot_offset = clock_label.size * 0.5
	clock_label.scale = Vector2(1.16, 1.16) if urgent else Vector2(1.06, 1.06)
	var tween := create_tween()
	tween.tween_property(clock_label, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if urgent:
		clock_label.add_theme_color_override("font_color", Color(0.45, 0.05, 0.05))
		GameSFX.play(self, "res://micro_games/midnight_deadline/Assets/clock.wav", 0.0)
	else:
		GameSFX.play(self, "res://micro_games/midnight_deadline/Assets/clock.wav", -8.0)


## Scale/fade pop-in for the two windows once the round starts.
func _play_window_intro() -> void:
	for path in ["UI/FileExplorerWindow", "UI/BrowserWindow"]:
		var window := get_node_or_null(path)
		if not window:
			continue
		window.pivot_offset = window.size * 0.5
		window.scale = Vector2(0.9, 0.9)
		window.modulate.a = 0.0
		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(window, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(window, "modulate:a", 1.0, 0.2)


func _on_file_dropped() -> void:
	file_dropped = true
	submit_button.disabled = false


func _on_submit_pressed() -> void:
	if game_ended or not file_dropped:
		return
	game_ended = true
	if dropzone.dropped_file_correct:
		win.emit()
	else:
		lose.emit()


func _on_win() -> void:
	_end_round()
	_show_end_feedback(true)


func _on_lose() -> void:
	_end_round()
	_show_end_feedback(false)


func _end_round() -> void:
	game_ended = true
	countdown_active = false
	set_process(false)
	dropzone.lock()
	_lock_interactions()
	_clear_ads()


func _clear_ads() -> void:
	for child in get_children():
		if child.is_in_group("ad_popup"):
			child.queue_free()


## Blocks further interaction once the round ends, and hides the OS cursor
## (it renders above any in-game overlay otherwise, incl. the CRT shutoff).
func _lock_interactions() -> void:
	submit_button.disabled = true
	var blocker := Control.new()
	blocker.name = "InputBlocker"
	blocker.mouse_filter = Control.MOUSE_FILTER_STOP
	blocker.size = get_viewport_rect().size
	blocker.z_index = 200
	add_child(blocker)
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


func _show_end_feedback(is_win: bool) -> void:
	var target_color: Color = Color(0.1, 0.85, 0.25, 0.35) if is_win else Color(0.9, 0.1, 0.1, 0.35)
	var overlay := ColorRect.new()
	overlay.color = Color(target_color.r, target_color.g, target_color.b, 0.0)
	overlay.size = get_viewport_rect().size
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Parented to UI so it collapses with everything else during the shutoff.
	var ui := get_node_or_null("UI")
	if ui:
		ui.add_child(overlay)
		# Must draw before CRTFilter so the shader's screen capture picks it up.
		var crt_filter := ui.get_node_or_null("CRTFilter")
		if crt_filter:
			ui.move_child(overlay, crt_filter.get_index())
	else:
		add_child(overlay)
	var tween := create_tween()
	tween.tween_property(overlay, "color:a", target_color.a, 0.25).set_trans(Tween.TRANS_SINE)

	if is_win:
		GameSFX.play(self, "res://micro_games/midnight_deadline/Assets/CorrectAnswer.wav", -4.0)
	else:
		GameSFX.play(self, "res://micro_games/midnight_deadline/Assets/WrongAnswer.wav", -4.0)
		_shake_screen()

	# tv_off.wav gets a 0.5s head start on the visual collapse
	var sound_timer := get_tree().create_timer(0.5)
	sound_timer.timeout.connect(func(): GameSFX.play(self, "res://micro_games/midnight_deadline/Assets/tv_off.wav", -2.0))
	var shutoff_timer := get_tree().create_timer(1.0)
	shutoff_timer.timeout.connect(_play_crt_shutoff)


## Classic CRT power-off: collapses to a line, then a point.
func _play_crt_shutoff() -> void:
	var ui := get_node_or_null("UI")
	if not ui:
		return
	var viewport_size := get_viewport_rect().size
	ui.pivot_offset = viewport_size * 0.5
	var tween := create_tween()
	tween.tween_property(ui, "scale:y", 0.01, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(ui, "scale:x", 0.001, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	# scale never hits exactly 0 - hide it or a hairline sliver stays visible
	tween.tween_callback(func(): ui.visible = false)


func _shake_screen() -> void:
	var ui := get_node_or_null("UI")
	if not ui:
		return
	var base_pos: Vector2 = ui.position
	var shake_tween := create_tween()
	for i in range(3):
		shake_tween.tween_property(ui, "position", base_pos + Vector2(randf_range(-3.0, 3.0), randf_range(-3.0, 3.0)), 0.025)
	shake_tween.tween_property(ui, "position", base_pos, 0.025)


# set_custom_mouse_cursor() is global engine state - it stays applied after
# this microgame ends since Main never resets it (move to an autoload if
# that's not wanted).
## Cursor scale as authored at the 1920x1080 design resolution. The Game
## screen renders that design canvas into a SubViewport whose actual output
## buffer is often smaller (e.g. 1152x648), scaling everything down - but
## Input.set_custom_mouse_cursor() draws at native OS pixel size and knows
## nothing about that scaling, so DESIGN_CURSOR_SCALE alone would look
## oversized relative to the shrunk game visuals. _cursor_scale() corrects
## for that at runtime.
const DESIGN_CURSOR_SCALE := 3.0

## Offset into the scaled texture so the cursor's contact point lines up
## with the actual pointer position.
const CURSOR_HOTSPOT := Vector2(10, 10)


## Ratio between the SubViewport's real output size and its 2D design
## resolution (size_2d_override) - 1.0 when running standalone (no
## SubViewport wrapper) or when the two already match.
func _cursor_scale() -> float:
	var vp := get_viewport()
	if vp is SubViewport and vp.size_2d_override.x > 0:
		return DESIGN_CURSOR_SCALE * (float(vp.size.x) / float(vp.size_2d_override.x))
	return DESIGN_CURSOR_SCALE


func _setup_cursors() -> void:
	var arrow_texture := _load_cursor_texture("res://micro_games/midnight_deadline/Assets/cursor.png")
	var pointer_texture := _load_cursor_texture("res://micro_games/midnight_deadline/Assets/pointer.png")
	var cross_texture := _load_cursor_texture("res://micro_games/midnight_deadline/Assets/cross.png")
	Input.set_custom_mouse_cursor(arrow_texture, Input.CURSOR_ARROW, CURSOR_HOTSPOT)
	Input.set_custom_mouse_cursor(pointer_texture, Input.CURSOR_POINTING_HAND, CURSOR_HOTSPOT)
	Input.set_custom_mouse_cursor(pointer_texture, Input.CURSOR_DRAG, CURSOR_HOTSPOT)
	# shown automatically by Godot over valid drop targets / invalid ones
	Input.set_custom_mouse_cursor(pointer_texture, Input.CURSOR_CAN_DROP, CURSOR_HOTSPOT)
	Input.set_custom_mouse_cursor(cross_texture, Input.CURSOR_FORBIDDEN, CURSOR_HOTSPOT)


## Resized with nearest-neighbor to stay crisp, at whatever scale actually
## matches how large the game is being displayed right now.
func _load_cursor_texture(path: String) -> Texture2D:
	var scale := _cursor_scale()
	var img: Image = load(path).get_image()
	img.resize(
		int(img.get_width() * scale),
		int(img.get_height() * scale),
		Image.INTERPOLATE_NEAREST
	)
	return ImageTexture.create_from_image(img)
