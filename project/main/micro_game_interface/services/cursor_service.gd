extends Resource
class_name CursorService

func reset_cursor() -> void:
	for i in range(0, 17):
		Input.set_custom_mouse_cursor(null, i)
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
