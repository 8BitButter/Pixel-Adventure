extends Node2D


# Enumeration for flame states
enum FlameState { OFF, ON }

# Flame state variable
var flame_state = FlameState.OFF

# References to child nodes
@onready var animated_sprite = $AnimatedSprite2D
@onready var flame_area = $Area2D

# This function is called when the script is initialized
func _ready():
	# Connect the body_entered and body_exited signals of the Area2D node
	flame_area.connect("body_entered",Callable( self, "_on_FlameArea_body_entered"))
	flame_area.connect("body_exited",Callable( self, "_on_FlameArea_body_exited"))
	start_fire_cycle()

# Function to start the fire animation cycle
func start_fire_cycle() -> void:
	while true:
		await handle_fire_state(true)
		await wait_random_duration()
		await handle_fire_state(false)
		await wait_random_duration()

# Function to handle the fire state (on/off)
func handle_fire_state(on: bool) -> void:
	var duration = randi_range(2, 5)
	if on:
		#print("Fire is ON for %s seconds." % duration)
		turn_on_flame()
	else:
		#print("Fire is OFF for %s seconds." % duration)
		turn_off_flame()
	await wait_timer(duration)

# Function to turn the flame on
func turn_on_flame():
	flame_state = FlameState.ON
	animated_sprite.play("fire_on")  # Assuming you have a "fire_on" animation
	check_player_in_area()

# Function to turn the flame off
func turn_off_flame():
	flame_state = FlameState.OFF
	animated_sprite.play("fire_off")  # Assuming you have a "fire_off" animation

# Function to check if the player is in the area when the flame is on
func check_player_in_area():
	if flame_state == FlameState.ON:
		for body in flame_area.get_overlapping_bodies():
			if body.name == "Player":  # Adjust based on your player's node name
				player_hurt(body, true)

# Signal handler for when a body enters the area
func _on_FlameArea_body_entered(body):
	if flame_state == FlameState.ON and body.name == "Player":
		player_hurt(body, true)

# Signal handler for when a body exits the area
func _on_FlameArea_body_exited(body):
	print("Body exited:", body.name)

# Function to wait for a specific duration
func wait_timer(duration: float) -> void:
	await get_tree().create_timer(duration).timeout

# Function to wait for a random duration
func wait_random_duration() -> void:
	await wait_timer(randi_range(2, 5))

# Helper function to generate a random integer within a range
func randi_range(min: int, max: int) -> int:
	return randi() % (max - min + 1) + min

# Function to handle player hurt logic
func player_hurt(player: CharacterBody2D, hurt: bool) -> void:
	if hurt:
		# Ensure player has an AnimatedSprite2D node
		var animated_sprite = player.get_node("AnimatedSprite2D")
		if animated_sprite:
			animated_sprite.play("hit")
		else:
			print("AnimatedSprite2D not found on player")

		# Calculate the impulse vector in the opposite direction
		var direction = (player.global_position - global_position).normalized()
		var impulse_vector = direction * 500  # Adjust the impulse strength as needed

		# Temporarily disable user control
		player.set_physics_process(false)

		# Apply the impulse to the player's velocity
		player.velocity = impulse_vector
		#print("Player hurt, applying impulse:", impulse_vector)

		# Wait for a short duration
		await get_tree().create_timer(0.5).timeout

		# Re-enable user control
		player.set_physics_process(true)
		player.velocity = Vector2.ZERO  # Reset velocity after the impulse effect
		
