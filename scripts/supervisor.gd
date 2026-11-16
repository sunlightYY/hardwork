extends CharacterBody2D

const SHEET := preload("res://assets/art/supervisor.png")

const SPEED := 95.0
const VIEW_DISTANCE := 300.0
const VIEW_HALF_ANGLE := 0.75
const SCOLD_AFTER := 1.2
const SCOLD_COOLDOWN := 4.0

var waypoints := [Vector2(1200, 618), Vector2(4100, 618)]
var waypoint_index := 0
var player: Node2D
var facing := Vector2.RIGHT
var suspicion := 0.0
var cooldown := 0.0
var sprite: AnimatedSprite2D

func _ready() -> void:
	collision_layer = 4
	collision_mask = 1
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(24, 24)
	shape.shape = rect
	add_child(shape)
	sprite = AnimatedSprite2D.new()
	sprite.frames = Sheet.frames(SHEET)
	sprite.animation = "idle_down"
	sprite.scale = Vector2(2.0, 2.0)
	add_child(sprite)
	global_position = waypoints[0]

func _physics_process(delta: float) -> void:
	cooldown = maxf(0.0, cooldown - delta)

	if WorldState.is_night or player == null:
		velocity = Vector2.ZERO
		suspicion = 0.0
		_update_anim()
		queue_redraw()
		return

	var target: Vector2 = waypoints[waypoint_index]
	if global_position.distance_to(target) < 8.0:
		waypoint_index = (waypoint_index + 1) % waypoints.size()
		target = waypoints[waypoint_index]
	var to_target := (target - global_position).normalized()
	facing = Vector2(signf(to_target.x), 0.0)
	velocity = facing * SPEED
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

	_update_anim()
	queue_redraw()

func _update_anim() -> void:
	if sprite == null:
		return
	var target := ("walk_" if velocity.length() > 1.0 else "idle_") + Sheet.dir_name(facing)
	if sprite.animation != target:
		sprite.play(target)

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

	draw_set_transform(Vector2(0, 22), 0.0, Vector2(1.0, 0.35))
	draw_circle(Vector2.ZERO, 18.0, Color(0, 0, 0, 0.18))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
