extends HBoxContainer
class_name DigitDisplay 

var digits : Array[Texture2D] = [
	preload("res://main/assets/digits/digit0.png"),
	preload("res://main/assets/digits/digit1.png"),
	preload("res://main/assets/digits/digit2.png"),
	preload("res://main/assets/digits/digit3.png"),
	preload("res://main/assets/digits/digit4.png"),
	preload("res://main/assets/digits/digit5.png"),
	preload("res://main/assets/digits/digit6.png"),
	preload("res://main/assets/digits/digit7.png"),
	preload("res://main/assets/digits/digit8.png"),
	preload("res://main/assets/digits/digit9.png")
]

var digit_scene : PackedScene = preload("res://main/screens/game/digit.tscn")

func _ready() -> void:
	set_number(0)

func clear():
	for child in get_children():
		remove_child(child)
		child.queue_free()

func set_number(val : int):
	clear()
	if val == 0:
		var new_d = digit_scene.instantiate()
		new_d.texture = digits[0]
		add_child(new_d)
	
	while val != 0:
		var digit = val % 10
		var new_d = digit_scene.instantiate()
		new_d.texture = digits[digit]
		add_child(new_d)
		val /= 10
		move_child(new_d, 0)
		
	
