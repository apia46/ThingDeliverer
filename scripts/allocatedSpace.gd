extends RefCounted
class_name AllocatedSpace

const ALLOCATED_SPACE_CONNECTION_PROBABILITY = 0.18

var position:Vector2i
var chunk:Chunk
var map:Node2D

var unlocked:bool = false

var isUpConnected:U.BOOL3
var upConnect:AllocatedSpace
var isLeftConnected:U.BOOL3
var leftConnect:AllocatedSpace

var isRightConnected:U.BOOL3 = U.BOOL3.UNKNOWN
var rightConnect:AllocatedSpace
var isDownConnected:U.BOOL3 = U.BOOL3.UNKNOWN
var downConnect:AllocatedSpace

func _init(_position:Vector2i, _chunk:Chunk) -> void:
	position = _position
	chunk = _chunk
	map = chunk.get_node("/root/game/map")
	isLeftConnected = U.toBool3(randf() < ALLOCATED_SPACE_CONNECTION_PROBABILITY)
	isUpConnected = U.toBool3(randf() < ALLOCATED_SPACE_CONNECTION_PROBABILITY)

func getAllocatedSpaceRelative(difference:Vector2i) -> AllocatedSpace:
	var posChunk:Vector2i = position + difference
	if Rect2i(0, 0, Scene.ALLOCATED_SPACES_PER_CHUNK, Scene.ALLOCATED_SPACES_PER_CHUNK).has_point(posChunk):
		return chunk.allocatedSpaces.get(v2toindex(posChunk))
	else: return chunk.scene.getChunk(chunk.chunkPos + Vector2i(floor(posChunk/float(Scene.ALLOCATED_SPACES_PER_CHUNK)))).allocatedSpaces.get(v2toindex(U.v2iposmod(posChunk, Scene.ALLOCATED_SPACES_PER_CHUNK)))

static func v2toindex(vector:Vector2i) -> int: return vector.y * 4 + vector.x

func updateConnections() -> void:
	if !isRightConnected:
		var space = getAllocatedSpaceRelative(Vector2i(1,0))
		if space and U.toBool(space.isLeftConnected):
			isRightConnected = U.BOOL3.TRUE
			rightConnect = space
	if !isDownConnected:
		var space = getAllocatedSpaceRelative(Vector2i(0,1))
		if space and U.toBool(space.isUpConnected):
			isDownConnected = U.BOOL3.TRUE
			downConnect = space
	if !leftConnect:
		leftConnect = getAllocatedSpaceRelative(Vector2i(-1,0))
		leftConnect.rightConnect = self
		leftConnect.isRightConnected = isLeftConnected
		leftConnect.updateVisual()
	if !upConnect:
		upConnect = getAllocatedSpaceRelative(Vector2i(0,-1))
		upConnect.downConnect = self
		upConnect.isDownConnected = isUpConnected
		upConnect.updateVisual()
	updateVisual()

func updateVisual() -> void:
	if unlocked: map.setAllocatedSpaceMap(chunk.chunkPos * 4 + position, Vector2i(U.b3toint(isLeftConnected)|int(leftConnect.unlocked) + 2,U.b3toint(isUpConnected)|int(!upConnect.unlocked)))
	else: map.setAllocatedSpaceMap(chunk.chunkPos * 4 + position, Vector2i(U.b3toint(isLeftConnected),U.b3toint(isUpConnected)))
	
	if unlocked: chunk.floorTiles.set_cell_item(Vector3i(position.x, 0, position.y), 0)

func unlock() -> void:
	unlocked = true
	if U.toBool(isUpConnected) and !upConnect.unlocked: upConnect.unlock()
	if U.toBool(isRightConnected) and !rightConnect.unlocked: rightConnect.unlock()
	if U.toBool(isDownConnected) and !downConnect.unlocked: downConnect.unlock()
	if U.toBool(isLeftConnected) and !leftConnect.unlocked: leftConnect.unlock()
	updateVisual()
