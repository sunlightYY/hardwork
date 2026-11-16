extends Node2D

const PLAYER := preload("res://scripts/player.gd")
const SUPERVISOR := preload("res://scripts/supervisor.gd")
const MONSTER := preload("res://scripts/monster.gd")
const COWORKER := preload("res://scripts/coworker.gd")

const FLOOR_Y := 520.0
const FLOOR_H := 228.0
const CEIL_H := 64.0
const SLAB_H := 26.0
const CHAR_Y := 442.0
const BAY := 340.0
const MULLION := 16.0

const SEG_A_START := 0.0
const SEG_A_END := 4400.0
const SEG_B_START := 5200.0
const SEG_B_END := 7800.0

var player: Node2D
var player_home := Vector2(680, CHAR_Y)
var work_point := Vector2(680, CHAR_Y)
var sink_point := Vector2(7540, CHAR_Y)
var min_x := 60.0
var max_x := SEG_B_END - 60.0
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
	backdrop.color = Color("151a21")
	backdrop.position = Vector2(SEG_A_START - 1600, -200)
	backdrop.size = Vector2(SEG_B_END - SEG_A_START + 3200, 1120)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	backdrop.z_index = -40
	add_child(backdrop)

	_build_strip(SEG_A_START, SEG_A_END, true)
	_build_strip(SEG_B_START, SEG_B_END, false)

	foreground = Node2D.new()
	foreground.z_index = 10
	add_child(foreground)
	_build_props()

	_spawn_player()
	_spawn_day_actors()
	_spawn_monsters()
	WorldState.phase_changed.connect(_on_phase_changed)
	WorldState.resentment_changed.connect(_on_resentment_changed)
	_apply_phase()

func _build_strip(x0: float, x1: float, office: bool) -> void:
	var width := x1 - x0
	var back := Node2D.new()
	back.z_index = -10
	add_child(back)

	_floor_band(back, x0, width, FLOOR_Y - FLOOR_H, false, office)
	_floor_band(back, x0, width, FLOOR_Y, true, office)
	_floor_band(back, x0, width, FLOOR_Y + FLOOR_H, false, office)

	var front := Node2D.new()
	front.z_index = 30
	add_child(front)

	var mx := x0 + 90.0
	while mx < x1:
		_layer_rect(front, mx, 0, MULLION, 720, Color("2c3a4a"))
		_layer_rect(front, mx + MULLION - 5, 0, 5, 720, Color("3d4f63"))
		mx += BAY

func _floor_band(parent: Node2D, x0: float, width: float, floor_line: float, detailed: bool, office: bool) -> void:
	var top := floor_line - FLOOR_H
	_layer_rect(parent, x0, floor_line, width, SLAB_H, Color("242f3c"))
	_layer_rect(parent, x0, floor_line, width, 5, Color("3a4a5c"))

	_layer_rect(parent, x0, top, width, CEIL_H, Color("e7e3dc"))

	var gx := x0
	while gx < x0 + width:
		_layer_rect(parent, gx, top, 2, CEIL_H, Color("d8d3cb"))
		gx += 64.0
	gx = x0 + 40.0
	while gx + 120.0 < x0 + width:
		_layer_rect(parent, gx, top + 22, 120, 14, Color("fbfdff"))
		gx += BAY

	_layer_rect(parent, x0, top + CEIL_H, width, FLOOR_H - CEIL_H, Color("d5d2cc"))

	gx = x0 + 50.0
	while gx < x0 + width:
		_layer_rect(parent, gx, top + CEIL_H, 2, FLOOR_H - CEIL_H, Color("cac4ba"))
		gx += 170.0

	_layer_rect(parent, x0, floor_line - 12, width, 12, Color("bab4aa"))
	_layer_rect(parent, x0, floor_line - 12, width, 2, Color("9aa4b3"))

	if detailed:
		_window(parent, x0 + 24, top + CEIL_H, 220, FLOOR_H - CEIL_H - 12)
		_window(parent, x0 + width - 244, top + CEIL_H, 220, FLOOR_H - CEIL_H - 12)
		if not office:
			var door_x := x0 + 260.0
			while door_x + 110.0 < x0 + width:
				_layer_rect(parent, door_x, floor_line - 150, 104, 150, Color("b6afa3"))
				_layer_rect(parent, door_x + 8, floor_line - 142, 88, 142, Color("c6bfb2"))
				_layer_rect(parent, door_x + 78, floor_line - 78, 10, 10, Color("8b857a"))
				_layer_rect(parent, door_x + 14, floor_line - 136, 76, 52, Color("9fb3c3"))
				door_x += 420.0
		return

	gx = x0 + 110.0
	while gx + 190.0 < x0 + width:
		_layer_rect(parent, gx, floor_line - 56, 190, 10, Color("b6bfcc"))
		_layer_rect(parent, gx + 8, floor_line - 46, 10, 46, Color("a9b3c1"))
		_layer_rect(parent, gx + 168, floor_line - 46, 10, 46, Color("a9b3c1"))
		_layer_rect(parent, gx + 52, floor_line - 92, 46, 36, Color("bec7d4"))
		_layer_rect(parent, gx + 58, floor_line - 86, 34, 24, Color("a8b6c6"))
		gx += 330.0

