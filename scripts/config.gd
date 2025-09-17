extends PanelContainer

@onready var menu:Menu = get_node("/root/menu")

var showTutorial:bool = true
var uiScale:float = 1

func _showTutorial_toggle(toggled_on:bool):
	showTutorial = toggled_on
	if toggled_on:
		%showTutorial.get_child(0).text = "   [color=#9CDCFE] show_tutorial[/color]: [color=#4FC1FF] true[/color]"
	else:
		%showTutorial.get_child(0).text = "   [color=#9CDCFE] show_tutorial[/color]: [color=#4FC1FF]false[/color]"

func _uiScale_change(value:float):
	%uiScale.get_child(0).text = "   [color=#9CDCFE] ui_scale[/color]: [color=#4FC1FF]%s[/color]" % [str(int(%uiScale.get_child(1).value)).lpad(3) + "%"]
	menu.scale = U.v2(%uiScale.get_child(1).value * 0.01)
	uiScale = %uiScale.get_child(1).value * 0.01
