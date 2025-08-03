extends Panel

@onready var menu:Menu = get_node("/root/menu")
@onready var game:Game = get_node("../..")

var options = [undergrounds, null, null]

func loadNext() -> void:
	%version.text = "Build " + str(game.rounds)

func _optionChosen(_meta, which:int) -> void: # i think theres a way to remove the first param but i cant bother to figure it out
	options[which].call()
	menu.consolePrint("Option %s chosen, next round is %s" % [which+1, game.rounds+1])
	game.nextRound()

func undergrounds() -> void:
	game.undergroundsAvailable += 5
