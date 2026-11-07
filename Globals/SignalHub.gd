extends Node

signal pill_collected
signal show_exit
signal game_over

func emit_pill_collected() -> void:
	pill_collected.emit()


func emit_game_over(won: bool) -> void:
	game_over.emit(won)

func emit_show_exit() -> void:
	show_exit.emit()
