extends Area2D

# Exported variable to easily set the checkpoint ID in the editor if needed
@export var checkpoint_id: int

# Signal to notify when a checkpoint is activated
signal checkpoint_activated(checkpoint_id: int, position: Vector2)

func _ready():
	# Connect the body_entered signal to the function _on_body_entered
	self.connect("body_entered",Callable( self, "_on_body_entered"))

# Function called when a body enters the checkpoint area
func _on_body_entered(body):
	# Check if the body is the player
	if body.is_in_group("Player"):
		# Emit signal with checkpoint ID and position
		emit_signal("checkpoint_activated", checkpoint_id, global_position)
		print("Checkpoint activated at position: ", global_position)

# Optionally, you can add visual or sound effects here when checkpoint is activated
