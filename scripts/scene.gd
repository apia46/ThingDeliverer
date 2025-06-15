extends Node3D
class_name Scene

const DEBUG_VISUAL = preload("res://scenes/debugVisual.tscn");
const SPACE_SIZE:int = 8

@onready var game:Game = $"/root/game"
@onready var items:Items = $"items"
@onready var spaceVisuals:SpaceVisuals = $"spaceVisuals"

var entities:Dictionary[Vector2i, Entity]
var spaces:Dictionary[Vector2i, Space]

func getEntity(pos:Vector2i) -> Entity:
	if game.isDebug: newDebugVisual(pos, Color(1, 0, 0.4))
	var entity = entities.get(pos)
	if entity: return entity
	return null

func placeEntity(type:Variant, pos:Vector2i, rot:U.ROTATIONS) -> Entity:
	var entity:Entity = entities.get(pos)
	if entity: deleteEntity(pos)
	entity = type.new(self, pos, rot)
	entities[pos] = entity
	entity.ready(visible)
	return entity

func deleteEntity(pos:Vector2i) -> Entity:
	var entity:Entity = entities.get(pos)
	if entities.erase(pos):
		entity.delete()
		return entity
	return null

func getSpace(pos:Vector2i) -> Space:
	var space = spaces.get(Vector2i(floor(Vector2(pos) / SPACE_SIZE)))
	if !space: return null
	return space

func newSpace(pos:Vector2i) -> Space:
	if getSpace(pos): return getSpace(pos)
	var space = Space.new(pos, self)
	spaces[pos] = space
	return space

func newDebugVisual(pos:Vector2i, color:Color) -> void:
	if !game.isDebug: return
	var visual:MeshInstance3D = DEBUG_VISUAL.instantiate()
	add_child(visual)
	visual.position = U.fxz(pos) + U.v3(0.5)
	visual.get_active_material(0).albedo_color = color
	var tween = create_tween()
	tween.tween_property(visual.get_active_material(0), "albedo_color", color - Color(0, 0, 0, 1), 0.5)
	tween.tween_callback(visual.queue_free)
