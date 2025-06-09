extends Node3D
class_name Chunk

@onready var scene:Scene = $"/root/game/scene"

var entities:Dictionary[Vector2i, Entity]
var spaces:Array[Space]
var chunkPos:Vector2i

func _ready() -> void:
	for y in 4: for x in 4:
		spaces.append(Space.new(Vector2i(x,y), self))
	for space in spaces: 
		space.updateConnections()

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

func newEntity(type:Variant, pos:Vector2i, rot:U.ROTATIONS) -> Entity:
	var entity:Entity = entities.get(pos)
	if entity: removeEntity(pos)
	entity = type.new(self, pos, rot)
	entities[pos] = entity
	entity.ready(visible)
	return entity

func removeEntity(pos:Vector2i) -> Entity:
	var entity:Entity = entities.get(pos)
	if entities.erase(pos):
		entity.delete()
		return entity
	return null
