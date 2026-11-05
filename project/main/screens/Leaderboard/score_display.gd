extends Control

@onready var medal_texture_rect := $HBoxContainer/Left/HBoxContainer/MedalTextureRect
@onready var rank_label := $HBoxContainer/Left/HBoxContainer/RankLabel
@onready var name_label := $HBoxContainer/Left/HBoxContainer/NameLabel
@onready var score_label := $HBoxContainer/Right/CenterContainer/ScoreLabel
@onready var colour_rect := $ColorRect
@onready var highlight := $Highlight

var score_res : ScoreResource:
	set(new):
		score_res = new
		if new == null:
			return
		name_label.text = score_res.player_name
		score_label.text = str(score_res.score)

var rank : int:
	set(new):
		rank = new
		rank_label.text = str(rank) + "."
		match rank:
			1:
				medal_texture_rect.texture = load("res://main/screens/Leaderboard/gold_medal.png")
			2:
				medal_texture_rect.texture = load("res://main/screens/Leaderboard/silver_medal.png")
			3:
				medal_texture_rect.texture = load("res://main/screens/Leaderboard/bronze_medal.png")

var colour : Color:
	set(new):
		colour = new
		colour_rect.color = colour

func highlight_score(yes : bool):
	highlight.visible = yes
