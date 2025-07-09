extends Panel

@onready var game = get_node("/root/game")
var options = [undergrounds, null, null]

func optionChosen(which) -> void:
	options[which].call()
	game.nextRound()

func undergrounds() -> void:
	game.undergroundsAvailable += 5
