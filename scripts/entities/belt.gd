extends Entity
class_name Belt

const BELT_STRAIGHT:PackedScene = preload("res://scenes/entityVisuals/beltStraight.tscn")
const BELT_CCW:PackedScene = preload("res://scenes/entityVisuals/beltCCW.tscn")
const BELT_CW:PackedScene = preload("res://scenes/entityVisuals/beltCW.tscn")

const YELLOW = Color(0xFFD800FF)

func ready(visible) -> void:
	super(visible)

func loadVisuals(recurse:=true) -> void:
	if visualInstance: visualInstance.queue_free()
	if facingThis(getEntityRelative(U.rotate(Vector2i(-1,0), rotation), true)):
		visualInstance = BELT_CCW.instantiate()
	elif facingThis(getEntityRelative(U.rotate(Vector2i(1,0), rotation), true)):
		visualInstance = BELT_CW.instantiate()
	else: visualInstance = BELT_STRAIGHT.instantiate()
	visualInstance.get_active_material(1).albedo_color = YELLOW
	visualInstance.get_active_material(1).emission = YELLOW
	if recurse: updateEntityVisuals(getEntityRelative(U.rotate(Vector2i(0,-1), rotation), true))
	super()

func unloadVisuals() -> void:
	updateEntityVisuals(getEntityRelative(U.rotate(Vector2i(0,-1), rotation), true))
	super()

func facingThis(entity:Entity) -> bool:
	if !entity: return false
	scene.newDebugVisual(entity.positionAbsolute() + U.rotate(Vector2i(0,-1), entity.rotation), Color(0, 1, 0.4))
	return entity.positionAbsolute() + U.rotate(Vector2i(0,-1), entity.rotation) == positionAbsolute() and entity is Belt or entity is Inputter
