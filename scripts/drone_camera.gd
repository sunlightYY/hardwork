extends Camera2D

const FOLLOW_OFFSET := Vector2(0, -60)
const SWAY := Vector2(6.0, 4.0)

const SWING_TIME := 0.7
const SWING_ANGLE := 0.21
const SWING_ZOOM := 0.93
const SWING_SQUASH := 0.955
const TURN_TRIGGER := 0.5

var target: Node2D
var time := 0.0
var swing := 1.0
var swing_sign := 1.0
var last_dir := Vector2.ZERO

func _ready() -> void:
	position_smoothing_enabled = false
	global_position = target.global_position + FOLLOW_OFFSET
	make_current()

func _process(delta: float) -> void:
	if target == null:
		return
	time += delta

	var dir: Vector2 = target.dir
	if dir != Vector2.ZERO:
		if last_dir != Vector2.ZERO and swing >= 1.0 and last_dir.dot(dir) < TURN_TRIGGER:
			var cross := last_dir.x * dir.y - last_dir.y * dir.x
			swing_sign = -signf(cross)
			swing = 0.0
		last_dir = dir

	var sway := Vector2(sin(time * 0.7) * SWAY.x, cos(time * 0.53) * SWAY.y)
	var goal: Vector2 = target.global_position + FOLLOW_OFFSET + sway
	global_position = global_position.lerp(goal, 1.0 - exp(-3.2 * delta))

	if swing < 1.0:
		swing = minf(1.0, swing + delta / SWING_TIME)
		var wave := sin(PI * swing)
		rotation = SWING_ANGLE * swing_sign * wave
		var pulled := 1.0 - (1.0 - SWING_ZOOM) * wave
		zoom = Vector2(pulled, pulled * (1.0 - (1.0 - SWING_SQUASH) * wave))
	else:
		rotation = lerp_angle(rotation, 0.0, 1.0 - exp(-8.0 * delta))
		zoom = zoom.lerp(Vector2.ONE, 1.0 - exp(-8.0 * delta))
