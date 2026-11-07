class_name Player
extends CharacterBody2D


@export var speed: float = 120.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	var input: Vector2 = Input.get_vector("left","right","up","down")
	velocity = input.normalized() * speed
	if !is_zero_approx(velocity.length()):
		rotation = velocity.angle()
	move_and_slide()
