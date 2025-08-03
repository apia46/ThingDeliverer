extends Control
class_name Menu

@onready var game = %game
@onready var overlay = %overlay

var paused:bool = false

func togglePause() -> void:
	if paused: retreat()
	else: entreat()
	paused = !paused

func retreat() -> void:
	var tween = create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "position:x", -200, 0.2)
	tween.tween_property(self, "size", Vector2(get_viewport().size) + Vector2(200, 200), 0.2)

func entreat() -> void:
	var tween = create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "position:x", 0, 0.2)
	tween.tween_property(self, "size", Vector2(get_viewport().size), 0.2)

func consolePrint(string:String) -> void:
	%console.append_text("\n[" + U.timeToText(game.timeSinceStart, true) + "] " + string)

func consoleError(string:String) -> void:
	%console.append_text("\n[color=#f96790][" + U.timeToText(game.timeSinceStart, true) + "] " + string + "[/color]")
