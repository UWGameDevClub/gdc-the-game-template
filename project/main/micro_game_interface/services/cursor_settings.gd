## Helper to store and apply custom mouse textures.
extends Resource
class_name CursorSetting

## Images for the various cursor shapes.
## The resource should be an Image or a Texture2D. 
## See also Input.set_custom_mouse_cursor
@export var images: Dictionary[Input.CursorShape, Resource]

## Hotspots for the various cursor shapes.
@export var hotspots: Dictionary[Input.CursorShape, Vector2]

## Used as a fallback for any hotspots that are not set.
## See also Input.set_custom_mouse_cursor
@export var default_cursor_hotspot : Vector2 = Vector2.ZERO

## Sets the default cursor shape to be used instead of CURSOR_ARROW
## See also Input.set_default_cursor_shape
@export var default_cursor_shape : Input.CursorShape = Input.CURSOR_ARROW


## Resets all custom cursor settings. 
static func clear_custom_cursor() -> void:
	for i in range(0, 17):
		Input.set_custom_mouse_cursor(null, i)
	Input.set_default_cursor_shape()

## Applies all the custom cursor settings.
func set_custom_cursor() -> void:
	clear_custom_cursor()
	for i in range(0, 17):
		if i not in images:
			continue
		var image = images.get(i, null)
		var hotspot = hotspots.get(i, default_cursor_hotspot)
		Input.set_custom_mouse_cursor(image, i, hotspot)
	Input.set_default_cursor_shape(default_cursor_shape)
