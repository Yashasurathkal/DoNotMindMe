class_name Bullet
extends Area2D

const SPEED:float = 300.0

@export var explosion: PackedScene

var _velocity: Vector2 = Vector2.ZERO

func setup(dir: Vector2) -> void:
	_velocity = dir * SPEED
	rotation = dir.angle() 


func explode() -> void:
	var explosion = explosion.instantiate()
	get_tree().current_scene.add_child(explosion)
	explosion.global_position = global_position
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	position += _velocity * delta


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		SignalHub.emit_game_over(false)
	explode()
