extends Node2D

var level: Node2D
var player: Node2D
var camera: Camera2D
var tint: ColorRect
var fade: ColorRect
var floor_label: Label
var hand_label: Label
var phase_label: Label
var watch_label: Label
var hint_label: Label
var message_label: Label
var big_label: Label

var message_timer := 0.0
var busy := false

func _ready() -> void:
	level = $Level
	player = level.player
	_build_tint()
	_build_camera()
	_build_hud()

	WorldState.message_posted.connect(_on_message)
	WorldState.floor_changed.connect(_on_floor_changed)
	WorldState.inventory_changed.connect(_on_inventory_changed)
	WorldState.run_completed.connect(_on_run_completed)
	level.floor_finished.connect(_on_floor_finished)

	_on_floor_changed(WorldState.floor_number)
	_on_inventory_changed(WorldState.held)
	_intro()

func _process(delta: float) -> void:
	_paint_tint(delta)
	_paint_hud(delta)
	_layout()

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

	hint_label.text = "SHIFT  SWITCH SPACE        E  HAND IT OVER"

	if message_timer > 0.0:
		message_timer -= delta
		if message_timer <= 0.0:
			message_label.text = ""

func _layout() -> void:
	var vp := get_viewport_rect().size
	phase_label.position = Vector2(vp.x - 32.0 - phase_label.size.x, 24.0)
	watch_label.position = Vector2(vp.x - 32.0 - watch_label.size.x, 58.0)
	message_label.position = Vector2((vp.x - message_label.size.x) * 0.5, 140.0)
	hint_label.position = Vector2((vp.x - hint_label.size.x) * 0.5, vp.y - 58.0)
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
	camera = Camera2D.new()
	camera.limit_left = 0
	camera.limit_right = 1280
	camera.limit_top = 0
	camera.limit_bottom = 720
	camera.global_position = Vector2(640, 360)
	add_child(camera)
	camera.make_current()

func _build_hud() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 10
	add_child(layer)

	fade = ColorRect.new()
	fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade.color = Color(0, 0, 0, 0)
	layer.add_child(fade)

	floor_label = _make_label(34, Color("e8edf4"))
	floor_label.position = Vector2(30, 22)
	layer.add_child(floor_label)

	hand_label = _make_label(22, Color("b9c6d6"))
	hand_label.position = Vector2(32, 70)
	layer.add_child(hand_label)

	phase_label = _make_label(24, Color("8fa3b8"))
	layer.add_child(phase_label)

	watch_label = _make_label(22, Color("d9c8ff"))
	watch_label.visible = false
	layer.add_child(watch_label)

	message_label = _make_label(26, Color("ffd9a0"))
	layer.add_child(message_label)

	hint_label = _make_label(20, Color("9fb0c2"))
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

func _on_message(text: String, seconds: float) -> void:
	message_label.text = text
	message_timer = seconds
	_layout()

func _on_floor_changed(value: int) -> void:
	floor_label.text = "FLOOR  %d" % maxi(value, 1)

func _on_inventory_changed(held: String) -> void:
	hand_label.text = "IN HAND:  " + (player.item_label(held) if held != "" else "---")

func _on_floor_finished() -> void:
	if busy:
		return
	busy = true
	player.frozen = true
	await _flash(Color(0, 0, 0, 1), 0.45)
	WorldState.descend()
	if WorldState.running:
		level.start_floor()
		await _flash(Color(0, 0, 0, 0), 0.5)
		player.frozen = false
	busy = false

func _on_run_completed() -> void:
	busy = true
	player.frozen = true
	big_label.text = "OUT OF THE BUILDING"
	await get_tree().create_timer(2.0).timeout

func _intro() -> void:
	player.sitting = true
	player.frozen = true
	WorldState.post_message("28TH FLOOR. THE LIFT IS DOWN.", 2.4)
	await get_tree().create_timer(2.2).timeout
	WorldState.toggle_phase()
	await get_tree().create_timer(1.0).timeout
	WorldState.toggle_phase()
	WorldState.post_message("SOMETHING ON YOUR WRIST CLICKED.", 3.0)
	player.frozen = false

func _flash(target: Color, duration: float) -> void:
	var tween := create_tween()
	tween.tween_property(fade, "color", target, duration)
	await tween.finished
