extends Control

@export var score_number : DigitDisplay

func set_initial_value(val : int):
	score_number.set_number(val)
	
func animate_value_change(old_val : int, new_val : int):
	score_number.pivot_offset_ratio = Vector2(0.5, 0.5)
	var original_scale = score_number.scale
	var tween = create_tween()
	tween.tween_property(score_number, "scale", original_scale * Vector2(1.25, 1.25), 0.25)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_callback(score_number.set_number.bind(new_val))
	tween.tween_property(score_number, "scale", original_scale, 0.1)\
		.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	
	await tween.finished
