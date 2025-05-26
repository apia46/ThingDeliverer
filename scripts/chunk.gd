extends MeshInstance3D
class_name Chunk

@onready var scene:Scene = $"/root/game/scene"

var entities:Dictionary[Vector2i, Entity]
var chunkPos:Vector2i

func setProperties(_chunkPos:Vector2i) -> Chunk:
	chunkPos = _chunkPos
	position = U.v3fxz(chunkPos.x * 32, chunkPos.y * 32)
	return self

func loadVisuals() -> void:
	if !visible: for entity:Entity in entities.values(): entity.loadVisuals()
	visible = true

func unloadVisuals() -> void:
	if visible: for entity:Entity in entities.values(): entity.unloadVisuals()
	visible = false

func newEntity(type:Variant, pos:Vector2i, rot:U.ROTATIONS, authority:=false) -> Entity:
	var entity:Entity = entities.get(pos)
	if entity and !removeEntity(pos, authority): return entities[pos]
	entity = type.new(self, pos, rot)
	entities[pos] = entity
	entity.ready(visible)
	return entity

func removeEntity(pos:Vector2i, authority:=false) -> Entity:
	var entity:Entity = entities.get(pos)
	if authority or entity is not InputOutput and entities.erase(pos):
		entity.delete()
		return entity
	return null
