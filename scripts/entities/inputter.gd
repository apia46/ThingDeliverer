extends InputOutput
class_name Inputter

var itemDisplay:Items.Display

func loadVisuals():
	if visualInstance: visualInstance.queue_free()
	visualInstance = preload("res://scenes/entityVisuals/input.tscn").instantiate()
	
	if pathPoint and pathPoint.complete and !itemDisplay: itemDisplay = scene.items.addDisplay(Items.TYPES.BOX, position, rotation)
	elif itemDisplay: itemDisplay = scene.items.removeDisplay(itemDisplay)
	super()
