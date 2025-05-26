extends InputOutput
class_name Inputter

func loadVisuals():
	if visualInstance: visualInstance.queue_free()
	visualInstance = preload("res://scenes/entityVisuals/input.tscn").instantiate()
	super()
