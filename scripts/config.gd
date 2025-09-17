extends PanelContainer

@onready var menu:Menu = get_node("/root/menu")

var showTutorial:bool = true
var showTutorialEntities:bool = true
var uiScale:float = 1

func _showTutorial_toggle(toggled_on:bool):
	showTutorial = toggled_on
	if toggled_on:
		%showTutorial.get_child(0).text = "   [color=#9CDCFE] show_controls_tutorial[/color]: [color=#4FC1FF] true[/color]"
	else:
		%showTutorial.get_child(0).text = "   [color=#9CDCFE] show_controls_tutorial[/color]: [color=#4FC1FF]false[/color]"

func _showTutorialEntities_toggle(toggled_on:bool):
	showTutorialEntities = toggled_on
	if toggled_on:
		%showTutorialEntities.get_child(0).text = "   [color=#9CDCFE] show_entities_tutorial[/color]: [color=#4FC1FF] true[/color]"
	else:
		%showTutorialEntities.get_child(0).text = "   [color=#9CDCFE] show_entities_tutorial[/color]: [color=#4FC1FF]false[/color]"

func setShowTutorial(value:bool):
	_showTutorial_toggle(value)
	%showTutorial.get_child(1).button_pressed = value

func setShowTutorialEntities(value:bool):
	_showTutorialEntities_toggle(value)
	%showTutorialEntities.get_child(1).button_pressed = value

func _uiScale_change(value:float):
	%uiScale.get_child(0).text = "   [color=#9CDCFE] ui_scale[/color]: [color=#4FC1FF]%s[/color]" % [str(int(%uiScale.get_child(1).value)).lpad(3) + "%"]
	menu.scale = U.v2(%uiScale.get_child(1).value * 0.01)
	uiScale = %uiScale.get_child(1).value * 0.01
