# Projectile Script - Handles projectile movement and collision

extends Area2D

var velocity: Vector2 = Vector2.ZERO
var owner_player: Node = null
var damage: float = 15.0
var weapon_type: String = "assault_rifle"
var lifetime: float = 10.0
var hit_enemies: Array[Node] = []

@onready var sprite = $Sprite2D
@onready var collision_shape = $CollisionShape2D

func _ready():
	area_entered.connect(_on_area_entered)
	set_process(true)
	
	# Auto-destroy after lifetime
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _process(delta: float):
	global_position += velocity * delta
	rotation = velocity.angle()
	
	# Destroy if off-map
	if global_position.x < -100 or global_position.x > Constants.MAP_WIDTH + 100 or \
	   global_position.y < -100 or global_position.y > Constants.MAP_HEIGHT + 100:
		queue_free()

func _on_area_entered(area: Area2D):
	"""Handle collision with enemies or objects"""
	if area == owner_player:
		return  # Don't hit owner
	
	if area in hit_enemies:
		return  # Don't hit same target twice
	
	# Check if it's a player
	if area.is_in_group("player"):
		if area != owner_player:
			hit_enemies.append(area)
			area.take_damage(damage)
			_create_hit_effect(area.global_position)
			
			# Don't destroy on hit (allow piercing for some weapons)
			if weapon_type in ["sniper", "rpg"]:
				queue_free()
	
	# Check if it's a world object
	if area.is_in_group("obstacle"):
		_create_hit_effect(global_position)
		queue_free()

func _create_hit_effect(position: Vector2):
	"""Create visual/audio feedback for hit"""
	var particles = preload("res://scenes/effects/impact_particles.tscn").instantiate()
	particles.global_position = position
	get_parent().add_child(particles)
	
	AudioManager.play_sfx("projectile_hit")
	
	# RPG creates explosion
	if weapon_type == "rpg":
		_create_explosion(position)

func _create_explosion(center: Vector2):
	"""Create area damage for explosives"""
	var explosion_radius = 150.0
	var explosion_damage = damage * 0.5
	
	# Find all players in radius
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = CircleShape2D.new()
	query.shape.radius = explosion_radius
	query.transform.origin = center
	
	var results = space_state.intersect_shape(query)
	for result in results:
		if result.collider.is_in_group("player") and result.collider != owner_player:
			result.collider.take_damage(explosion_damage)
	
	# Visual explosion
	var explosion = preload("res://scenes/effects/explosion.tscn").instantiate()
	explosion.global_position = center
	get_parent().add_child(explosion)
