extends Entity
class_name ThroughpathReference

var throughpath:Throughpath

func loadVisuals() -> void:
	if game.isDebug:
		if visualInstance: visualInstance.queue_free()
		visualInstance = preload("res://scenes/debugVisual.tscn").instantiate()
	super()

func delete() -> void:
	throughpath.delete()
