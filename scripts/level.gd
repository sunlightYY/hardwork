extends Node2D

const PLAYER := preload("res://scripts/player.gd")
const REQUESTER := preload("res://scripts/requester.gd")
const ITEM := preload("res://scripts/item.gd")
const ROOM := preload("res://assets/art/room.png")

const ROOM_W := 1280.0
const ROOM_H := 720.0
const CHAR_Y := 444.0
const START_X := 120.0
const EXIT_X := 1160.0
const REQUESTER_X := 900.0

signal floor_finished

var player: Node2D
var requester: Node2D
var items: Array = []
var leaving := false

func _ready() -> void:
	var backdrop := ColorRect.new()
	backdrop.color = Color("12151a")
	backdrop.position = Vector2(-200, -200)
	backdrop.size = Vector2(2000, 1200)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	backdrop.z_index = -40
	add_child(backdrop)

	var room := TextureRect.new()
	room.texture = ROOM
	room.position = Vector2.ZERO
	room.size = Vector2(ROOM_W, ROOM_H)
	room.mouse_filter = Control.MOUSE_FILTER_IGNORE
	room.z_index = -10
	add_child(room)

	player = PLAYER.new()
	player.global_position = Vector2(START_X, CHAR_Y)
	add_child(player)

	requester = REQUESTER.new()
	requester.global_position = Vector2(REQUESTER_X, CHAR_Y)
	requester.z_index = 5
	add_child(requester)
	player.requester = requester

	WorldState.phase_changed.connect(_on_phase_changed)
	start_floor()

func start_floor() -> void:
	leaving = false
	for item in items:
		if is_instance_valid(item):
			item.queue_free()
	items.clear()

	player.global_position = Vector2(START_X, CHAR_Y)
	player.frozen = false
	player.sitting = false
	requester.reset()
	WorldState.consume()
	WorldState.roll_request()
	requester.queue_redraw()

func _on_phase_changed(_is_night: bool) -> void:
	_drop_items()

func _drop_items() -> void:
	var base := player.global_position.x
	for i in range(3):
		var kind: String = WorldState.ITEM_TYPES[randi() % WorldState.ITEM_TYPES.size()]
		if i == 0 and randf() < 0.5:
			kind = WorldState.request
		var item := ITEM.new()
		item.setup(kind, base - 70.0 + float(i) * 70.0, 580.0)
		add_child(item)
		items.append(item)

func _process(_delta: float) -> void:
	if leaving or requester == null:
		return
	if requester.satisfied and player.global_position.x > EXIT_X:
		leaving = true
		floor_finished.emit()
