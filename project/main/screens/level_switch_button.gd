extends BaseButton

@export var next_screen : GameManager.Screen

func _ready():
	pressed.connect(GameManager.request_transition_to.emit.bind(next_screen))
	
