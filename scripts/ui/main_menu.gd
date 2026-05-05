extends CanvasLayer

var play_button: Button
var character_button: Button
var battle_pass_button: Button
var settings_button: Button

func _ready() -> void:
	setup_ui()
	AudioManager.play_music("menu_music")

func setup_ui() -> void:
	# Title
	var title = Label.new()
	title.text = "TOP DOWN BATTLE ROYALE"
	title.position = Vector2(540, 300)
	title.add_theme_font_size_override("font_size", 56)
	title.align = HORIZONTAL_ALIGNMENT_CENTER
	add_child(title)
	
	# Play button
	play_button = create_button("PLAY", Vector2(540, 700), 200, 80)
	play_button.pressed.connect(_on_play_pressed)
	
	# Character locker
	character_button = create_button("CHARACTERS", Vector2(540, 830), 200, 80)
	character_button.pressed.connect(_on_character_pressed)
	
	# Battle pass
	battle_pass_button = create_button("BATTLE PASS", Vector2(540, 960), 200, 80)
	battle_pass_button.pressed.connect(_on_battle_pass_pressed)
	
	# Settings
	settings_button = create_button("SETTINGS", Vector2(540, 1090), 200, 80)
	settings_button.pressed.connect(_on_settings_pressed)

func create_button(text: String, position: Vector2, width: int, height: int) -> Button:
	var button = Button.new()
	button.text = text
	button.position = position - Vector2(width / 2, height / 2)
	button.size = Vector2(width, height)
	button.add_theme_font_size_override("font_size", 24)
	add_child(button)
	return button

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_game.tscn")

func _on_character_pressed() -> void:
	# Open character selection
	print("Character locker not implemented yet")

func _on_battle_pass_pressed() -> void:
	# Open battle pass screen
	print("Battle pass not implemented yet")

func _on_settings_pressed() -> void:
	# Open settings
	print("Settings not implemented yet")
