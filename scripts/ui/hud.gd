extends CanvasLayer

# UI elements
@onready var health_bar = $VBoxContainer/HealthBar
@onready var ammo_label = $VBoxContainer/AmmoLabel
@onready var weapon_label = $VBoxContainer/WeaponLabel
@onready var minimap = $VBoxContainer/Minimap
@onready var match_time_label = $VBoxContainer/MatchTimeLabel
@onready var circle_warning = $VBoxContainer/CircleWarning

var player: Node = null

func _ready():
	set_process(true)
	if GameManager:
		GameManager.connect("circle_phase_changed", _on_circle_phase_changed)

func _process(_delta: float):
	if GameManager and GameManager.is_match_running:
		update_match_time()

func set_player(p: Node):
	"""Set reference to player"""
	player = p

func update_health(current: float, maximum: float):
	"""Update health bar display"""
	if health_bar:
		health_bar.value = (current / maximum) * 100
		# Color coding: green -> yellow -> red
		var ratio = current / maximum
		if ratio > 0.5:
			health_bar.modulate = Color.GREEN
		elif ratio > 0.25:
			health_bar.modulate = Color.YELLOW
		else:
			health_bar.modulate = Color.RED

func update_ammo(current: int, maximum: int):
	"""Update ammo display"""
	if ammo_label:
		ammo_label.text = "%d / %d" % [current, maximum]

func update_weapon_name(weapon_name: String):
	"""Update weapon display"""
	if weapon_label:
		weapon_label.text = weapon_name

func update_minimap(player_pos: Vector2, circle_pos: Vector2, circle_radius: float):
	"""Update minimap with player and circle positions"""
	if minimap:
		minimap.update_positions(player_pos, circle_pos, circle_radius)

func update_match_time():
	"""Update match timer"""
	if match_time_label and GameManager:
		var time_sec = int(GameManager.match_time)
		var minutes = time_sec / 60
		var seconds = time_sec % 60
		match_time_label.text = "%02d:%02d" % [minutes, seconds]

func _on_circle_phase_changed(phase_index: int):
	"""Show circle warning"""
	if circle_warning:
		circle_warning.show()
		AudioManager.play_sfx("circle_warning")
		
		await get_tree().create_timer(3.0).timeout
		circle_warning.hide()

func show_elimination_feed(killer_name: String, victim_name: String):
	"""Show kill feed entry"""
	var feed_item = Label.new()
	feed_item.text = "%s eliminated %s" % [killer_name, victim_name]
	feed_item.add_theme_color_override("font_color", Color.RED)
	# Add to feed container
	AudioManager.play_ui_sound("kill_notification")
