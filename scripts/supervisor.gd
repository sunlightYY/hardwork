extends CharacterBody2D

const SPEED := 95.0
const VIEW_DISTANCE := 300.0
const VIEW_HALF_ANGLE := 0.75
const SCOLD_AFTER := 1.2
const SCOLD_COOLDOWN := 4.0

var waypoints := [Vector2(300, 300), Vector2(900, 300), Vector2(900, 700), Vector2(300, 700)]
var waypoint_index := 0
var player: Node2D
var facing := Vector2.RIGHT
var suspicion := 0.0
var cooldown := 0.0

func _ready() -> void:
	collision_layer = 4
	collision_mask = 1
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(24, 24)
	shape.shape = rect
	add_child(shape)
	global_position = waypoints[0]

func _physics_process(delta: float) -> void:
	cooldown = maxf(0.0, cooldown - delta)

	if WorldState.is_night or player == null:
		velocity = Vector2.ZERO
		suspicion = 0.0
		queue_redraw()
		return

	var target: Vector2 = waypoints[waypoint_index]
	if global_position.distance_to(target) < 8.0:
		waypoint_index = (waypoint_index + 1) % waypoints.size()
		target = waypoints[waypoint_index]
	var to_target := (target - global_position).normalized()
	facing = to_target
	velocity = to_target * SPEED
	move_and_slide()

	var sees := _can_see_player()
	if sees and player.is_moving():
		suspicion += delta
	else:
		suspicion = maxf(0.0, suspicion - delta * 1.5)

	if suspicion >= SCOLD_AFTER and cooldown <= 0.0:
		suspicion = 0.0
		cooldown = SCOLD_COOLDOWN
		WorldState.get_scolded()

	queue_redraw()

func _can_see_player() -> bool:
	var to_player := player.global_position - global_position
	if to_player.length() > VIEW_DISTANCE:
		return false
	if absf(facing.angle_to(to_player.normalized())) > VIEW_HALF_ANGLE:
		return false
	var query := PhysicsRayQueryParameters2D.create(global_position, player.global_position, 1)
	query.exclude = [get_rid()]
	return get_world_2d().direct_space_state.intersect_ray(query).is_empty()

func _draw() -> void:
	var angle := facing.angle()
	var points := PackedVector2Array([Vector2.ZERO])
	var steps := 14
	for i in range(steps + 1):
		var a := angle - VIEW_HALF_ANGLE + (2.0 * VIEW_HALF_ANGLE) * float(i) / float(steps)
		points.append(Vector2(cos(a), sin(a)) * VIEW_DISTANCE)
	var cone := Color(0.55, 0.75, 1.0, 0.10)
	if suspicion > 0.4:
		cone = Color(1.0, 0.30, 0.30, 0.22)
	draw_colored_polygon(points, cone)

	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.6))
	draw_circle(Vector2(0, 24), 15.0, Color(0, 0, 0, 0.16))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	draw_rect(Rect2(-11, 2, 22, 14), Color("15171c"))
	draw_rect(Rect2(-14, -15, 28, 22), Color("1d2027"))
	draw_rect(Rect2(-12, -13, 24, 18), Color("23262e"))
	draw_rect(Rect2(-4, -13, 8, 7), Color("e9edf4"))
	draw_rect(Rect2(-1.5, -11, 3, 14), Color("8c2a33"))
	draw_circle(Vector2(0, -20), 10.6, Color("f0c9a6"))
	draw_rect(Rect2(-10, -26, 20, 6), Color("14161b"))
