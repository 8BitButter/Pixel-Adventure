extends CharacterBody2D

# Variables for movement
@export var speed: float = 200.0
@export var jump_force: float = -300.0
@export var double_jump_force: float = -250.0
@export var wall_jump_force: Vector2 = Vector2(300, -300)  # Adjust for desired wall jump strength
@export var gravity: float = 800.0
@export var blown_away_force: Vector2 = Vector2(40, -600)  # Adjust for desired blown away strength

# References to nodes
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animated_sprite_particle: AnimatedSprite2D = $DoubleJumpAnimatedSprite2D2

# State variables
var is_wall_jumping: bool = false
var wall_jump_direction: Vector2 = Vector2.ZERO
var can_double_jump: bool = false
var has_double_jumped: bool = false  # Track if the player has performed the double jump
var being_blown: bool = false  # Track if the player is being blown by the fan
var is_hurt: bool = false  # Track if the player is hurt
var is_dead: bool = false  # Track if the player is dead

# Checkpoint functionality
var last_checkpoint_position: Vector2 = Vector2.ZERO

func _ready():
	# Try to get the 'Checkpoints' node and connect to its signals
	var checkpoints_node = get_parent().get_node_or_null("Checkpoints")
	if checkpoints_node:
		for checkpoint in checkpoints_node.get_children():
			checkpoint.connect("checkpoint_activated", Callable(self, "_on_checkpoint_activated"))
	else:
		print("Warning: 'Checkpoints' node not found in the scene tree.")

func _physics_process(delta: float) -> void:
	if is_dead:
		return  # Stop processing if the player is dead

	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle horizontal movement
	var direction: int = 0
	if Input.is_action_pressed("ui_right"):
		direction += 1
		animated_sprite.flip_h = false  # Ensure sprite faces right
	if Input.is_action_pressed("ui_left"):
		direction -= 1
		animated_sprite.flip_h = true  # Ensure sprite faces left

	# Handle wall jumping
	if is_touching_wall() and not is_on_floor() and Input.is_action_just_pressed("ui_up"):
		perform_wall_jump()

	if is_on_floor():
		is_wall_jumping = false  # Reset wall jumping state when on floor
		can_double_jump = true  # Reset double jump state when on floor
		has_double_jumped = false  # Reset double jump animation state
		velocity.x = direction * speed
	elif not is_wall_jumping:
		velocity.x = direction * speed

	# Handle jumping
	if is_on_floor() and Input.is_action_just_pressed("ui_up"):
		velocity.y = jump_force
	elif can_double_jump and Input.is_action_just_pressed("ui_up"):
		velocity.y = double_jump_force
		can_double_jump = false  # Disable double jump after using it
		has_double_jumped = true  # Indicate that double jump was used

	# Apply blowing away force if being blown by the fan
	if being_blown:
		apply_blown_away_force(delta)

	# Move the character
	move_and_slide()

	# Update animation
	update_animation()

func update_animation() -> void:
	animated_sprite_particle.play("nodust")
	if is_dead:
		animated_sprite.play("die")
	elif is_hurt:
		animated_sprite.play("hit")
	elif not is_on_floor():
		if velocity.y < 0:
			if is_wall_jumping:
				if get_wall_jump_direction() == Vector2(1, -1):  # Jump to the right
					animated_sprite.flip_h = true  # Ensure sprite faces right
				elif get_wall_jump_direction() == Vector2(-1, -1):  # Jump to the left
					animated_sprite.flip_h = false  # Ensure sprite faces left
				animated_sprite.play("wall_jump")
			elif has_double_jumped:
				animated_sprite.play("double_jump")
				animated_sprite_particle.play("dust")
			else:
				animated_sprite.play("jump")
		else:
			animated_sprite.play("fall")
	elif velocity.x != 0:
		animated_sprite.play("run")
	else:
		animated_sprite.play("idle")

func perform_wall_jump() -> void:
	is_wall_jumping = true
	wall_jump_direction = get_wall_jump_direction()
	velocity = Vector2(wall_jump_force.x * wall_jump_direction.x, wall_jump_force.y)

func get_wall_jump_direction() -> Vector2:
	if is_touching_wall_left():
		return Vector2(1, -1)  # Jump to the right
	elif is_touching_wall_right():
		return Vector2(-1, -1)  # Jump to the left
	return Vector2.ZERO

func is_touching_wall() -> bool:
	return is_touching_wall_left() or is_touching_wall_right()

func is_touching_wall_left() -> bool:
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		if collision and collision.get_normal() == Vector2.RIGHT:
			return true
	return false

func is_touching_wall_right() -> bool:
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		if collision and collision.get_normal() == Vector2.LEFT:
			return true
	return false

func get_hurt() -> void:
	if not is_hurt and not is_dead:
		is_hurt = true
		animated_sprite.play("hit")
		print("Player hurt")

		# Disable player control for a short duration
		set_physics_process(false)

		# Wait for a short duration using await
		await get_tree().create_timer(1.5).timeout

		set_physics_process(true)
		is_hurt = false
		velocity = Vector2.ZERO  # Reset velocity after the hurt effect

func start_being_blown() -> void:
	being_blown = true

func stop_being_blown() -> void:
	being_blown = false

func apply_blown_away_force(delta: float) -> void:
	# Apply continuous force to simulate wind blowing the player away
	velocity.x += blown_away_force.x * delta * 100
	if velocity.y > 0:  # Only apply vertical force if the player is falling
		velocity.y += blown_away_force.y * delta * 100

# Checkpoint functionality

# Function to handle checkpoint activation
func _on_checkpoint_activated(checkpoint_id: int, position: Vector2):
	last_checkpoint_position = position
	print("Checkpoint reached! New respawn position: ", last_checkpoint_position)

# Function to respawn the player at the last checkpoint
func respawn():
	if last_checkpoint_position != Vector2.ZERO:  # Ensure there's a valid checkpoint
		global_position = last_checkpoint_position
		print("Player respawned at: ", global_position)
	else:
		print("No checkpoint set. Unable to respawn.")

# Example function to handle player death or respawn logic
func die():
	print("Player died. Respawning...")
	respawn()
