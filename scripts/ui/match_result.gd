extends Control

# Results display
@onready var placement_label = $VBoxContainer/PlacementLabel
@onready var xp_earned_label = $VBoxContainer/XPEarnedLabel
@onready var stats_container = $VBoxContainer/StatsContainer
@onready var play_again_button = $VBoxContainer/PlayAgainButton
@onready var menu_button = $VBoxContainer/MenuButton

var match_result: Dictionary = {}

func _ready():
	play_again_button.pressed.connect(_on_play_again_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	
	# Get results from GameManager
	if GameManager:
		display_results()

func display_results():
	"""Show match results"""
	# This would be populated by GameManager.end_match() signal
	var placement = 1  # Example
	var xp_earned = 500
	var eliminations = 3
	
	placement_label.text = "Placement: #%d" % placement
	xp_earned_label.text = "+%d XP" % xp_earned
	
	var stats_text = """
	Eliminations: %d
	Damage Dealt: 250
	Distance Traveled: 1,500 m
	Time Survived: 8:45
	""" % eliminations
	
	stats_container.text = stats_text
	
	AudioManager.play_sfx("match_end")

func _on_play_again_pressed():
	"""Start another match"""
	AudioManager.play_ui_sound("button_click")
	get_tree().reload_current_scene()

func _on_menu_pressed():
	"""Return to main menu"""
	AudioManager.play_ui_sound("button_click")
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
