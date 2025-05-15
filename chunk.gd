extends MeshInstance3D
class_name Chunk

const CUBE:PackedScene = preload("res://cube.tscn")

var entities:Dictionary[Vector2i, MeshInstance3D]
var chunkPos:Vector2i

func setProperties(_chunkPos:Vector2i) -> Chunk:
	chunkPos = _chunkPos
	position = Vector3(chunkPos.x * 32, 0, chunkPos.y * 32)
	return self

func newEntity(pos:Vector2i) -> void:
	if pos in entities: return
	var entity = CUBE.instantiate()
	entities[pos] = entity
	entity.position = U.fxz(Vector2(pos) + Vector2(0.5, 0.5))
	add_child(entity)
