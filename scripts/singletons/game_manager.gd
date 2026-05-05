extends Node

signal match_started
signal player_eliminated
signal match_ended(winner: String)
signal circle_updated(radius: float, center: Vector2)

var players_alive: int = 32
var match_time: float = 0.0
var current_circle_phase: int = 0
var is_match_active: bool = false

# Match config
const TOTAL_PLAYERS = 32
const MATCH_DURATION = 600  # 10 minutes
const CIRCLE_PHASES = [
	{"duration": 120, "shrink_from": 1000, "shrink_to": 800},
	{"duration": 120, "shrink_from": 800, "shrink_to": 500},
	{"duration": 120, "shrink_from": 500, "shrink_to": 200},
]

var circle_center: Vector2 = Vector2(500, 500)
var circle_radius: float = 1000.0

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if is_match_active:
		match_time += delta
		update_circle()
		
		if match_time >= MATCH_DURATION:
			end_match()

func start_match() -> void:
	is_match_active = true
	players_alive = TOTAL_PLAYERS
	match_time = 0.0
	current_circle_phase = 0
	match_started.emit()

func eliminate_player(player_name: String) -> void:
	players_alive -= 1
	player_eliminated.emit()
	
	if players_alive <= 1:
		end_match(player_name)

func update_circle() -> void:
	if current_circle_phase >= len(CIRCLE_PHASES):
		return
	
	var phase = CIRCLE_PHASES[current_circle_phase]
	var phase_progress = fmod(match_time, phase.duration) / phase.duration
	
	if phase_progress >= 1.0:
		current_circle_phase += 1
		if current_circle_phase < len(CIRCLE_PHASES):
			update_circle()
		return
	
	circle_radius = lerp(phase.shrink_from, phase.shrink_to, phase_progress)
	circle_updated.emit(circle_radius, circle_center)

func end_match(winner: String = "Nobody") -> void:
	is_match_active = false
	match_ended.emit(winner)

func reset_match() -> void:
	match_time = 0.0
	players_alive = TOTAL_PLAYERS
	current_circle_phase = 0
	is_match_active = false
