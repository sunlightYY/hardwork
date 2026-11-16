extends Node2D

const PLAYER := preload("res://scripts/player.gd")
const SUPERVISOR := preload("res://scripts/supervisor.gd")
const MONSTER := preload("res://scripts/monster.gd")
const COWORKER := preload("res://scripts/coworker.gd")
const ROOM := preload("res://assets/art/room.png")

const ROOM_W := 1280.0
const ROOM_H := 720.0
const CHAR_Y := 444.0

const SEG_A_START := 0.0
const SEG_A_END := 1280.0
const SEG_B_START := 1600.0
const SEG_B_END := 2880.0

var player: Node2D
var player_home := Vector2(640, CHAR_Y)
var work_point := Vector2(640, CHAR_Y)
var sink_point := Vector2(2700, CHAR_Y)
var min_x := 40.0
var max_x := SEG_B_END - 40.0
var segment_a_start := SEG_A_START
var segment_a_end := SEG_A_END
var segment_b_start := SEG_B_START
var segment_b_end := SEG_B_END
var char_y := CHAR_Y

var day_actors: Node2D
var foreground: Node2D
var supervisor: Node2D
var monsters: Array = []

func _ready() -> void:
	var backdrop := ColorRect.new()
	backdrop.color = Color("12151a")
	backdrop.position = Vector2(-1600, -400)
	backdrop.size = Vector2(7000, 1600)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	backdrop.z_index = -40
	add_child(backdrop)

	_build_room(SEG_A_START, false)
	_build_room(SEG_B_START, true)

	foreground = Node2D.new()
	foreground.z_index = 10
	add_child(foreground)
	_build_restroom()

	_spawn_player()
	_spawn_day_actors()
	_spawn_monsters()
	WorldState.phase_changed.connect(_on_phase_changed)
	WorldState.resentment_changed.connect(_on_resentment_changed)
	_apply_phase()

func _build_room(x0: float, flipped: bool) -> void:
	var room := TextureRect.new()
	room.texture = ROOM
	room.position = Vector2(x0, 0)
	room.size = Vector2(ROOM_W, ROOM_H)
	room.flip_h = flipped
	room.mouse_filter = Control.MOUSE_FILTER_IGNORE
	room.z_index = -10
	add_child(room)

func _rect(x: float, y: float, w: float, h: float, color: Color) -> void:
	var rect := ColorRect.new()
	rect.color = color
	rect.position = Vector2(x, y)
	rect.size = Vector2(w, h)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	foreground.add_child(rect)

func _build_restroom() -> void:
	_rect(2600, 250, 300, 8, Color("9fb0c2"))
	_rect(2640, 470, 210, 26, Color("e6ecf3"))
	_rect(2650, 476, 190, 14, Color("cdd7e2"))
	_rect(2668, 300, 150, 120, Color("b9d9e6"))
	_rect(2676, 308, 134, 104, Color("cfe8f2"))

func _spawn_player() -> void:
	player = PLAYER.new()
	player.global_position = player_home
	player.work_point = work_point
	player.sink_point = sink_point
	player.min_x = min_x
	player.max_x = max_x
	player.interact_requested.connect(_on_interact)
	add_child(player)

func _spawn_day_actors() -> void:
	day_actors = Node2D.new()
	add_child(day_actors)

	var seats := [430.0, 900.0, 1730.0, 2500.0]
	for i in range(seats.size()):
		var worker := COWORKER.new()
		worker.global_position = Vector2(seats[i], CHAR_Y)
		worker.facing_right = i % 2 == 0
		day_actors.add_child(worker)

	supervisor = SUPERVISOR.new()
	supervisor.player = player
	day_actors.add_child(supervisor)

func _spawn_monsters() -> void:
	var spots := [Vector2(980, 527), Vector2(2100, 527), Vector2(2500, 527)]
	for spot in spots:
		var monster := MONSTER.new()
		monster.global_position = spot
		monster.player = player
		add_child(monster)
		monsters.append(monster)

func _on_interact(kind: String) -> void:
	if kind == "work":
		WorldState.complete_task()
	elif kind == "sink":
		WorldState.wash_face()

func _on_phase_changed(_is_night: bool) -> void:
	_apply_phase()

func _on_resentment_changed(_value: float) -> void:
	_refresh_monsters()

func _apply_phase() -> void:
	if day_actors:
		day_actors.visible = not WorldState.is_night
	_refresh_monsters()

func _refresh_monsters() -> void:
	var count := WorldState.monster_count() if WorldState.is_night else 0
	for i in range(monsters.size()):
		monsters[i].visible = i < count
		monsters[i].set_active(i < count)
