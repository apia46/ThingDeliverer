extends Entity
class_name Belt

const BELT_STRAIGHT:PackedScene = preload("res://scenes/entityVisuals/beltStraight.tscn")
const BELT_CCW:PackedScene = preload("res://scenes/entityVisuals/beltCCW.tscn")
const BELT_CW:PackedScene = preload("res://scenes/entityVisuals/beltCW.tscn")

func loadVisuals() -> void:
	if getEntityRelative(U.rotate(Vector2i(-1,0), rotation)):
		visualInstance = BELT_CW.instantiate()
	elif getEntityRelative(U.rotate(Vector2i(1,0), rotation)):
		visualInstance = BELT_CCW.instantiate()
	else: visualInstance = BELT_STRAIGHT.instantiate()
	visualInstance.get_active_material(1).albedo_color = Color(1,1,0)
	visualInstance.get_active_material(1).emission = Color(1,1,0)
	super()
