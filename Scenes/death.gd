extends Node2D

# Variables for player's health
@export var max_health: int = 100
var current_health: int = max_health

# Signal for when the player dies
signal player_died

# Function to take damage
func take_damage(amount: int) -> void:
	current_health -= amount
	if current_health <= 0:
		die()
	else:
		print("Player health: %d" % current_health)

# Function to heal the player
func heal(amount: int) -> void:
	current_health += amount
	if current_health > max_health:
		current_health = max_health
	print("Player health: %d" % current_health)

# Function to handle player death
func die() -> void:
	emit_signal("player_died")
	print("Player is dead")
	get_tree().change_scene("res://GameOver.tscn")  # Replace with the path to your Game Over scene
