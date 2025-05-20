class_name U

# to swizzled
static func xz(vector:Vector3) -> Vector2: return Vector2(vector.x, vector.z)
# from swizzled
static func fxz(vector:Vector2) -> Vector3: return Vector3(vector.x, 0, vector.y)
static func v3fxz(x:float,z:float) -> Vector3: return Vector3(x, 0, z)
# rect2i from corners
static func rectCorners(start:Vector2i, end:Vector2i) -> Rect2i: return Rect2i(start, end - start)

static func v2iposmod(vector:Vector2i,by) -> Vector2i: return (vector % by + (by if by is Vector2i else Vector2i(by, by))) % by

static func v2(value:float) -> Vector2: return Vector2(value, value)

static func v3(value:float) -> Vector3: return Vector3(value, value, value)
