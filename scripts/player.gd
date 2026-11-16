extends CharacterBody2D

signal interact_requested(kind: String)

const SHEET := preload("res://assets/art/player.png")
const SPEED := 230.0
const INTERACT_RADIUS := 150.0

var dir := Vector2.RIGHT
var facing_name := "right"
var crouching := false
var frozen := false
var sitting := true
var anim_time := 0.0
var near := ""
var work_point := Vector2.ZERO
var sink_point := Vector2.ZERO
var min_x := 0.0
var max_x := 10000.0
var sprite: AnimatedSprite2D

func _ready() -> void:
	add_to_group("player")
	collision_layer = 2
	collision_mask = 1
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(26, 40)
	shape.shape = rect
	shape.position = Vector2(0, 8)
	add_child(shape)
	_build_sprite()

func _physics_process(delta: float) -> void:
	anim_time += delta
	if frozen:
		velocity = Vector2.ZERO
		move_and_slide()
		_update_anim()
		return

	var axis := Input.get_axis("move_left", "move_right")
	if sitting:
		velocity = Vector2.ZERO
		move_and_slide()
		if axis != 0.0:
			sitting = false
			dir.x = signf(axis)
			facing_name = "right" if axis > 0.0 else "left"
		_update_anim()
		queue_redraw()
		return

	if axis != 0.0:
		dir.x = signf(axis)
		facing_name = "right" if axis > 0.0 else "left"

	crouching = Input.is_action_pressed("crouch")
	velocity = Vector2(dir.x * (0.0 if crouching else SPEED), 0.0)
	move_and_slide()
	global_position.x = clampf(global_position.x, min_x, max_x)

	if Input.is_action_just_pressed("toggle_phase"):
		WorldState.toggle_phase()

	_update_near()
	if near != "" and Input.is_action_just_pressed("interact"):
		interact_requested.emit(near)

	_update_anim()
	queue_redraw()

func is_moving() -> bool:
	return not crouching and velocity.length() > 10.0

func _update_near() -> void:
	near = ""
	var best := INTERACT_RADIUS
	if not WorldState.is_night:
		var d := absf(global_position.x - work_point.x)
		if d < best:
			best = d
			near = "work"
	var d2 := absf(global_position.x - sink_point.x)
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
	sprite.scale = Vector2(4.0, 3.2) if crouching and not sitting else Vector2(4.0, 4.0)

func _build_sprite() -> void:
	sprite = AnimatedSprite2D.new()
	sprite.frames = Sheet.frames(SHEET)
	sprite.animation = "sit"
	add_child(sprite)

func _draw() -> void:
	draw_set_transform(Vector2(0, 78), 0.0, Vector2(1.0, 0.32))
	draw_circle(Vector2.ZERO, 42.0, Color(0, 0, 0, 0.20))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	draw_arc(Vector2(0, 78), 46.0, 0.0, TAU, 32, Color(0.40, 0.70, 1.0, 0.28), 2.0)
