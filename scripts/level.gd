extends Node2D

const PLAYER := preload("res://scripts/player.gd")
const SUPERVISOR := preload("res://scripts/supervisor.gd")
const MONSTER := preload("res://scripts/monster.gd")
const COWORKER := preload("res://scripts/coworker.gd")

const MAP_SIZE := Vector2(2112, 1056)
const DESK_SIZE := Vector2(96, 56)

var player: Node2D
var player_home := Vector2(240, 648)
var work_point := Vector2(192, 596)
var sink_point := Vector2(1968, 824)

var day_actors: Node2D
var supervisor: Node2D
var monsters: Array = []
var solid: StaticBody2D

var wall_rects := [
	Rect2(0, 0, MAP_SIZE.x, 48),
	Rect2(0, MAP_SIZE.y - 48, MAP_SIZE.x, 48),
	Rect2(0, 0, 48, MAP_SIZE.y),
	Rect2(MAP_SIZE.x - 48, 0, 48, MAP_SIZE.y),
	Rect2(1248, 432, 384, 192),
	Rect2(1848, 336, 48, 240),
	Rect2(1920, 744, 96, 56),
]

func _ready() -> void:
	_build_floor()
	_build_solid()
	_build_desks()
	_spawn_player()
	_spawn_day_actors()
	_spawn_monsters()
	WorldState.phase_changed.connect(_on_phase_changed)
	WorldState.resentment_changed.connect(_on_resentment_changed)
	_apply_phase()

func _build_floor() -> void:
	var floor := ColorRect.new()
	floor.color = Color("dfe3e8")
	floor.size = MAP_SIZE
	floor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(floor)

	var hall := ColorRect.new()
	hall.color = Color("d3d9e1")
	hall.position = Vector2(960, 48)
	hall.size = Vector2(1104, 960)
	hall.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(hall)

func _build_solid() -> void:
	solid = StaticBody2D.new()
	solid.collision_layer = 1
	solid.collision_mask = 0
	add_child(solid)

	for rect in wall_rects:
		var shape := CollisionShape2D.new()
		var box := RectangleShape2D.new()
		box.size = rect.size
		shape.shape = box
		shape.position = rect.position + rect.size * 0.5
		solid.add_child(shape)

		var visual := ColorRect.new()
		visual.color = Color("8d93a0")
		visual.position = rect.position
		visual.size = rect.size
		visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(visual)

func _build_desks() -> void:
	for row in range(3):
		for col in range(4):
			var pos := Vector2(144 + col * 216, 168 + row * 180)
			_add_desk(Rect2(pos, DESK_SIZE), row == 2 and col == 0)

func _add_desk(rect: Rect2, mine: bool) -> void:
	var shape := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = rect.size
	shape.shape = box
	shape.position = rect.position + rect.size * 0.5
	solid.add_child(shape)

	var top := ColorRect.new()
	top.color = Color("f7f9fc") if mine else Color("c9cfd8")
	top.position = rect.position
	top.size = rect.size
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(top)

	var monitor := ColorRect.new()
	monitor.color = Color("3a4250")
	monitor.position = rect.position + Vector2(rect.size.x * 0.5 - 14, 10)
	monitor.size = Vector2(28, 18)
	monitor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(monitor)

	var chair := ColorRect.new()
	chair.color = Color("6f7787")
	chair.position = rect.position + Vector2(rect.size.x * 0.5 - 12, rect.size.y + 12)
	chair.size = Vector2(24, 20)
	chair.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(chair)

func _spawn_player() -> void:
	player = PLAYER.new()
	player.global_position = player_home
	player.work_point = work_point
	player.sink_point = sink_point
	player.interact_requested.connect(_on_interact)
	add_child(player)

func _spawn_day_actors() -> void:
	day_actors = Node2D.new()
	add_child(day_actors)

	var seats := [
		Vector2(180, 152), Vector2(396, 152), Vector2(612, 332),
		Vector2(828, 332), Vector2(396, 512), Vector2(612, 692),
		Vector2(1040, 720), Vector2(1700, 200),
	]
	for i in range(seats.size()):
		var worker := COWORKER.new()
		worker.global_position = seats[i]
		worker.phase_offset = float(i) * 0.9
		worker.facing = -1.0 if i % 2 == 0 else 1.0
		day_actors.add_child(worker)

	supervisor = SUPERVISOR.new()
	supervisor.player = player
	day_actors.add_child(supervisor)

func _spawn_monsters() -> void:
	var spots := [Vector2(760, 880), Vector2(1080, 300), Vector2(1600, 700)]
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
