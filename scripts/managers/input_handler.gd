# Input Handler - Manages touch and gamepad input for mobile

extends Node

# Virtual joystick state
var left_joystick_position: Vector2 = Vector2.ZERO
var right_joystick_position: Vector2 = Vector2.ZERO
var joystick_radius: float = 100.0
var fire_button_pressed: bool = false

func _ready():
	set_process_input(true)

func _input(event: InputEvent):
	"""Handle touch input"""
	if event is InputEventScreenTouch:
		var touch_pos = event.position
		
		# Left side = movement
		if touch_pos.x < get_viewport().get_visible_rect().size.x / 2:
			if event.pressed:
				left_joystick_position = touch_pos
		else:
			# Right side = aiming/firing
			if event.pressed:
				right_joystick_position = touch_pos
				fire_button_pressed = true
			else:
				fire_button_pressed = false
	
	elif event is InputEventScreenDrag:
		var touch_pos = event.position
		
		# Determine which joystick based on position
		if touch_pos.x < get_viewport().get_visible_rect().size.x / 2:
			left_joystick_position = touch_pos
		else:
			right_joystick_position = touch_pos

func get_movement_input() -> Vector2:
	"""Get normalized movement vector from left joystick"""
	if left_joystick_position == Vector2.ZERO:
		return Vector2.ZERO
	
	var center = Vector2(get_viewport().get_visible_rect().size.x / 4, get_viewport().get_visible_rect().size.y / 2)
	var direction = (left_joystick_position - center).normalized()
	return direction

func get_aim_direction() -> Vector2:
	"""Get normalized aiming direction from right joystick"""
	if right_joystick_position == Vector2.ZERO:
		return Vector2(1, 0)  # Default to right
	
	var center = Vector2(get_viewport().get_visible_rect().size.x * 0.75, get_viewport().get_visible_rect().size.y / 2)
	var direction = (right_joystick_position - center).normalized()
	return direction if direction != Vector2.ZERO else Vector2(1, 0)

func is_firing() -> bool:
	"""Check if fire button is pressed"""
	return fire_button_pressed

func reset_inputs():
	"""Reset all input states"""
	left_joystick_position = Vector2.ZERO
	right_joystick_position = Vector2.ZERO
	fire_button_pressed = false
