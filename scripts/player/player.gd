extends CharacterBody2D

signal health_changed(new_health: int)
signal weapon_changed(new_weapon: String)
signal died

# Movement
const BASE_SPEED = 400.0
var current_speed: float = BASE_SPEED
var input_vector: Vector2 = Vector2.ZERO

# Health & Status
var max_health: int = 100
var current_health: int = 100
var is_dead: bool = false

# Weapons
var current_weapon: String = "assault_rifle"
var weapon_data: Dictionary = {}
var ammo: Dictionary = {
	"assault_rifle": 120,
	"shotgun": 24,
	"sniper": 8,
	"rpg": 4
}

# Aim & Combat
var aim_vector: Vector2 = Vector2.RIGHT
var is_aiming: bool = false
var damage_cooldown: float = 0.0

# Cosmetics
var player_name: String = "Player"
var skin: String = "default"

var sprite: Sprite2D
var collision_shape: CollisionShape2D
var weapon_node: Node2D

func _ready() -> void:
	# Setup visual components
	sprite = Sprite2D.new()
	sprite.texture = load("res://assets/sprites/player/default.png")
	add_child(sprite)
	
	collision_shape = CollisionShape2D.new()
	collision_shape.shape = CircleShape2D.new()
	collision_shape.shape.radius = 16
	add_child(collision_shape)
	
	weapon_node = Node2D.new()
	add_child(weapon_node)
	
	current_health = max_health
	load_weapon_data()
	GameManager.player_eliminated.connect(_on_player_eliminated)

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	handle_input()
	update_movement(delta)
	handle_aiming()
	handle_damage_cooldown(delta)
	move_and_slide()

func handle_input() -> void:
	input_vector = Vector2.ZERO
	
	# Keyboard input for testing
	if Input.is_action_pressed("move_up"):
		input_vector.y -= 1
	if Input.is_action_pressed("move_down"):
		input_vector.y += 1
	if Input.is_action_pressed("move_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("move_right"):
		input_vector.x += 1
	
	# Joystick input for mobile
	var joy_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if joy_input.length() > 0.1:
		input_vector = joy_input
	
	input_vector = input_vector.normalized()
	
	# Aiming joystick (right stick on gamepad)
	var aim_input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if aim_input.length() > 0.1:
		aim_vector = aim_input.normalized()

func update_movement(delta: float) -> void:
	velocity = input_vector * current_speed
	
	# Clamp to map bounds
	var clamped_pos = position + velocity * delta
	clamped_pos.x = clamp(clamped_pos.x, 0, 2000)
	clamped_pos.y = clamp(clamped_pos.y, 0, 2000)
	position = clamped_pos

func handle_aiming() -> void:
	if aim_vector.length() > 0.1:
		is_aiming = true
		if Input.is_action_pressed("fire"):
			fire_weapon()
	else:
		is_aiming = false

func fire_weapon() -> void:
	if ammo[current_weapon] <= 0:
		return
	
	ammo[current_weapon] -= 1
	
	# Create projectile
	var projectile_scene = load("res://scenes/projectile.tscn")
	var projectile = projectile_scene.instantiate()
	get_parent().add_child(projectile)
	projectile.position = global_position + aim_vector * 20
	projectile.direction = aim_vector
	projectile.weapon_type = current_weapon
	projectile.owner_player = self
	
	AudioManager.play_sound("fire_%s" % current_weapon, "sfx", 0.1)

func take_damage(amount: int, attacker = null) -> void:
	current_health -= amount
	health_changed.emit(current_health)
	
	# Visual feedback
	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE
	
	AudioManager.play_sound("hit", "sfx")
	
	if current_health <= 0:
		die(attacker)

func die(killer = null) -> void:
	is_dead = true
	died.emit()
	
	AudioManager.play_sound("explosion", "sfx")
	GameManager.eliminate_player(player_name)
	
	# Create loot explosion
	spawn_loot()
	
	# Fade out and remove
	var tween = create_tween()
	tween.tween_property(modulate, "a", 0.0, 0.3)
	await tween.finished
	queue_free()

func spawn_loot() -> void:
	var loot_types = ["ammo_box", "health_crate", "weapon_drop"]
	for _i in range(randi() % 3 + 1):
		var loot_type = loot_types[randi() % loot_types.size()]
		var loot = create_loot(loot_type)
		get_parent().add_child(loot)
		loot.position = position + Vector2(randf_range(-30, 30), randf_range(-30, 30))

func create_loot(loot_type: String) -> Node2D:
	var loot = Node2D.new()
	var sprite = Sprite2D.new()
	sprite.texture = load("res://assets/sprites/loot/%s.png" % loot_type)
	loot.add_child(sprite)
	
	var area = Area2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 16
	var collision = CollisionShape2D.new()
	collision.shape = shape
	area.add_child(collision)
	loot.add_child(area)
	
	loot.set_meta("loot_type", loot_type)
	return loot

func pickup_weapon(weapon_name: String) -> void:
	if weapon_name in ammo:
		var old_weapon = current_weapon
		current_weapon = weapon_name
		ammo[weapon_name] = weapon_data[weapon_name]["max_ammo"]
		weapon_changed.emit(current_weapon)
		AudioManager.play_sound("pickup", "sfx")

func pickup_health(amount: int) -> void:
	current_health = min(current_health + amount, max_health)
	health_changed.emit(current_health)
	AudioManager.play_sound("pickup", "sfx")

func handle_damage_cooldown(delta: float) -> void:
	if damage_cooldown > 0:
		damage_cooldown -= delta

func load_weapon_data() -> void:
	weapon_data = {
		"assault_rifle": {
			"damage": 15,
			"fire_rate": 0.1,
			"spread": 10,
			"max_ammo": 120
		},
		"shotgun": {
			"damage": 40,
			"fire_rate": 0.8,
			"spread": 30,
			"max_ammo": 24
		},
		"sniper": {
			"damage": 80,
			"fire_rate": 1.5,
			"spread": 2,
			"max_ammo": 8
		},
		"rpg": {
			"damage": 100,
			"fire_rate": 2.0,
			"spread": 5,
			"max_ammo": 4
		}
	}

func _on_player_eliminated() -> void:
	pass
