extends Node

signal phase_changed(is_night: bool)
signal resentment_changed(value: float)
signal message_posted(text: String, seconds: float)
signal floor_changed(value: int)
signal inventory_changed(held: String)
signal run_completed

const BASE_RISE := 0.010
const SWITCH_COST := 0.05
const ITEM_TYPES := ["gloves", "cards", "doc"]
const START_FLOOR := 28
const WATCH_REVEAL := 0.55
const MONSTERS_PER_TIER := [0, 1, 1, 2]

const TINTS := [
	Color(0.72, 0.93, 1.00),
	Color(1.00, 0.80, 0.92),
	Color(0.78, 1.00, 0.84),
	Color(0.44, 0.50, 1.00),
	Color(1.00, 0.55, 0.82),
	Color(0.48, 0.22, 0.86),
	Color(0.36, 0.05, 0.09),
	Color(0.00, 0.00, 0.00),
]

const BINDINGS := {
	"move_left": [KEY_A, KEY_LEFT],
	"move_right": [KEY_D, KEY_RIGHT],
	"move_up": [KEY_W, KEY_UP],
	"move_down": [KEY_S, KEY_DOWN],
	"crouch": [KEY_CTRL, KEY_C],
	"toggle_phase": [KEY_SHIFT],
	"interact": [KEY_E],
}

var is_night := false
var resentment := 0.0
var watch_visible := false
var floor_number := START_FLOOR
var held := ""
var request := ""
var running := true

func _ready() -> void:
	_setup_inputs()

func _process(delta: float) -> void:
	if not running:
		return
	_set_resentment(resentment + BASE_RISE * delta)

func tier() -> int:
	if resentment < 0.30:
		return 0
	if resentment < 0.60:
		return 1
	if resentment < 0.85:
		return 2
	return 3

func monster_count() -> int:
	return MONSTERS_PER_TIER[tier()]

func tint() -> Color:
	var pos := resentment * float(TINTS.size() - 1)
	var i := clampi(int(floor(pos)), 0, TINTS.size() - 1)
	var j := clampi(i + 1, 0, TINTS.size() - 1)
	return TINTS[i].lerp(TINTS[j], pos - float(i))

func toggle_phase() -> void:
	is_night = not is_night
	_set_resentment(resentment + SWITCH_COST)
	phase_changed.emit(is_night)

func roll_request() -> void:
	request = ITEM_TYPES[randi() % ITEM_TYPES.size()]

func pick_up(kind: String) -> void:
	held = kind
	inventory_changed.emit(held)

func consume() -> void:
	held = ""
	inventory_changed.emit(held)

func descend() -> void:
	floor_number -= 1
	floor_changed.emit(floor_number)
	if floor_number <= 0:
		running = false
		run_completed.emit()

func post_message(text: String, seconds: float) -> void:
	message_posted.emit(text, seconds)

func _set_resentment(value: float) -> void:
	resentment = clampf(value, 0.0, 1.0)
	if not watch_visible and resentment >= WATCH_REVEAL:
		watch_visible = true
		post_message("YOUR WATCH IS SHOWING NUMBERS", 3.0)
	resentment_changed.emit(resentment)

func _setup_inputs() -> void:
	for action in BINDINGS:
		if InputMap.has_action(action):
			InputMap.erase_action(action)
		InputMap.add_action(action)
		for key in BINDINGS[action]:
			var event := InputEventKey.new()
			event.physical_keycode = key
			InputMap.action_add_event(action, event)
