extends Control

@onready var start_button = $MarginContainer/HBoxContainer/VBoxContainer/start
@onready var exit_button = $MarginContainer/HBoxContainer/VBoxContainer/quit
@onready var start_level = preload("res://Scenes/game.tscn")

func _ready():
	start_button.pressed.connect(_on_start_button_pressed)
	exit_button.pressed.connect(_on_exit_button_pressed)

func _on_start_button_pressed() -> void:
	var new_game_scene = start_level.instantiate()
	get_tree().root.add_child(new_game_scene)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = new_game_scene

func _on_exit_button_pressed() -> void:
	get_tree().quit()
