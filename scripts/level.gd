extends Node2D

const PLAYER := preload("res://scripts/player.gd")
const SUPERVISOR := preload("res://scripts/supervisor.gd")
const MONSTER := preload("res://scripts/monster.gd")
const COWORKER := preload("res://scripts/coworker.gd")

const FLOOR_Y := 640.0
const CHAR_Y := 598.0

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
	backdrop.color = Color("191d24")
	backdrop.position = Vector2(SEG_A_START - 1600, -200)
	backdrop.size = Vector2(SEG_B_END - SEG_A_START + 3200, 1120)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	backdrop.z_index = -30
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

	_layer_rect(back, x0, -40, width, FLOOR_Y + 40, Color("cbd3de"))
	_layer_rect(back, x0, 0, width, 96, Color("b9c2cf"))
	_layer_rect(back, x0, 80, width, 6, Color("a7b0bf"))
	_layer_rect(back, x0, FLOOR_Y - 16, width, 16, Color("8f99a8"))
	_layer_rect(back, x0, FLOOR_Y, width, 720 - FLOOR_Y, Color("a3acba"))

	var step := 360.0
	var x := x0 + 140.0
	while x + 170.0 < x1:
		if office:
			_layer_rect(back, x, 200, 170, 180, Color("cfe3f4"))
			_layer_rect(back, x, 200, 170, 8, Color("b3c4d6"))
			_layer_rect(back, x, 372, 170, 8, Color("b3c4d6"))
			_layer_rect(back, x + 82, 208, 6, 164, Color("b3c4d6"))
		else:
			_layer_rect(back, x, 300, 110, 340, Color("b6bfcd"))
			_layer_rect(back, x + 8, 312, 94, 316, Color("a6b0c0"))
			_layer_rect(back, x + 96, 430, 10, 10, Color("e3e8ef"))
		x += step

	for dx in [60.0, 300.0, 540.0, 780.0]:
		var lx: float = x0 + float(dx)
		if lx + 120.0 < x1:
			_layer_rect(back, lx, 34, 120, 12, Color("eef2f7"))
			_layer_rect(back, lx + 14, 46, 92, 4, Color("fdfefe"))

	_layer_rect(back, x0, 430, width, 4, Color("c0c9d6"))

	if office:
		var poster_x := x0 + 250.0
		var poster_index := 0
		while poster_x + 96.0 < x1:
			var frame_color := Color("9fb3c9") if poster_index % 2 == 0 else Color("c3a6a0")
			_layer_rect(back, poster_x, 452, 96, 122, frame_color)
			_layer_rect(back, poster_x + 8, 460, 80, 106,
				Color("dbe6f1") if poster_index % 2 == 0 else Color("e6d2cb"))
			poster_x += 620.0
			poster_index += 1

		var clock_x := x0 + 900.0
		while clock_x + 76.0 < x1:
			_layer_rect(back, clock_x, 118, 76, 76, Color("f1f4f8"))
			_layer_rect(back, clock_x + 6, 124, 64, 64, Color("e2e8f0"))
			_layer_rect(back, clock_x + 36, 136, 4, 22, Color("6d7686"))
			_layer_rect(back, clock_x + 38, 154, 16, 4, Color("6d7686"))
			clock_x += 1500.0

	_layer_rect(back, x1 - 26, 0, 26, FLOOR_Y, Color("8b95a4"))
	_layer_rect(back, x1 - 10, 0, 10, FLOOR_Y, Color("78828f"))

func _layer_rect(parent: Node2D, x: float, y: float, w: float, h: float, color: Color) -> void:
	var rect := ColorRect.new()
	rect.color = color
	rect.position = Vector2(x, y)
	rect.size = Vector2(w, h)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(rect)

func _build_props() -> void:
	var x := 600.0
	while x < SEG_A_END - 200.0:
		_desk(x)
		x += 340.0

	_plant(420)
	_plant(1880)
	_plant(3100)
	_plant(4260)
	_plant(5720)
	_water_cooler(5600)

	_sink(7540)

func _desk(x: float) -> void:
	var top := ColorRect.new()
	top.color = Color("c9a97e")
	top.position = Vector2(x, 576)
	top.size = Vector2(200, 22)
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	foreground.add_child(top)

	for dx in [12.0, 172.0]:
		var leg := ColorRect.new()
		leg.color = Color("a98c66")
		leg.position = Vector2(x + float(dx), 598)
		leg.size = Vector2(16, 44)
		leg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		foreground.add_child(leg)

	var monitor := ColorRect.new()
	monitor.color = Color("2f3642")
	monitor.position = Vector2(x + 42, 522)
	monitor.size = Vector2(66, 54)
	monitor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	foreground.add_child(monitor)

	var screen := ColorRect.new()
	screen.color = Color("3f5168") if not WorldState.is_night else Color("6b5fa8")
	screen.position = Vector2(x + 48, 528)
	screen.size = Vector2(54, 40)
	screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	foreground.add_child(screen)

	var paper := ColorRect.new()
	paper.color = Color("f4f6fa")
	paper.position = Vector2(x + 140, 566)
	paper.size = Vector2(40, 10)
	paper.mouse_filter = Control.MOUSE_FILTER_IGNORE
	foreground.add_child(paper)

func _plant(x: float) -> void:
	var pot := ColorRect.new()
	pot.color = Color("b0705a")
	pot.position = Vector2(x, 588)
	pot.size = Vector2(52, 52)
	pot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	foreground.add_child(pot)

	for i in range(5):
		var leaf := ColorRect.new()
		leaf.color = Color("4f8a5b") if i % 2 == 0 else Color("3f7a4c")
		leaf.position = Vector2(x - 18 + i * 18, 498 - absf(2 - i) * 16)
		leaf.size = Vector2(24, 100)
		leaf.mouse_filter = Control.MOUSE_FILTER_IGNORE
		foreground.add_child(leaf)

func _water_cooler(x: float) -> void:
	var body := ColorRect.new()
	body.color = Color("dfe6ee")
	body.position = Vector2(x, 508)
	body.size = Vector2(64, 132)
	body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	foreground.add_child(body)

	var bottle := ColorRect.new()
	bottle.color = Color("8fc2dd")
	bottle.position = Vector2(x + 12, 440)
	bottle.size = Vector2(40, 68)
	bottle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	foreground.add_child(bottle)

func _sink(x: float) -> void:
	var basin := ColorRect.new()
	basin.color = Color("e8eef5")
	basin.position = Vector2(x - 60, 566)
	basin.size = Vector2(160, 32)
	basin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	foreground.add_child(basin)

	var mirror := ColorRect.new()
	mirror.color = Color("bfe0ea")
	mirror.position = Vector2(x - 42, 372)
	mirror.size = Vector2(124, 168)
	mirror.mouse_filter = Control.MOUSE_FILTER_IGNORE
	foreground.add_child(mirror)

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

	var seats := [860.0, 1200.0, 1540.0, 2220.0, 2560.0, 3240.0, 3580.0, 4080.0]
	for i in range(seats.size()):
		var worker := COWORKER.new()
		worker.global_position = Vector2(seats[i], CHAR_Y)
		worker.facing_right = i % 2 == 0
		day_actors.add_child(worker)

	supervisor = SUPERVISOR.new()
	supervisor.player = player
	day_actors.add_child(supervisor)

func _spawn_monsters() -> void:
	var spots := [Vector2(1500, 624), Vector2(2900, 624), Vector2(3800, 624), Vector2(6400, 624)]
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