func _window(parent: Node2D, x: float, y: float, w: float, h: float) -> void:
	_layer_rect(parent, x, y, w, h, Color("a9cbe3"))
	_layer_rect(parent, x, y, w, h * 0.42, Color("c3dcee"))

	var skyline_x := x + 16.0
	var index := 0
	while skyline_x + 26.0 < x + w - 16.0:
		var tower_h := 40.0 + float((index * 37) % 5) * 14.0
		_layer_rect(parent, skyline_x, y + h - tower_h, 26, tower_h, Color("95b3c9"))
		skyline_x += 34.0
		index += 1

	_layer_rect(parent, x, y, w, 4, Color("8fa2b5"))
	_layer_rect(parent, x, y + h - 4, w, 4, Color("8fa2b5"))

func _layer_rect(parent: Node2D, x: float, y: float, w: float, h: float, color: Color) -> void:
	var rect := ColorRect.new()
	rect.color = color
	rect.position = Vector2(x, y)
	rect.size = Vector2(w, h)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(rect)

func _build_props() -> void:
	var x := 560.0
	while x < SEG_A_END - 260.0:
		_desk(x)
		x += 330.0

	_plant(430)
	_plant(1980)
	_plant(3120)
	_plant(4270)
	_plant(5720)
	_water_cooler(5580)

	_sink(7540)

func _desk(x: float) -> void:
	_layer_rect(foreground, x, 456, 210, 18, Color("cfc2ac"))
	_layer_rect(foreground, x, 456, 210, 4, Color("ded3c0"))
	_layer_rect(foreground, x + 8, 474, 12, 46, Color("a9a191"))
	_layer_rect(foreground, x + 190, 474, 12, 46, Color("a9a191"))

	_layer_rect(foreground, x + 18, 384, 78, 68, Color("3a3f47"))
	_layer_rect(foreground, x + 25, 391, 64, 50, Color("8fd7e8") if not WorldState.is_night else Color("8f7ad8"))
	_layer_rect(foreground, x + 18, 452, 78, 6, Color("2b3037"))
	_layer_rect(foreground, x + 54, 456, 6, 10, Color("2b3037"))

	_layer_rect(foreground, x + 130, 470, 30, 50, Color("444b55"))
	_layer_rect(foreground, x + 134, 476, 22, 8, Color("5b636e"))

	_layer_rect(foreground, x + 164, 488, 34, 32, Color("b9c0c9"))
	_layer_rect(foreground, x + 168, 492, 26, 10, Color("cfd5dd"))

	_layer_rect(foreground, x + 62, 506, 54, 14, Color("4a5261"))
	_layer_rect(foreground, x + 30, 520, 10, 4, Color("3c434e"))
	_layer_rect(foreground, x + 150, 520, 10, 4, Color("3c434e"))

func _plant(x: float) -> void:
	_layer_rect(foreground, x, 470, 62, 52, Color("c9c3b8"))
	_layer_rect(foreground, x + 6, 476, 50, 44, Color("ded9cf"))

	for i in range(5):
		var leaf_x := x - 14 + i * 18
		var leaf_y := 372.0 + absf(2 - i) * 22.0
		_layer_rect(foreground, leaf_x, leaf_y, 24, 106, Color("4f8a5b") if i % 2 == 0 else Color("3f7a4c"))
	_layer_rect(foreground, x + 22, 400, 12, 78, Color("3a6b46"))

func _water_cooler(x: float) -> void:
	_layer_rect(foreground, x, 416, 76, 106, Color("e2e8ef"))
	_layer_rect(foreground, x + 8, 424, 60, 90, Color("d3dae3"))
	_layer_rect(foreground, x + 14, 342, 48, 76, Color("9fd0e6"))
	_layer_rect(foreground, x + 14, 342, 48, 10, Color("b6dcee"))

func _sink(x: float) -> void:
	_layer_rect(foreground, x - 72, 462, 184, 30, Color("e6ecf3"))
	_layer_rect(foreground, x - 62, 468, 164, 18, Color("cdd7e2"))
	_layer_rect(foreground, x - 40, 356, 128, 100, Color("b9d9e6"))
	_layer_rect(foreground, x - 32, 364, 112, 84, Color("cfe8f2"))

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

	var seats := [860.0, 1200.0, 1540.0, 2240.0, 2580.0, 3260.0, 3600.0, 4080.0]
	for i in range(seats.size()):
		var worker := COWORKER.new()
		worker.global_position = Vector2(seats[i], CHAR_Y)
		worker.facing_right = i % 2 == 0
		day_actors.add_child(worker)

	supervisor = SUPERVISOR.new()
	supervisor.player = player
	day_actors.add_child(supervisor)

func _spawn_monsters() -> void:
	var spots := [Vector2(1500, 484), Vector2(2900, 484), Vector2(3800, 484), Vector2(6400, 484)]
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
