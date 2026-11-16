extends CharacterBody2D

const SHEET := preload("res://assets/art/player.png")
const SPEED := 200.0
const PICKUP_RADIUS := 110.0
const GIVE_RADIUS := 190.0

var frozen := false
var sitting := true
var anim_time := 0.0
var sprite: AnimatedSprite2D
var requester: Node2D

func _ready() -> void:
	add_to_group("player")
	collision_layer = 2
	collision_mask = 17
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(56, 300)
	shape.shape = rect
	shape.position = Vector2(0, -110)
	add_child(shape)

	sprite = AnimatedSprite2D.new()
	sprite.frames = Sheet.frames(SHEET)
	sprite.animation = "idle_right"
	sprite.scale = Vector2(8.0, 8.0)
	add_child(sprite)

func _physics_process(delta: float) -> void:
	anim_time += delta
	if frozen:
		velocity = Vector2.ZERO
		move_and_slide()
		_update_anim()
		return

	if sitting:
		velocity = Vector2.ZERO
		move_and_slide()
		if Input.is_action_just_pressed("move_right") or Input.is_action_just_pressed("move_left"):
			sitting = false
		_update_anim()
		queue_redraw()
		return

	velocity = Vector2(SPEED, 0.0)
	move_and_slide()

	if Input.is_action_just_pressed("toggle_phase"):
		WorldState.toggle_phase()

	_check_pickup()
	_try_give()
	_update_anim()
	queue_redraw()

func _check_pickup() -> void:
	for node in get_tree().get_nodes_in_group("item"):
		if node.falling:
			continue
		if absf(node.global_position.x - global_position.x) > PICKUP_RADIUS:
			continue
		WorldState.pick_up(node.kind)
		WorldState.post_message("PICKED UP: " + item_label(node.kind), 1.4)
		node.queue_free()

func _try_give() -> void:
	if requester == null or requester.satisfied:
		return
	if absf(requester.global_position.x - global_position.x) > GIVE_RADIUS:
		return
	if not Input.is_action_just_pressed("interact"):
		return
	try_give_now()

func try_give_now() -> void:
	if requester == null or requester.satisfied:
		return
	if WorldState.held == "":
		WorldState.post_message("YOUR HANDS ARE EMPTY", 1.6)
	elif WorldState.held == WorldState.request:
		requester.satisfy()
		WorldState.consume()
		WorldState.post_message("HE TAKES IT. THE WAY IS OPEN.", 2.2)
	else:
		WorldState.post_message("NOT WHAT HE WANTS", 1.6)

func item_label(kind: String) -> String:
	match kind:
		"gloves":
			return "BOXING GLOVES"
		"cards":
			return "PLAYING CARDS"
		"doc":
			return "WORK DOCUMENT"
	return "SOMETHING"

func _update_anim() -> void:
	if sprite == null:
		return
	var target := "sit"
	if not sitting:
		target = "walk_right" if velocity.length() > 10.0 else "idle_right"
	if sprite.animation != target:
		sprite.play(target)

func _draw() -> void:
	draw_set_transform(Vector2(0, 156), 0.0, Vector2(1.0, 0.30))
	draw_circle(Vector2.ZERO, 74.0, Color(0, 0, 0, 0.18))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
