extends Node3D
class_name Scene

const CHUNK = preload("res://scenes/chunk.tscn");
const DEBUG_VISUAL = preload("res://scenes/debugVisual.tscn");
const CHUNK_SIZE:int = 32
const SPACE_SIZE:int = 8
@warning_ignore("integer_division") const SPACES_PER_CHUNK:int = CHUNK_SIZE / SPACE_SIZE

@onready var game:Game = $"/root/game"
@onready var items:Items = $"items"
var chunks:Array[Chunk] = []
var unlockedSpaces:Array[Space] = []
var chunkPositions:Array[Vector2i] = []
var loadedChunks:int = 0

func loadChunk(chunkPos:Vector2i) -> void:
	var index:int = chunkPositions.find(chunkPos)
	if index == -1:
		var chunk:Chunk = CHUNK.instantiate().setProperties(chunkPos)
		chunks.append(chunk)
		chunkPositions.append(chunkPos)
		add_child(chunk)
	else: chunks[index].loadVisuals()
	loadedChunks += 1

func unloadChunk(chunkPos:Vector2i) -> void:
	chunks[chunkPositions.find(chunkPos)].unloadVisuals()
	loadedChunks -= 1

func getChunk(chunkPos:Vector2i) -> Chunk:
	return chunks[chunkPositions.find(chunkPos)]

func getEntity(pos:Vector2i) -> Entity:
	if game.isDebug: newDebugVisual(pos, Color(1, 0, 0.4))
	return getChunk(floor(Vector2(pos) / CHUNK_SIZE)).entities.get(U.v2iposmod(pos, Scene.CHUNK_SIZE))

func placeEntity(type:Variant, pos:Vector2i, rot:U.ROTATIONS) -> Entity:
	return getChunk(floor(Vector2(pos) / CHUNK_SIZE)).newEntity(type, U.v2iposmod(pos, Scene.CHUNK_SIZE), rot)

func deleteEntity(pos:Vector2i) -> void:
	getChunk(floor(Vector2(pos) / CHUNK_SIZE)).removeEntity(U.v2iposmod(pos, Scene.CHUNK_SIZE))

func getSpace(pos:Vector2i) -> Space:
	return getChunk(floor(Vector2(pos) / CHUNK_SIZE)).spaces[U.v2iunwrap(U.v2iposmod(floor(Vector2(pos) / SPACE_SIZE), Scene.SPACES_PER_CHUNK), Scene.SPACES_PER_CHUNK)]

func newDebugVisual(pos:Vector2i, color:Color) -> void:
	if !game.isDebug: return
	var visual:MeshInstance3D = DEBUG_VISUAL.instantiate()
	add_child(visual)
	visual.position = U.fxz(pos) + U.v3(0.5)
	visual.get_active_material(0).albedo_color = color
	var tween = create_tween()
	tween.tween_property(visual.get_active_material(0), "albedo_color", color - Color(0, 0, 0, 1), 0.5)
	tween.tween_callback(visual.queue_free)
