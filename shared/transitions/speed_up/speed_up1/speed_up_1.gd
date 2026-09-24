extends Control


@onready var icon = %icon

func hide_all():
	icon.visible = false
	
func _ready() -> void:
	hide_all()

func play():
	hide_all()
	await pop_in(icon, Vector2(0.1, 0.1))
	
func pop_in(inp : Control, start_at : Vector2):
	var original_scale = inp.scale
	inp.scale = start_at
	inp.visible = true
	
	var tween = create_tween()
	tween.tween_property(inp, "scale", original_scale, 0.25)\
		.set_trans(Tween.TRANS_EXPO)
	await tween.finished
