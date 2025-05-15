extends Node
class_name U

# to swizzled
static func xz(vector:Vector3) -> Vector2: return Vector2(vector.x, vector.z)
# from swizzled
static func fxz(vector:Vector2) -> Vector3: return Vector3(vector.x, 0, vector.y)
# rect2i from corners
static func rectCorners(start:Vector2i, end:Vector2i) -> Rect2i: return Rect2i(start, end - start)

static func v2iposmod(vector:Vector2i,by) -> Vector2i:
	if by is Vector2i:
		return Vector2i(posmod(vector.x, by.x), posmod(vector.y, by.y))
	elif by is int:
		return Vector2i(posmod(vector.x, by), posmod(vector.y, by))
	else: assert(false)
	return Vector2i() # unreachable
