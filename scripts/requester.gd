extends Node2D

const SHEET := preload("res://assets/art/coworker.png")

var satisfied := false
var sprite: AnimatedSprite2D
var blocker: StaticBody2D

func _ready() -> void:
	sprite = AnimatedSprite2D.new()
	sprite.frames = Sheet.frames(SHEET)
	sprite.animation = "idle_left"
	sprite.scale = Vector2(8.0, 8.0)
	add_child(sprite)
	_build_blocker()

func reset() -> void:
	satisfied = false
	position.x = 900.0
	if blocker == null or not is_instance_valid(blocker):
		_build_blocker()
	blocker.process_mode = Node.PROCESS_MODE_INHERIT
	queue_redraw()

func _build_blocker() -> void:
	blocker = StaticBody2D.new()
	blocker.collision_layer = 16
	blocker.collision_mask = 0
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(90, 560)
	shape.shape = rect
	shape.position = Vector2(0, -150)
	blocker.add_child(shape)
	add_child(blocker)

func satisfy() -> void:
	if satisfied:
		return
	satisfied = true
	if blocker and is_instance_valid(blocker):
		blocker.queue_free()
	var tween := create_tween()
	tween.tween_property(self, "position:x", position.x + 170.0, 0.45)
	queue_redraw()

func _draw() -> void:
	if satisfied:
		return
	var top := -240.0
	draw_rect(Rect2(-52, top - 78, 104, 88), Color(0.98, 0.98, 1.0, 0.94))
	draw_rect(Rect2(-52, top - 78, 104, 88), Color(0.25, 0.28, 0.34, 0.5), false, 3.0)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-12, top + 10), Vector2(12, top + 10), Vector2(0, top + 30)
	]), Color(0.98, 0.98, 1.0, 0.94))
	_draw_icon(Vector2(0, top - 34))

func _draw_icon(center: Vector2) -> void:
	match WorldState.request:
		"gloves":
			draw_circle(center + Vector2(0, -4), 16.0, Color("c0392b"))
			draw_circle(center + Vector2(15, 4), 8.0, Color("d9534f"))
			draw_rect(Rect2(center + Vector2(-16, 10), Vector2(32, 12)), Color("f2f4f7"))
		"cards":
			draw_rect(Rect2(center + Vector2(-13, -20), Vector2(26, 38)), Color("f7f9fc"))
			draw_rect(Rect2(center + Vector2(-13, -20), Vector2(26, 38)), Color("2b3038"), false, 2.0)
			draw_colored_polygon(PackedVector2Array([
				center + Vector2(0, -12), center + Vector2(8, -3),
				center + Vector2(0, 6), center + Vector2(-8, -3)
			]), Color("c0392b"))
		"doc":
			draw_rect(Rect2(center + Vector2(-15, -20), Vector2(30, 40)), Color("fbfcfe"))
			draw_rect(Rect2(center + Vector2(-15, -20), Vector2(30, 40)), Color("9aa4b3"), false, 2.0)
			for i in range(3):
				draw_rect(Rect2(center + Vector2(-9, -12 + i * 9), Vector2(18, 3)), Color("c3cbd6"))
