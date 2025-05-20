extends Entity
class_name Belt

func loadVisuals() -> void:
	visualInstance = preload("res://scenes/entityVisuals/belt.tscn").instantiate()
	visualInstance.get_active_material(1).albedo_color = Color(1,1,0)
	visualInstance.get_active_material(1).emission = Color(1,1,0)
	super()
