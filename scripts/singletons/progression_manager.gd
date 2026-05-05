extends Node

signal level_up(new_level: int)
signal battle_pass_updated

var player_data: Dictionary = {
	"username": "Player",
	"level": 1,
	"experience": 0,
	"battle_pass_tier": 0,
	"battle_pass_progress": 0,
	"wins": 0,
	"kills": 0,
	"playtime": 0,
	"cosmetics_owned": [],
	"current_skin": "default"
}

const EXPERIENCE_PER_LEVEL = 1000
const BATTLE_PASS_TIERS = 100
const TIER_PROGRESS_MAX = 100

func _ready() -> void:
	load_player_data()

func add_experience(amount: int) -> void:
	player_data.experience += amount
	
	while player_data.experience >= EXPERIENCE_PER_LEVEL:
		player_data.experience -= EXPERIENCE_PER_LEVEL
		player_data.level += 1
		level_up.emit(player_data.level)
	
	update_battle_pass()

func add_kill() -> void:
	player_data.kills += 1
	add_experience(50)

func add_win() -> void:
	player_data.wins += 1
	add_experience(500)

func add_playtime(seconds: float) -> void:
	player_data.playtime += seconds
	add_experience(int(seconds / 60))

func update_battle_pass() -> void:
	player_data.battle_pass_progress += 1
	
	if player_data.battle_pass_progress >= TIER_PROGRESS_MAX:
		player_data.battle_pass_progress = 0
		player_data.battle_pass_tier = min(player_data.battle_pass_tier + 1, BATTLE_PASS_TIERS)
	
	battle_pass_updated.emit()
	save_player_data()

func load_player_data() -> void:
	var save_path = "user://player_data.json"
	if ResourceLoader.exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		if file:
			var json = JSON.new()
			player_data = json.parse(file.get_as_text())

func save_player_data() -> void:
	var save_path = "user://player_data.json"
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(player_data)
		file.store_string(json_string)

func set_current_skin(skin_name: String) -> void:
	if skin_name in player_data.cosmetics_owned:
		player_data.current_skin = skin_name
		save_player_data()

func get_player_data() -> Dictionary:
	return player_data
