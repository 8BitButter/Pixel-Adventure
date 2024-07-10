extends Node2D

# References to child nodes
@onready var animated_sprite = $AnimatedSprite2D
@onready var fan_area = $Area2D

# Fan state enumeration
enum FanState { OFF, ON }
var fan_state: FanState = FanState.ON  # Always on

# This function is called when the script is initialized
func _ready():
	# Connect the body_entered and body_exited signals of the Area2D node
	fan_area.connect("body_entered", Callable(self, "_on_FanArea_body_entered"))
	fan_area.connect("body_exited", Callable(self, "_on_FanArea_body_exited"))
	turn_on_fan()

# Function to turn the fan on
func turn_on_fan():
	fan_state = FanState.ON
	animated_sprite.play("fan_on")

# Signal handler for when a body enters the area
func _on_FanArea_body_entered(body):
	if fan_state == FanState.ON and body.name == "Player":
		body.start_being_blown()

# Signal handler for when a body exits the area
func _on_FanArea_body_exited(body):
	if body.name == "Player":
		body.stop_being_blown()
