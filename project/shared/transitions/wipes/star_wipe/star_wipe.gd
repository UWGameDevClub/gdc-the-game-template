extends Control

@onready var sprite = $AnimatedSprite2D

func wipe(texture : Texture2D, callback : Callable = Callable()):
	sprite.visible = true
	(sprite.material as ShaderMaterial).set_shader_parameter("current_screen_texture", texture)
	
	if not callback.is_null():
		callback.call()
	
	sprite.play("wipe")
	await sprite.animation_finished
	sprite.visible = false
	
