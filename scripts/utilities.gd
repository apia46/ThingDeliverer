class_name U

# to swizzled
static func xz(vector:Vector3) -> Vector2: return Vector2(vector.x, vector.z)
# from swizzled
static func fxz(vector:Vector2) -> Vector3: return Vector3(vector.x, 0, vector.y)
static func v3fxz(x:float,z:float) -> Vector3: return Vector3(x, 0, z)
# rect2i from corners
static func rectCorners(start:Vector2i, end:Vector2i) -> Rect2i: return Rect2i(start, end - start)

static func iposmod(num:int, by:int) -> int: return (num % by + by) % by
static func v2iposmod(vector:Vector2i, by) -> Vector2i: return (vector % by + (by if by is Vector2i else Vector2i(by, by))) % by

static func v2(value:float) -> Vector2: return Vector2(value, value)

static func v3(value:float) -> Vector3: return Vector3(value, value, value)

const V2I_DIRECTIONS_NO_UP:Array[Vector2i] = [Vector2i(0, 1), Vector2i(1, 0), Vector2i(-1, 0)]
const V2I_DIRECTIONS:Array[Vector2i] = [Vector2i(0, 1), Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, -1)]

enum ROTATIONS {UP, RIGHT, DOWN, LEFT}
const ROTATION_NAMES:Array[String] = ["UP", "RIGHT", "DOWN", "LEFT"]
const ROTATION_RADIANS:Array[float] = [4.71238898038, 3.14159265359, 1.57079632679, 0]

static func rotToRad(rot:ROTATIONS) -> float: return ROTATION_RADIANS[rot]
static func r90(rot:ROTATIONS) -> ROTATIONS: return (rot + 1) % 4 as ROTATIONS
static func r180(rot:ROTATIONS) -> ROTATIONS: return (rot + 2) % 4 as ROTATIONS
static func r270(rot:ROTATIONS) -> ROTATIONS: return (rot + 3) % 4 as ROTATIONS

static func rNeg(rot:ROTATIONS) -> ROTATIONS: return (4 - rot if rot % 2 == 1 else rot) as ROTATIONS

static func isVertical(rot:ROTATIONS) -> bool: return rot % 2 == 0
static func isHorizontal(rot:ROTATIONS) -> bool: return rot % 2 == 1

static func rotate(vector:Vector2i, rot:ROTATIONS) -> Vector2i:
	match rot:
		ROTATIONS.UP: return vector
		ROTATIONS.RIGHT: return Vector2i(-vector.y, vector.x)
		ROTATIONS.DOWN: return Vector2i(-vector.x, -vector.y)
		_, ROTATIONS.LEFT: return Vector2i(vector.y, -vector.x)

static func rotatef(vector:Vector2, rot:ROTATIONS) -> Vector2:
	match rot:
		ROTATIONS.UP: return vector
		ROTATIONS.RIGHT: return Vector2(-vector.y, vector.x)
		ROTATIONS.DOWN: return Vector2(-vector.x, -vector.y)
		_, ROTATIONS.LEFT: return Vector2(vector.y, -vector.x)

static func v2itorot(vector:Vector2i) -> ROTATIONS:
	if vector.y > 0: return ROTATIONS.DOWN
	if vector.x > 0: return ROTATIONS.RIGHT
	if vector.y < 0: return ROTATIONS.UP
	if vector.x < 0: return ROTATIONS.LEFT
	assert(false) # two things in the same place or something like that
	return ROTATIONS.UP

enum BOOL3 {UNKNOWN, FALSE, TRUE}

static func isTrue(bool3:BOOL3) -> bool: return bool3 == BOOL3.TRUE
static func isFalse(bool3:BOOL3) -> bool: return bool3 == BOOL3.FALSE
static func isKnown(bool3:BOOL3) -> bool: return bool3 != BOOL3.UNKNOWN
static func bool3not(bool3:BOOL3) -> BOOL3: return toBool3(!isTrue(bool3))
static func toBool3(condition:Variant) -> BOOL3: return BOOL3.TRUE if condition else BOOL3.FALSE
static func bool3ToText(bool3:BOOL3): return ["?", "X", "✓"][bool3]

static func v2iunwrap(vector:Vector2i, gridSize:int) -> int:
	return vector.y * gridSize + vector.x

static func timeToText(time:float, decimals:bool=false):
	var minutes = int(time / 60)
	@warning_ignore("incompatible_ternary") var seconds = float(time - 60*minutes) if decimals else int(time - 60*minutes)
	return str(minutes).pad_zeros(2) + ":" + str(seconds).pad_zeros(2).left(6)

static func boolToText(condition:Variant): return "✓" if condition else "X"
