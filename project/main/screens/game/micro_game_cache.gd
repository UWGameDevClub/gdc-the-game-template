extends Resource
class_name MicroGameCache

@export var force_reload : bool = true 
@export var do_validation : bool = true

var cached_games : Dictionary[MicroGameInfo, MicroGame]

func clear():
	for game in cached_games.values():
		game.queue_free()
		
	cached_games.clear()


func _is_valid(game : Node):
	return game is MicroGame


func _load_and_validate(info: MicroGameInfo):
	if info == null or \
		info.game_scene == null or \
		not info.game_scene.can_instantiate():
		return null
		
	var game = info.game_scene.instantiate()
	
	if not do_validation:
		return game
		
	if _is_valid(game):	
		return game

	else:
		game.queue_free()
		return null


func _load_cached(info: MicroGameInfo):
	if cached_games.has(info):
		return cached_games.get(info)
	
	var game = _load_and_validate(info)
	cached_games.set(info, game)
	return game


func load_game(info: MicroGameInfo) -> MicroGame:
	if force_reload:
		return _load_and_validate(info)
	
	return _load_cached(info)
