extends Underground
class_name UndergroundInput

func loadVisuals() -> void:
	if visualInstance: visualInstance.queue_free()
	visualInstance = preload("res://scenes/entityVisuals/undergroundInput.tscn").instantiate()
	super()
