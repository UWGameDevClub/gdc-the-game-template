extends LineEdit

signal name_created
signal name_deleted

func _on_text_changed(new_text:String):
	var caret_pos := caret_column
	text = new_text.to_upper()
	caret_column = caret_pos
	if len(new_text) > 0: name_created.emit()
	else: name_deleted.emit()
