extends CharacterBody2D

signal interact_requested(kind: String)

const SHEET := preload("res://assets/art/player.png")
const SPEED := 170.0
const INTERACT_RADIUS := 96.0

var dir := Vector2.ZERO
var facing_name := "down"
var crouching := false
var frozen := false
var sitting := true
var anim_time := 0.0
var near := ""
var work_point := Vector2.ZERO
var sink_point := Vector2.ZERO
var sprite: AnimatedSprite2D

func _ready() -> void:
	add_to_group("player")
	collision_layer = 2
	collision_mask = 1
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(24, 24)
	shape.shape = rect
	add_child(shape)
	_build_sprite()

func _physics_process(delta: float) -> void:
	anim_time += delta
	if frozen:
		velocity = Vector2.ZERO
		move_and_slide()
		_update_anim()
		return

	var input := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down"))
	if sitting:
		velocity = Vector2.ZERO
		move_and_slide()
		if _any_direction_just_pressed():
			sitting = false
			facing_name = _dir_from(input) if input != Vector2.ZERO else "down"
		_update_anim()
		queue_redraw()
		return

	if input != Vector2.ZERO:
		dir = input.normalized()
		facing_name = _dir_from(dir)

	crouching = Input.is_action_pressed("crouch")
	velocity = dir * (0.0 if crouching else SPEED)
	move_and_slide()

	if Input.is_action_just_pressed("toggle_phase"):
		WorldState.toggle_phase()

	_update_near()
	if near != "" and Input.is_action_just_pressed("interact"):
		interact_requested.emit(near)

	_update_anim()
	queue_redraw()

func is_moving() -> bool:
	return not crouching and velocity.length() > 10.0

func _dir_from(vector: Vector2) -> String:
	if absf(vector.x) > absf(vector.y):
		return "right" if vector.x > 0.0 else "left"
	return "up" if vector.y < 0.0 else "down"

func _any_direction_just_pressed() -> bool:
	return (Input.is_action_just_pressed("move_left")
		or Input.is_action_just_pressed("move_right")
		or Input.is_action_just_pressed("move_up")
		or Input.is_action_just_pressed("move_down"))

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

func _update_anim() -> void:
	if sprite == null:
		return
	var target := "sit"
	if not sitting:
		target = ("walk_" if is_moving() else "idle_") + facing_name
	if sprite.animation != target:
		sprite.play(target)
	sprite.scale = Vector2(1.0, 0.8) if crouching and not sitting else Vector2.ONE

func _build_sprite() -> void:
	sprite = AnimatedSprite2D.new()
	sprite.frames = Sheet.frames(SHEET)
	sprite.animation = "sit"
	add_child(sprite)

func _draw() -> void:
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.55))
	draw_circle(Vector2(0, 20), 15.0, Color(0, 0, 0, 0.16))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	draw_arc(Vector2(0, 19), 23.0, 0.0, TAU, 28, Color(0.40, 0.70, 1.0, 0.35), 2.0)
