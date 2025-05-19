extends MeshInstance3D
class_name Chunk

const CUBE:PackedScene = preload("res://scenes/cube.tscn")

var entities:Dictionary[Vector2i, MeshInstance3D]
var chunkPos:Vector2i

func setProperties(_chunkPos:Vector2i) -> Chunk:
	chunkPos = _chunkPos
	position = Vector3(chunkPos.x * 32, 0, chunkPos.y * 32)
	return self

func newEntity(pos:Vector2i) -> Variant:
	var entity:Variant = entities.get(pos)
	if entity: return entity
	entity = CUBE.instantiate()
	entities[pos] = entity
	entity.position = U.fxz(pos) + Vector3(0.5, 0.5, 0.5)
	add_child(entity)
	return entity

func removeEntity(pos:Vector2i) -> Variant:
	var entity:Variant = entities.get(pos)
	if entities.erase(pos):
		entity.queue_free()
		return entity
	return null
