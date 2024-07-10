extends Control

@onready var retry_button = $MarginContainer/HBoxContainer/VBoxContainer/retry
@onready var quit_button = $MarginContainer/HBoxContainer/VBoxContainer/quit
@onready var retry_checkpoint_button = $MarginContainer/HBoxContainer/VBoxContainer/retry_checkpoint
@onready var start_level = preload("res://Scenes/game.tscn")

func _ready():
	retry_button.pressed.connect(_on_retry_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)
	retry_checkpoint_button.pressed.connect(_on_retry_checkpoint_button_pressed)

func _on_retry_button_pressed() -> void:
	var new_game_scene = start_level.instantiate()
	get_tree().root.add_child(new_game_scene)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = new_game_scene

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_retry_checkpoint_button_pressed() -> void:
	# Assuming there is a global script or singleton managing the player's state
	var player = get_tree().root.get_node("GameRoot/Player")
	if player and player.has_method("respawn"):
		player.respawn()
