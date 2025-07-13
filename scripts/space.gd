extends RefCounted
class_name Space

const SPACE_CONNECTION_PROBABILITY = 0.17

var scene:Scene

var position:Vector2i

var spaceVisual:SpaceVisuals.SpaceVisual

func _init(_position:Vector2i, _scene:Scene) -> void:
	position = _position
	scene = _scene
	spaceVisual = scene.spaceVisuals.addSpaceVisual(position + Vector2i(4,4))

func getSpaceRelative(difference:Vector2i) -> Space:
	return scene.getSpace(position + difference)

# it feels weird removing this entire system
# maybe it will still be useful..?
#func updateConnections() -> void:
#	if !isRightConnected:
#		var space = getSpaceRelative(Vector2i(1,0))
#		if space and U.isTrue(space.isLeftConnected):
#			isRightConnected = U.BOOL3.TRUE
#			rightConnect = space
#	if !isDownConnected:
#		var space = getSpaceRelative(Vector2i(0,1))
#		if space and U.isTrue(space.isUpConnected):
#			isDownConnected = U.BOOL3.TRUE
#			downConnect = space
#	if !leftConnect:
#		leftConnect = getSpaceRelative(Vector2i(-1,0))
#		if leftConnect:
#			leftConnect.rightConnect = self
#			leftConnect.isRightConnected = isLeftConnected
#	if !upConnect:
#		upConnect = getSpaceRelative(Vector2i(0,-1))
#		if upConnect:
#			upConnect.downConnect = self
#			upConnect.isDownConnected = isUpConnected

#func unlock() -> void:
#	unlocked = true
#	if U.isTrue(isUpConnected) and upConnect and !upConnect.unlocked: upConnect.unlock()
#	if U.isTrue(isRightConnected) and rightConnect and !rightConnect.unlocked: rightConnect.unlock()
#	if U.isTrue(isDownConnected) and downConnect and !downConnect.unlocked: downConnect.unlock()
#	if U.isTrue(isLeftConnected) and leftConnect and !leftConnect.unlocked: leftConnect.unlock()
