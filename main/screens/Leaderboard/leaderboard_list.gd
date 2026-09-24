extends VBoxContainer

const colour_A := Color(1.0, 0.996, 0.996, 1.0)
const colour_B := Color(0.647, 0.824, 0.843, 1.0)

@export var leaderboard_name : String = "TODAY"
@onready var title_label := $TitleLabel
@onready var score_container := $OuterPanel/MarginContainer/InnerPanel/MarginContainer/ScrollContainer/ScoreContainer
@onready var score_display_scn : PackedScene = preload("res://main/screens/Leaderboard/ScoreDisplay.tscn")
@onready var loading_notification := $OuterPanel/MarginContainer/InnerPanel/MarginContainer/LoadingNotification
@onready var empty_notification := $OuterPanel/MarginContainer/InnerPanel/MarginContainer/EmptyNotification

var _use_colour_A : bool = true
var _rank : int = 1

func _ready():
	title_label.text = leaderboard_name

func _add_new_score(score_res:ScoreResource):
	var score_display = score_display_scn.instantiate()
	score_container.add_child(score_display)
	if _use_colour_A:
		score_display.colour = colour_A
	else:
		score_display.colour = colour_B
	_use_colour_A = ! _use_colour_A
	score_display.rank = _rank
	_rank += 1
	score_display.score_res = score_res


func highlight_name(name : String):
	for c in score_container.get_children():
		var scr_res : ScoreResource = c.score_res
		c.highlight_score(name == scr_res.player_name)


func show_loading_notification():
	loading_notification.show()
	empty_notification.hide()
	score_container.hide()


func display_score_list(scores:Array[ScoreResource]):
	_use_colour_A = true
	for c in score_container.get_children(): c.queue_free()
	empty_notification.hide()
	_rank = 1
	scores.sort_custom(func(a:ScoreResource, b:ScoreResource):return a.score > b.score)
	for s in scores:
		_add_new_score(s)
	loading_notification.hide()
	score_container.show()
	if len(scores) == 0:
		empty_notification.show()
