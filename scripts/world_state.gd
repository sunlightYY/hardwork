extends Node

signal phase_changed(is_night: bool)
signal resentment_changed(value: float)
signal tasks_changed(done: int, total: int)
signal message_posted(text: String, seconds: float)
signal day_completed
signal player_caught

const BASE_RISE := 0.010
const SCOLD_GAIN := 0.05
const CAUGHT_GAIN := 0.10
const WASH_RELIEF := 0.10
const TASK_RELIEF := 0.12
const WASH_COOLDOWN := 8.0
const TASK_BASE := 3
const TASK_MAX := 6
const MONSTERS_PER_TIER := [0, 1, 2, 3]

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
var tasks_done := 0
var tasks_total := TASK_BASE
var wash_cooldown := 0.0
var running := true

func _ready() -> void:
	_setup_inputs()

func _process(delta: float) -> void:
	if not running:
		return
	wash_cooldown = maxf(0.0, wash_cooldown - delta)
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
	phase_changed.emit(is_night)

func wash_face() -> void:
	if wash_cooldown > 0.0:
		post_message("THE MIRROR IS STILL WET", 1.5)
		return
	wash_cooldown = WASH_COOLDOWN
	_set_resentment(resentment - WASH_RELIEF)
	post_message("YOU SPLASH WATER ON YOUR FACE", 2.0)

func get_scolded() -> void:
	_set_resentment(resentment + SCOLD_GAIN)
	tasks_total = mini(tasks_total + 1, TASK_MAX)
	tasks_changed.emit(tasks_done, tasks_total)
	post_message("SUPERVISOR: STOP WANDERING AROUND", 2.5)

func complete_task() -> void:
	tasks_done += 1
	_set_resentment(resentment - TASK_RELIEF)
	tasks_changed.emit(tasks_done, tasks_total)
	if tasks_done >= tasks_total:
		day_completed.emit()

func caught() -> void:
	_set_resentment(resentment + CAUGHT_GAIN)
	post_message("SOMETHING DRAGGED YOU BACK", 2.0)
	player_caught.emit()

func start_new_day() -> void:
	tasks_done = 0
	tasks_total = TASK_BASE
	tasks_changed.emit(tasks_done, tasks_total)

func post_message(text: String, seconds: float) -> void:
	message_posted.emit(text, seconds)

func _set_resentment(value: float) -> void:
	resentment = clampf(value, 0.0, 1.0)
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
