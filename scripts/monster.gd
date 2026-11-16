extends CharacterBody2D

const SPEED := 130.0
const SIGHT := 340.0
const CONTACT := 30.0

var player: Node2D
var home := Vector2.ZERO
var active := false
var caught_cooldown := 0.0
var anim := 0.0

func _ready() -> void:
	collision_layer = 8
	collision_mask = 1
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(26, 26)
	shape.shape = rect
	add_child(shape)
	home = global_position

func set_active(value: bool) -> void:
	active = value and WorldState.is_night
	velocity = Vector2.ZERO
	queue_redraw()

func _physics_process(delta: float) -> void:
	anim += delta
	caught_cooldown = maxf(0.0, caught_cooldown - delta)

	if not active or player == null:
		velocity = Vector2.ZERO
		queue_redraw()
		return

	var to_player := player.global_position - global_position
	var dist := to_player.length()
	if dist < SIGHT and _has_line_of_sight():
		velocity = to_player.normalized() * SPEED
	else:
		var to_home := home - global_position
		velocity = to_home.normalized() * SPEED * 0.45 if to_home.length() > 8.0 else Vector2.ZERO
	move_and_slide()

	if dist < CONTACT and caught_cooldown <= 0.0:
		caught_cooldown = 2.0
		WorldState.caught()

	queue_redraw()

func _has_line_of_sight() -> bool:
	var query := PhysicsRayQueryParameters2D.create(global_position, player.global_position, 1)
	query.exclude = [get_rid()]
	return get_world_2d().direct_space_state.intersect_ray(query).is_empty()

func _draw() -> void:
	var bob := sin(anim * 3.4) * 3.0
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.6))
	draw_circle(Vector2(0, 28), 18.0, Color(0, 0, 0, 0.28))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	draw_rect(Rect2(-15, -30 + bob, 30, 44), Color("0d0d14"))
	draw_rect(Rect2(-15, -30 + bob, 30, 4), Color("2a1a3d"))
	draw_circle(Vector2(0, -38 + bob), 13.5, Color("0d0d14"))
	draw_circle(Vector2(-5.5, -40 + bob), 3.2, Color("ff3355"))
	draw_circle(Vector2(5.5, -40 + bob), 3.2, Color("ff3355"))
	draw_circle(Vector2(-5.5, -40 + bob), 1.6, Color("ffd0d8"))
	draw_circle(Vector2(5.5, -40 + bob), 1.6, Color("ffd0d8"))
