extends Panel

@onready var game:Game = get_node("/root/game")

var options = [undergrounds, null, null]

func loadNext() -> void:
	%version.text = "Build " + str(game.rounds)

func _optionChosen(_meta, which:int) -> void: # i think theres a way to remove the first param but i cant bother to figure it out
	options[which].call()
	game.nextRound()

func undergrounds() -> void:
	game.undergroundsAvailable += 5
