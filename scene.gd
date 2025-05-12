extends Node3D
const CHUNK = preload("res://chunk.tscn");

var chunks:Array[Chunk]

func loadChunk(chunkPos:Vector2) -> void:
	var chunk = CHUNK.instantiate()
	chunk.position = Vector3(chunkPos.x * 32, 0, chunkPos.y * 32)
	add_child(chunk)
