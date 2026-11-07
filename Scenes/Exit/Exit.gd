extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	SignalHub.show_exit.connect(on_show_exit)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		SignalHub.emit_game_over(true)

func on_show_exit() -> void:
	set_monitoring.call_deferred(true)
	show()
