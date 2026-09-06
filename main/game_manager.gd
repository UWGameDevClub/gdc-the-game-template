extends Node
class_name _GameManager

enum Screen {
	Title,
	MainMenu,
	LevelSelect,
	Game,
	Credits,
	Leaderboard
}

# signal bus for screens
signal request_transition_to(screen : Screen)
signal refresh_ui(screen : Screen)
signal enter_screen(screen : Screen)
signal exit_screen(screen : Screen)

func go_to_end():
	request_transition_to.emit(Screen.MainMenu)

func go_to_level_select():
	request_transition_to.emit(Screen.LevelSelect)

var all_game_packs : Array[MicroGamePack]
var test_game_pack : MicroGamePack
