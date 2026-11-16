extends Node2D

const DRONE := preload("res://scripts/drone_camera.gd")


var level: Node2D
var player: Node2D
var camera
var tint: ColorRect
var fade: ColorRect
var task_label: Label
var phase_label: Label
var watch_label: Label
var hint_label: Label
var message_label: Label
var big_label: Label

var message_timer := 0.0
var busy := false
var controls_hint_shown := false
var segment := 0
var corner_busy := false

func _ready() -> void:
	level = $Level
	player = level.player
	_build_tint()
	_build_camera()
	_build_hud()

	WorldState.tasks_changed.connect(_on_tasks_changed)
	WorldState.message_posted.connect(_on_message)
	WorldState.day_completed.connect(_on_day_completed)
	WorldState.player_caught.connect(_on_caught)
	_on_tasks_changed(WorldState.tasks_done, WorldState.tasks_total)
	_intro()

func _process(delta: float) -> void:
	_paint_tint(delta)
	_paint_hud(delta)
	_layout()
	_check_corner()

func _check_corner() -> void:
	if corner_busy or busy or level == null:
		return
	if segment == 0 and player.global_position.x > level.segment_a_end - 70.0:
		_turn_corner(1, 1.0, level.segment_b_start + 150.0)
	elif segment == 1 and player.global_position.x < level.segment_b_start + 70.0:
		_turn_corner(0, -1.0, level.segment_a_end - 150.0)

func _turn_corner(next_segment: int, swing_sign: float, target_x: float) -> void:
	corner_busy = true
	player.frozen = true
	camera.trigger(swing_sign)
	await get_tree().create_timer(0.34).timeout
	await _flash(Color(0, 0, 0, 1), 0.22)
	segment = next_segment
	player.global_position = Vector2(target_x, level.char_y)
	player.dir = Vector2(swing_sign, 0.0)
	if next_segment == 0:
		camera.set_bounds(level.segment_a_start, level.segment_a_end)
	else:
		camera.set_bounds(level.segment_b_start, level.segment_b_end)
	camera.snap_to(player.global_position)
	camera.trigger(-swing_sign)
	await _flash(Color(0, 0, 0, 0), 0.42)
	player.frozen = false
	corner_busy = false

func _paint_tint(delta: float) -> void:
	var target := Color(0, 0, 0, 0)
	if WorldState.is_night:
		target = WorldState.tint()
		target.s = clampf(target.s * 2.0, 0.0, 1.0)
		target.a = 0.26 + 0.44 * WorldState.resentment
	tint.color = tint.color.lerp(target, 1.0 - exp(-6.0 * delta))

func _paint_hud(delta: float) -> void:
	phase_label.text = "NIGHT" if WorldState.is_night else "DAY"
	phase_label.add_theme_color_override("font_color",
		Color("c9a3ff") if WorldState.is_night else Color("8fa3b8"))

	watch_label.visible = WorldState.watch_visible
	if watch_label.visible:
		watch_label.text = "WATCH  %d%%" % int(round(WorldState.resentment * 100.0))

	hint_label.text = ""
	if player.sitting:
		hint_label.text = "A / D     LEFT     RIGHT"
	elif not busy:
		if not controls_hint_shown:
			controls_hint_shown = true
			WorldState.post_message("SHIFT: WATCH    E: INTERACT    CTRL: CROUCH", 4.5)
		match player.near:
			"work":
				hint_label.text = "E   DO YOUR WORK"
			"sink":
				if WorldState.wash_cooldown > 0.0:
					hint_label.text = "THE MIRROR IS STILL WET"
				else:
					hint_label.text = "E   SPLASH WATER ON YOUR FACE"

	if message_timer > 0.0:
		message_timer -= delta
		if message_timer <= 0.0:
			message_label.text = ""

func _layout() -> void:
	var vp := get_viewport_rect().size
	phase_label.position = Vector2(vp.x - 32.0 - phase_label.size.x, 24.0)
	watch_label.position = Vector2(vp.x - 32.0 - watch_label.size.x, 58.0)
	message_label.position = Vector2((vp.x - message_label.size.x) * 0.5, 132.0)
	hint_label.position = Vector2((vp.x - hint_label.size.x) * 0.5, vp.y - 76.0)
	big_label.position = Vector2((vp.x - big_label.size.x) * 0.5, (vp.y - big_label.size.y) * 0.5)

func _build_tint() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 5
	add_child(layer)
	tint = ColorRect.new()
	tint.set_anchors_preset(Control.PRESET_FULL_RECT)
	tint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tint.color = Color(0, 0, 0, 0)
	layer.add_child(tint)

func _build_camera() -> void:
	camera = DRONE.new()
	camera.target = player
	camera.set_bounds(level.segment_a_start, level.segment_a_end)
	add_child(camera)

func _build_hud() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 10
	add_child(layer)

	fade = ColorRect.new()
	fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade.color = Color(0, 0, 0, 0)
	layer.add_child(fade)

	task_label = _make_label(24, Color("e2e8f0"))
	task_label.position = Vector2(28, 24)
	layer.add_child(task_label)

	phase_label = _make_label(24, Color("8fa3b8"))
	layer.add_child(phase_label)

	watch_label = _make_label(22, Color("d9c8ff"))
	watch_label.visible = false
	layer.add_child(watch_label)

	message_label = _make_label(26, Color("ffd9a0"))
	layer.add_child(message_label)

	hint_label = _make_label(22, Color("b9c6d6"))
	layer.add_child(hint_label)

	big_label = _make_label(64, Color("ffffff"))
	layer.add_child(big_label)

func _make_label(size: int, color: Color) -> Label:
	var label := Label.new()
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	label.add_theme_constant_override("outline_size", 5)
	return label

func _on_tasks_changed(done: int, total: int) -> void:
	task_label.text = "WORK  %d / %d" % [done, total]

func _on_message(text: String, seconds: float) -> void:
	message_label.text = text
	message_timer = seconds
	_layout()

func _intro() -> void:
	player.sitting = true
	player.frozen = true
	WorldState.post_message("ANOTHER DAY. SAME SPREADSHEET.", 2.6)
	await get_tree().create_timer(1.8).timeout
	WorldState.toggle_phase()
	await get_tree().create_timer(1.4).timeout
	WorldState.toggle_phase()
	WorldState.post_message("SOMETHING ON YOUR WRIST JUST CLICKED.", 3.0)
	player.frozen = false


func _on_caught() -> void:
	if busy:
		return
	busy = true
	player.frozen = true
	big_label.text = ""
	await _flash(Color(0.6, 0.05, 0.1, 0.85), 0.12)
	player.global_position = level.player_home
	camera.snap_to(level.player_home)
	segment = 0
	await get_tree().create_timer(0.25).timeout
	await _flash(Color(0.6, 0.05, 0.1, 0.0), 0.5)
	player.frozen = false
	busy = false

func _on_day_completed() -> void:
	if busy:
		return
	busy = true
	player.frozen = true
	message_label.text = ""
	message_timer = 0.0
	await _flash(Color(0, 0, 0, 1), 0.7)
	big_label.text = "WORKING DONE"
	await get_tree().create_timer(2.0).timeout
	big_label.text = ""
	WorldState.start_new_day()
	WorldState.post_message("A NEW DAY. STILL IN THIS BUILDING.", 3.0)
	await _flash(Color(0, 0, 0, 0), 0.9)
	player.frozen = false
	busy = false

func _flash(target: Color, duration: float) -> void:
	var tween := create_tween()
	tween.tween_property(fade, "color", target, duration)
	await tween.finished
