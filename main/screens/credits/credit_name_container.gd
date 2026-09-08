class_name _CreditNameContainer
extends Control

const animation_time : float = 0.2

@onready var info_container := $InfoContainer
@onready var name_label := $NameLabel
@onready var info_label := $InfoContainer/Panel/MarginContainer/InfoLabel

var credit_name : StringName:
	set(new):
		credit_name = new
		name_label.text = "[center]" + new.to_upper()
var info : String:
	set(new):
		info = new
		info_label.text = new
var link : String:
	set(new):
		link = new
		if link != "":
			name_label.text = "[center][url=" + new + "]" + credit_name.to_upper() + "[/url]"

func _on_name_label_mouse_entered():
	print("hello")
	var t := create_tween()
	t.set_trans(Tween.TRANS_QUAD)
	t.set_ease(Tween.EASE_IN_OUT)
	t.tween_property(info_container, "scale", Vector2(1,1), animation_time)


func _on_name_label_mouse_exited():
	var t := create_tween()
	t.set_trans(Tween.TRANS_QUAD)
	t.set_ease(Tween.EASE_IN_OUT)
	t.tween_property(info_container, "scale", Vector2(1,0), animation_time)


func _on_name_label_meta_clicked(meta):
	OS.shell_open(str(meta))
