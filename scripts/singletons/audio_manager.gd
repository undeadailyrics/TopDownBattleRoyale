extends Node

var audio_players: Dictionary = {}

func _ready() -> void:
	# Create audio player nodes for different categories
	for category in ["sfx", "music", "ui"]:
		var player = AudioStreamPlayer.new()
		player.name = category
		add_child(player)
		audio_players[category] = player

func play_sound(sound_name: String, category: String = "sfx", pitch_variation: float = 0.0) -> void:
	var audio_path = "res://assets/audio/%s/%s.ogg" % [category, sound_name]
	
	if ResourceLoader.exists(audio_path):
		var player = audio_players.get(category, audio_players["sfx"])
		var audio_stream = load(audio_path)
		
		player.stream = audio_stream
		
		if pitch_variation > 0:
			player.pitch_scale = randf_range(1.0 - pitch_variation, 1.0 + pitch_variation)
		
		player.play()
	else:
		push_warning("Sound not found: %s" % audio_path)

func play_music(track_name: String) -> void:
	play_sound(track_name, "music")

func stop_music() -> void:
	audio_players["music"].stop()

func set_volume(category: String, volume_db: float) -> void:
	if category in audio_players:
		audio_players[category].volume_db = volume_db
