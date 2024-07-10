extends Area2D
@onready var animated_sprite = $AnimatedSprite2D



func _on_body_entered(body):
	Game.gain_life()
	animated_sprite.play("disappear_item")
	


func _on_animated_sprite_2d_animation_finished():
	if animated_sprite.animation == "disappear_item":
		queue_free()
