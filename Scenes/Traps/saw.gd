extends AnimatableBody2D

# References to child nodes
@onready var collision_shape = $CollisionShape2D
@onready var animated_sprite = $AnimatedSprite2D
@onready var saw_area = $Area2D

# This function is called when the script is initialized
func _ready():
	# Connect the body_entered signal of the Area2D node
	saw_area.connect("body_entered", Callable(self, "_on_SawArea_body_entered"))

# Signal handler for when a body enters the area
func _on_SawArea_body_entered(body):
	if body.name == "Player":  # Adjust based on your player's node name
		body.get_hurt()
		Game.handle_player_death()
