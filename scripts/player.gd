extends CharacterBody2D

signal interact_requested(kind: String)

const SPEED := 170.0
const INTERACT_RADIUS := 96.0

var dir := Vector2.ZERO
var facing := 1.0
var crouching := false
var frozen := false
var anim_time := 0.0
var near := ""
var work_point := Vector2.ZERO
var sink_point := Vector2.ZERO

func _ready() -> void:
	add_to_group("player")
	collision_layer = 2
	collision_mask = 1
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(24, 24)
	shape.shape = rect
	add_child(shape)

func _physics_process(delta: float) -> void:
	anim_time += delta
	if frozen:
		velocity = Vector2.ZERO
		move_and_slide()
		queue_redraw()
		return

	var input := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down"))
	if input != Vector2.ZERO:
		dir = input.normalized()
		if absf(dir.x) > 0.1:
			facing = signf(dir.x)

	crouching = Input.is_action_pressed("crouch")
	velocity = dir * (0.0 if crouching else SPEED)
	move_and_slide()

	if Input.is_action_just_pressed("toggle_phase"):
		WorldState.toggle_phase()

	_update_near()
	if near != "" and Input.is_action_just_pressed("interact"):
		interact_requested.emit(near)

	queue_redraw()

func is_moving() -> bool:
	return not crouching and velocity.length() > 10.0

func _update_near() -> void:
	near = ""
	var best := INTERACT_RADIUS
	if not WorldState.is_night:
		var d := global_position.distance_to(work_point)
		if d < best:
			best = d
			near = "work"
	var d2 := global_position.distance_to(sink_point)
	if d2 < best:
		near = "sink"

func _draw() -> void:
	var squash := 0.8 if crouching else 1.0
	var bob := 0.0
	if is_moving():
		bob = sin(anim_time * 14.0) * 1.6

	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.6))
	draw_circle(Vector2(0, 24), 15.0, Color(0, 0, 0, 0.16))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	draw_arc(Vector2(0, 18), 22.0, 0.0, TAU, 28, Color(0.40, 0.70, 1.0, 0.35), 2.0)

	draw_rect(Rect2(-11, 2 * squash + bob, 22, 14 * squash), Color("22252b"))
	draw_rect(Rect2(-14, -15 * squash + bob, 28, 22 * squash), Color("2b3038"))
	draw_rect(Rect2(-12, -13 * squash + bob, 24, 18 * squash), Color("ffffff"))
	draw_rect(Rect2(-12, -1 * squash + bob, 24, 3), Color("dbe3ee"))
	draw_rect(Rect2(-3, -13 * squash + bob, 6, 9), Color("cfd6e0"))

	var head_y := -20.0 * squash + bob
	draw_circle(Vector2(0, head_y), 11.0, Color("1b1d22"))
	draw_circle(Vector2(facing * 4.0, head_y - 0.5), 6.8, Color("f0c9a6"))
