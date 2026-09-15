class_name _CreditNameContainer
extends Control

const animation_time : float = 0.2

@onready var info_container := $InfoContainer
@onready var name_label := $NameLabel
@onready var info_label := $InfoContainer/Panel/MarginContainer/HBoxContainer/InfoLabel
@onready var icon_panel := $InfoContainer/Panel/MarginContainer/HBoxContainer/Panel
@onready var icon_rect := $InfoContainer/Panel/MarginContainer/HBoxContainer/Panel/MarginContainer/CreditIcon

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
var icon : Texture:
	set(new):
		icon = new
		icon_rect.texture = icon
		icon_panel.visible = icon != null

func _on_mouse_entered():
	var t := create_tween()
	t.set_trans(Tween.TRANS_QUAD)
	t.set_ease(Tween.EASE_IN_OUT)
	t.tween_property(info_container, "scale", Vector2(1,1), animation_time)
	t.parallel().tween_property(self, "custom_minimum_size", Vector2(0, 50 + info_container.size.y), animation_time)


func _on_mouse_exited():
	var t := create_tween()
	t.set_trans(Tween.TRANS_QUAD)
	t.set_ease(Tween.EASE_IN_OUT)
	t.tween_property(info_container, "scale", Vector2(1,0), animation_time)
	t.parallel().tween_property(self, "custom_minimum_size", Vector2(0, 50), animation_time)


func _on_name_label_meta_clicked(meta):
	OS.shell_open(str(meta))
