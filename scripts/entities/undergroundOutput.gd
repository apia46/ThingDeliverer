extends Underground
class_name UndergroundOutput

func loadVisuals() -> void:
	if visualInstance: visualInstance.queue_free()
	visualInstance = preload("res://scenes/entityVisuals/undergroundOutput.tscn").instantiate()
	super()
