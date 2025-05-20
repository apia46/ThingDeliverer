extends MeshInstance3D
class_name Chunk

const BELT:PackedScene = preload("res://scenes/cube.tscn")

var entities:Dictionary[Vector2i, MeshInstance3D]
var chunkPos:Vector2i

func setProperties(_chunkPos:Vector2i) -> Chunk:
	chunkPos = _chunkPos
	position = U.v3fxz(chunkPos.x * 32, chunkPos.y * 32)
	return self

func newEntity(pos:Vector2i, rot:int) -> Variant:
	var entity:Variant = entities.get(pos)
	if entity: return entity
	entity = BELT.instantiate()
	entities[pos] = entity
	entity.position = U.fxz(pos) + U.v3(0.5)
	entity.rotation.y = deg_to_rad(rot)
	entity.get_active_material(1).albedo_color = Color(1,0,0)
	entity.get_active_material(1).emission = Color(1,0,0)
	add_child(entity)
	return entity

func removeEntity(pos:Vector2i) -> Variant:
	var entity:Variant = entities.get(pos)
	if entities.erase(pos):
		entity.queue_free()
		return entity
	return null
