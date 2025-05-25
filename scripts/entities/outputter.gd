extends PopupThing
class_name Outputter

func loadVisuals(_recurse:=true):
	if visualInstance: visualInstance.queue_free()
	visualInstance = preload("res://scenes/entityVisuals/output.tscn").instantiate()
	super()
