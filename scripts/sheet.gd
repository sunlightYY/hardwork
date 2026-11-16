class_name Sheet

const TILE := 48
const DIRS := ["down", "up", "left", "right"]

static func frames(texture: Texture2D) -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	for row in range(DIRS.size()):
		var dir_name: String = DIRS[row]
		for kind in ["idle", "walk"]:
			var anim_name := "%s_%s" % [kind, dir_name]
			frames.add_animation(anim_name)
			frames.set_animation_loop(anim_name, kind == "walk")
			frames.set_animation_speed(anim_name, 8.0)
			var count := 1 if kind == "idle" else 2
			for i in range(count):
				var column := 0 if kind == "idle" else i + 1
				frames.add_frame(anim_name, _cell(texture, column, row))
	frames.add_animation("sit")
	frames.set_animation_loop("sit", true)
	frames.set_animation_speed("sit", 2.0)
	for i in range(3):
		frames.add_frame("sit", _cell(texture, i, 4))
	return frames

static func dir_name(vector: Vector2) -> String:
	if absf(vector.x) > absf(vector.y):
		return "right" if vector.x > 0.0 else "left"
	return "up" if vector.y < 0.0 else "down"

static func _cell(texture: Texture2D, column: int, row: int) -> AtlasTexture:
	var cell := AtlasTexture.new()
	cell.atlas = texture
	cell.region = Rect2(column * TILE, row * TILE, TILE, TILE)
	return cell
