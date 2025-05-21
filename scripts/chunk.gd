extends MeshInstance3D
class_name Chunk

const BELT:PackedScene = preload("res://scenes/entityVisuals/belt.tscn")

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

func newEntity(pos:Vector2i, rot:U.ROTATIONS) -> Entity:
	if pos in entities: removeEntity(pos)
	var entity:Entity = Belt.new(self, pos, rot)
	entities[pos] = entity
	if visible: entity.loadVisuals()
	return entity

func removeEntity(pos:Vector2i) -> Entity:
	var entity:Entity = entities.get(pos)
	if entities.erase(pos):
		entity.unloadVisuals()
		return entity
	return null
