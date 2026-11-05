extends VBoxContainer

@export var default_credit_display: PackedScene 

func _ready() -> void:
	GameManager.refresh_ui.connect(on_credit_screen_load)

func on_credit_screen_load(screen):
	if screen != GameManager.Screen.Credits:
		return
		
	# todo: caching
	for c in get_children():
		remove_child(c)
		c.queue_free()
	
	#for mg in all_games:
		#var element_scene = mg.custom_credit_display
#
		#if element_scene == null:
			#element_scene = default_credit_display
#
		#var element = default_credit_display.instantiate() as MicroGameCreditDisplay
#
		#if element == null:
			#push_error("Credits failed to load credit display for ", mg)
		#
		#element.init(mg)
#
		#credits_list.add_child(element)
