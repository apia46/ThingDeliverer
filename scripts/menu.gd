extends Control
class_name Menu

var game:Game
@onready var overlay:Panel = %overlay
@onready var mainMenuButton:Button = %mainMenuButton

var paused:bool = true
var currentFile:int = 1
var gaming:bool = false

func _ready() -> void:
	var timer = create_tween()
	timer.tween_interval(0.2)
	timer.tween_callback(func():
		var tween = create_tween().set_parallel().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "position:x", 0, 1.5)
		tween.tween_property(self, "size", Vector2(get_viewport().size), 1.5)
		%mainMenu.loadDialogue(0)
	)

func togglePause(withoutConsole:bool=false) -> void:
	if paused: retreat(withoutConsole)
	else: entreat()
	paused = !paused

func retreat(withoutConsole:bool=false) -> void:
	var tween = create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "position:x", -200, 0.2)
	if withoutConsole: tween.tween_property(self, "size:x", get_viewport().size.x + 200, 0.2)
	else: tween.tween_property(self, "size", Vector2(get_viewport().size) + Vector2(200, 200), 0.2)

func entreat() -> void:
	var tween = create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "position:x", 0, 0.2)
	tween.tween_property(self, "size", Vector2(get_viewport().size), 0.2)

func consoleSet(string:String) -> void:
	%console.clear()
	%console.append_text(string)

func consolePrint(string:String) -> void:
	%console.append_text("\n[" + U.timeToText(game.timeSinceStart, true) + "] " + string)

func consoleError(string:String) -> void:
	%console.append_text("\n[color=#f96790][" + U.timeToText(game.timeSinceStart, true) + "] " + string + "[/color]")

func _chooseFile(which:int) -> void:
	if gaming and which == 1:
		%files.get_child(currentFile).get_child(0).button_pressed = true
		%confirm.visible = true
	else:
		%openFile.get_child(currentFile).visible = false
		%openFile.get_child(which).visible = true
		currentFile = which
		if which == 1: %mainMenu.loadDialogue(0)

func confirmEndRun() -> void:
	consolePrint("Game stopped")
	%openFile.get_child(currentFile).visible = true
	%openFile.get_child(0).visible = false
	%gameFile.visible = false
	%consoleCont.visible = false
	gaming = false
	overlay.modulate.a = 0
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	game.queue_free()

func startGame() -> void:
	if gaming: return
	var timer = create_tween()
	timer.tween_interval(0.2)
	timer.tween_callback(func():
		%consoleCont.visible = true
		size.y = get_viewport().size.y + 200
	)
	gaming = true
	%gameFile.visible = true
	%gameFileButton.button_pressed = true
	_chooseFile(0)
	game = preload("res://scenes/game.tscn").instantiate()
	%gameCont.add_child(game)
	togglePause(true)
