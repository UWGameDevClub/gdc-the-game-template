extends Resource
class_name AudioService

var _music_player : AudioStreamPlayer

func _init(node: AudioStreamPlayer):
	_music_player = node

var paused : bool:
	set(value):
		if paused:
			resume_music()
		else:
			pause_music()

	get(): return not _music_player or \
		not _music_player.playing or \
		_music_player.stream_paused 


func pause_music():
	if not _music_player:
		return 
		
	if not _music_player.stream_paused:
		_music_player.stream_paused = true

func resume_music():
	if not _music_player:
		return
	
	if _music_player.stream_paused:
		_music_player.stream_paused = false
	
	if not _music_player.playing:
		_music_player.play()
