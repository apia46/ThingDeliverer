extends Node3D
class_name Scene

const CHUNK = preload("res://scenes/chunk.tscn");
const DEBUG_VISUAL = preload("res://scenes/debugVisual.tscn");
const CHUNK_SIZE:int = 32

@onready var game:Game = $"/root/game"
var chunks:Array[Chunk] = []
var chunkPositions:Array[Vector2i] = []

func loadChunk(chunkPos:Vector2i) -> void:
	var index:int = chunkPositions.find(chunkPos)
	if index == -1:
		var chunk:Chunk = CHUNK.instantiate().setProperties(chunkPos)
		chunks.append(chunk)
		chunkPositions.append(chunkPos)
		add_child(chunk)
	else: chunks[index].loadVisuals()

func unloadChunk(chunkPos:Vector2i) -> void:
	chunks[chunkPositions.find(chunkPos)].unloadVisuals()

func getChunk(chunkPos:Vector2i) -> Chunk:
	return chunks[chunkPositions.find(chunkPos)]

func newDebugVisual(pos:Vector2i, color:Color) -> void:
	@warning_ignore("unreachable_code") return
	var visual:MeshInstance3D = DEBUG_VISUAL.instantiate()
	add_child(visual)
	visual.position = U.fxz(pos) + U.v3(0.5)
	visual.get_active_material(0).albedo_color = color
	var tween = create_tween()
	tween.tween_property(visual.get_active_material(0), "albedo_color", color - Color(0, 0, 0, 1), 0.5)
	tween.tween_callback(visual.queue_free)
