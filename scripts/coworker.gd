extends Node2D

const SHEET := preload("res://assets/art/coworker.png")

func _ready() -> void:
	var sprite := AnimatedSprite2D.new()
	sprite.frames = Sheet.frames(SHEET)
	sprite.animation = "sit"
	add_child(sprite)
