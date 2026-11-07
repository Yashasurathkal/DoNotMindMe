extends Area2D

@onready var sound: AudioStreamPlayer2D = $Sound


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		sound.play()
		hide()
		SignalHub.emit_pill_collected()

func _on_sound_finished() -> void:
	queue_free()
