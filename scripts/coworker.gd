extends Node2D

var shirt := Color("eef1f5")
var phase_offset := 0.0
var facing := 1.0

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var t := Time.get_ticks_msec() * 0.001 + phase_offset
	var bob := sin(t * 2.2) * 1.2

	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.6))
	draw_circle(Vector2(0, 22), 14.0, Color(0, 0, 0, 0.14))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	draw_rect(Rect2(-10, 2 + bob, 20, 13), Color("22252b"))
	draw_rect(Rect2(-13, -14 + bob, 26, 21), Color("9aa3b2"))
	draw_rect(Rect2(-11, -12 + bob, 22, 17), shirt)
	draw_rect(Rect2(-11, -1 + bob, 22, 3), Color("cfd8e4"))
	draw_rect(Rect2(-3, -12 + bob, 6, 8), Color("c3ccd9"))

	draw_circle(Vector2(0, -19 + bob), 10.4, Color("2a2622"))
	draw_circle(Vector2(facing * 3.8, -18.5 + bob), 6.4, Color("f0c9a6"))
