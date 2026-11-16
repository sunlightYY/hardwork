extends Node2D

const SHEET := preload("res://assets/art/coworker.png")

var facing_right := true

func _ready() -> void:
	var sprite := AnimatedSprite2D.new()
	sprite.frames = Sheet.frames(SHEET)
	sprite.animation = "idle_right" if facing_right else "idle_left"
	sprite.scale = Vector2(4.0, 4.0)
	add_child(sprite)
