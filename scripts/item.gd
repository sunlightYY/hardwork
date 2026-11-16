extends Node2D

const TYPES := ["gloves", "cards", "doc"]

var kind := "gloves"
var rest_y := 580.0
var vy := 0.0
var falling := true

func setup(type: String, x: float, target_y: float) -> void:
	kind = type
	position = Vector2(x, target_y - 760.0)
	rest_y = target_y
	vy = 0.0
	falling = true
	scale = Vector2(1.8, 1.8)

func _ready() -> void:
	add_to_group("item")

func _physics_process(delta: float) -> void:
	if not falling:
		return
	vy += 2400.0 * delta
	position.y += vy * delta
	if position.y >= rest_y:
		position.y = rest_y
		if vy > 300.0:
			vy = -vy * 0.3
		else:
			falling = false
			queue_redraw()

func _draw() -> void:
	draw_set_transform(Vector2(0, 26), 0.0, Vector2(1.0, 0.28))
	draw_circle(Vector2.ZERO, 22.0, Color(0, 0, 0, 0.22))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	match kind:
		"gloves":
			draw_rect(Rect2(-22, -28, 44, 38), Color("c0392b"))
			draw_rect(Rect2(-22, -28, 18, 14), Color("d9534f"))
			draw_rect(Rect2(6, -22, 16, 12), Color("d9534f"))
			draw_rect(Rect2(-22, 10, 44, 12), Color("f2f4f7"))
			draw_rect(Rect2(-26, -4, 8, 16), Color("c0392b"))
		"cards":
			draw_rect(Rect2(-18, -30, 36, 48), Color("f7f9fc"))
			draw_rect(Rect2(-18, -30, 36, 48), Color("2b3038"), false, 2.0)
			draw_colored_polygon(PackedVector2Array([
				Vector2(0, -18), Vector2(11, -6), Vector2(0, 8), Vector2(-11, -6)
			]), Color("c0392b"))
		"doc":
			draw_rect(Rect2(-20, -32, 40, 52), Color("fbfcfe"))
			draw_rect(Rect2(-20, -32, 40, 52), Color("9aa4b3"), false, 2.0)
			for i in range(4):
				draw_rect(Rect2(-13, -22 + i * 10, 26, 3), Color("c3cbd6"))
			draw_rect(Rect2(-13, 14, 16, 3), Color("c0392b"))
