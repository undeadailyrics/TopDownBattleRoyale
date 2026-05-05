extends Area2D

var direction: Vector2 = Vector2.RIGHT
var weapon_type: String = "assault_rifle"
var owner_player: Node2D
var speed: float = 400.0
var damage: int = 15
var lifetime: float = 10.0
var spread_angle: float = 0.0

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	
	# Set up sprite
	var sprite = Sprite2D.new()
	sprite.texture = load("res://assets/sprites/projectiles/%s.png" % weapon_type)
	add_child(sprite)
	
	# Set up collision
	var collision_shape = CollisionShape2D.new()
	collision_shape.shape = CircleShape2D.new()
	collision_shape.shape.radius = 4
	add_child(collision_shape)
	
	# Apply spread
	spread_angle = randf_range(-5, 5)
	direction = direction.rotated(deg_to_rad(spread_angle))
	
	# Start lifetime timer
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_area_entered(area: Area2D) -> void:
	# Don't hit owner
	if area.is_in_group("player") and area.owner == owner_player:
		return
	
	if area.is_in_group("player"):
		# Hit enemy player
		area.owner.take_damage(damage, owner_player)
		create_impact()
		queue_free()
	elif area.is_in_group("obstacle"):
		# Hit environment
		create_impact()
		queue_free()

func create_impact() -> void:
	var impact_particle = Node2D.new()
	impact_particle.position = position
	get_parent().add_child(impact_particle)
	
	# Simple particle effect
	for _i in range(8):
		var particle = Sprite2D.new()
		particle.texture = load("res://assets/sprites/particles/spark.png")
		particle.position = impact_particle.position + Vector2(randf_range(-10, 10), randf_range(-10, 10))
		get_parent().add_child(particle)
		
		var tween = create_tween()
		tween.tween_property(particle, "position", particle.position + Vector2(randf_range(-50, 50), randf_range(-50, 50)), 0.3)
		tween.parallel().tween_property(particle, "modulate:a", 0.0, 0.3)
		tween.tween_callback(particle.queue_free)
	
	AudioManager.play_sound("impact", "sfx", 0.2)
