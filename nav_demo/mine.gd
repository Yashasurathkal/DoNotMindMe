extends Node2D


@export var speed: float = 5.0
@export var range_px: float = 100.0
@onready var navigation_obstacle_2d: NavigationObstacle2D = $NavigationObstacle2D


var min_y: float
var max_y: float
var dir: int = 1
var _velocity: Vector2

func _ready() -> void:
	min_y = global_position.y - range_px
	max_y = global_position.y + range_px
	dir = -1 if randf() < 0.5 else 1


func _physics_process(delta: float) -> void:
	if global_position.y > max_y:
		dir = -1
	elif global_position.y < min_y:
		dir = 1
	_velocity = speed * Vector2(0,dir)
	navigation_obstacle_2d.velocity = _velocity
	global_position += speed * _velocity * delta
