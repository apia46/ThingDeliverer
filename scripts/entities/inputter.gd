extends PopupThing
class_name Inputter

func loadVisuals(_recurse:=true):
	if visualInstance: visualInstance.queue_free()
	visualInstance = preload("res://scenes/entityVisuals/input.tscn").instantiate()
	super()
