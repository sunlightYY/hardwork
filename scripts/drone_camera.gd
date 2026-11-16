extends Camera2D

const MID_Y := 360.0
const BASE_ZOOM := 1.0
const SWAY := 6.0

const SWING_TIME := 0.72
const SWING_ANGLE := 0.24
const SWING_ZOOM := 0.92
const SWING_SQUASH := 0.95

var target: Node2D
var time := 0.0
var swing := 1.0
var swing_sign := 1.0

func _ready() -> void:
	position_smoothing_enabled = false
	global_position = Vector2(target.global_position.x, MID_Y)
	zoom = Vector2(BASE_ZOOM, BASE_ZOOM)
	make_current()

func trigger(sign_value: float) -> void:
	swing_sign = sign_value
	swing = 0.0

func snap_to(pos: Vector2) -> void:
	global_position = Vector2(pos.x, MID_Y)
	rotation = 0.0
	zoom = Vector2(BASE_ZOOM, BASE_ZOOM)

func set_bounds(left: float, right: float) -> void:
	limit_left = int(left)
	limit_right = int(right)
	limit_top = 0
	limit_bottom = 720

func _process(delta: float) -> void:
	if target == null:
		return
	time += delta

	var goal_x: float = target.global_position.x + sin(time * 0.7) * SWAY
	global_position.x = lerpf(global_position.x, goal_x, 1.0 - exp(-4.0 * delta))
	global_position.y = MID_Y

	if swing < 1.0:
		swing = minf(1.0, swing + delta / SWING_TIME)
		var wave := sin(PI * swing)
		rotation = SWING_ANGLE * swing_sign * wave
		var pulled := BASE_ZOOM * (1.0 - (1.0 - SWING_ZOOM) * wave)
		zoom = Vector2(pulled, pulled * (1.0 - (1.0 - SWING_SQUASH) * wave))
	else:
		rotation = lerp_angle(rotation, 0.0, 1.0 - exp(-8.0 * delta))
		zoom = zoom.lerp(Vector2(BASE_ZOOM, BASE_ZOOM), 1.0 - exp(-8.0 * delta))
