extends Entity
class_name Belt

const BELT_STRAIGHT:PackedScene = preload("res://scenes/entityVisuals/beltStraight.tscn")
const BELT_CCW:PackedScene = preload("res://scenes/entityVisuals/beltCCW.tscn")
const BELT_CW:PackedScene = preload("res://scenes/entityVisuals/beltCW.tscn")

const DEACTIVATED_COLOR = Color(0x0D063AFF)
const ACTIVATED_COLOR = Color(0xFFD800FF)

var pathPoint:PathPoint

var currentlyDisplayedPreviousDirection:U.ROTATIONS
var previousDirection:U.ROTATIONS

var itemDisplay:Items.Display

func ready(visible) -> void:
	super(visible)
	checkPrevious(true)

func checkPrevious(isNew:bool=false) -> void:
	var previousEntity:Entity = facingThis(getEntityRelative(U.rotate(Vector2i(0,1), rotation), true))
	previousDirection = U.ROTATIONS.DOWN
	if !previousEntity:
		previousEntity = facingThis(getEntityRelative(U.rotate(Vector2i(1,0), rotation), true))
		previousDirection = U.ROTATIONS.RIGHT
	if !previousEntity:
		previousEntity = facingThis(getEntityRelative(U.rotate(Vector2i(-1, 0), rotation), true))
		previousDirection = U.ROTATIONS.LEFT
	if !previousEntity: previousDirection = U.ROTATIONS.DOWN
	
	if previousEntity:
		var previousPathPoint:PathPoint = previousEntity.getPathPoint(positionAbsolute())
		if previousPathPoint:
			if pathPoint and pathPoint.isBefore(previousPathPoint): # path cuts itself off
				pathPoint = null
				updateNext()
			elif !pathPoint or !pathPoint.isDirectlyAfter(previousPathPoint): # no updates needed if so
				pathPoint = previousPathPoint.generateNext(previousEntity)
				updateNext()
		else:
			if pathPoint:
				pathPoint = null
				updateNext()
			else:
				pathPoint = null
				if isNew: updateNext()
	else:
		if pathPoint:
			pathPoint = null
			updateNext()
		else:
			pathPoint = null
			if isNew: updateNext()
	
	loadVisuals()

# direction changes
func loadVisuals() -> void:
	#print(str(!visualInstance) + str(currentlyDisplayedPreviousDirection) + str(previousDirection))
	var changingInstance:bool = !visualInstance or currentlyDisplayedPreviousDirection != previousDirection
	if changingInstance:
		if visualInstance: visualInstance.queue_free()
		match previousDirection:
			U.ROTATIONS.LEFT: visualInstance = BELT_CCW.instantiate()
			U.ROTATIONS.RIGHT: visualInstance = BELT_CW.instantiate()
			_: visualInstance = BELT_STRAIGHT.instantiate()
	
	if pathPoint and pathPoint.complete:
		visualInstance.get_active_material(1).albedo_color = ACTIVATED_COLOR
		visualInstance.get_active_material(1).emission = ACTIVATED_COLOR
		if !itemDisplay: itemDisplay = chunk.scene.items.addDisplay(Items.TYPES.BOX, positionAbsolute(), rotation)
	else:
		visualInstance.get_active_material(1).albedo_color = DEACTIVATED_COLOR
		visualInstance.get_active_material(1).emission = DEACTIVATED_COLOR
		if itemDisplay: itemDisplay = chunk.scene.items.removeDisplay(itemDisplay)
	
	if game.isDebug:
		visualInstance.get_node("debugText").visible = !!pathPoint
		if pathPoint: visualInstance.get_node("debugText").text = str(pathPoint.path) + "-" + str(pathPoint.point)
	
	if changingInstance: super()
	currentlyDisplayedPreviousDirection = previousDirection

func delete() -> void:
	if pathPoint: pathPoint.previousEntity.getPathPoint(positionAbsolute()).pathUncomplete(pathPoint.previousEntity)
	if itemDisplay: chunk.scene.items.removeDisplay(itemDisplay)
	updateNext()
	super()

func facingThis(entity:Entity) -> Entity: # TODO:refactor
	if !entity: return null
	scene.newDebugVisual(entity.positionAbsolute() + U.rotate(Vector2i(0,-1), entity.rotation), Color(0, 1, 0.4))
	return entity if (entity is Belt or entity is Inputter) and entity.positionAbsolute() + U.rotate(Vector2i(0,-1), entity.rotation) == positionAbsolute() else null

func updateNext():
	var next:Entity = getEntityRelative(U.rotate(Vector2i(0,-1), rotation), true)
	if next is Belt or next is Outputter: next.checkPrevious()
