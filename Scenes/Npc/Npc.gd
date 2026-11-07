extends Area2D


enum EnemyState { Patrolling, Searching, Chasing }

const BULLET = preload("res://Scenes/Bullet/Bullet.tscn")

const SPEEDS: Dictionary[EnemyState, float] = {
	EnemyState.Patrolling: 90.0,
	EnemyState.Searching: 110.0,
	EnemyState.Chasing: 115.0
}

const FOV: Dictionary[EnemyState, float] = {
	EnemyState.Patrolling: 95.0,
	EnemyState.Searching: 125.0,
	EnemyState.Chasing: 150.0
}


@export var patrol_points: Node2D

@onready var nav_agent: NavigationAgent2D = $NavAgent
@onready var player_detect: RayCast2D = $PlayerDetect
@onready var gasp: AudioStreamPlayer2D = $Gasp
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var laser: AudioStreamPlayer2D = $Laser
@onready var timer: Timer = $Timer


var _patrol_points: Array[Vector2]
var _state: EnemyState = EnemyState.Patrolling
var _patrol_ix: int = 0
var _player_ref: Player

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("set_target"):
		nav_agent.target_position = get_global_mouse_position()

func _ready() -> void:
	for node in patrol_points.get_children():
		if node is Marker2D: _patrol_points.append(node.global_position)
		
	if _patrol_points.size() < 2:
		queue_free()
		return
	_player_ref = get_tree().get_first_node_in_group("player")
	if !_player_ref:
		queue_free()
		return

func detect_player() -> void:
	if can_see_player():
		change_state(EnemyState.Chasing)
	elif _state == EnemyState.Chasing:
		change_state(EnemyState.Searching)

func _physics_process(delta: float) -> void:
	detect_player()
	process_behavior()
	update_movement(delta)
	update_raycast()


func update_raycast() -> void:
	player_detect.look_at(_player_ref.global_position)

func navigate_to_patrol_point() -> void:
	nav_agent.target_position = _patrol_points[_patrol_ix]
	_patrol_ix = (_patrol_ix + 1) % _patrol_points.size()

func process_patrolling() -> void:
	if nav_agent.is_navigation_finished():
		navigate_to_patrol_point()
	
	
func process_searching() -> void:
	if nav_agent.is_navigation_finished():
		change_state(EnemyState.Patrolling)

func process_chasing() -> void:
	nav_agent.target_position = _player_ref.global_position

func process_behavior() -> void:
	match _state:
		EnemyState.Patrolling:
			process_patrolling()
		EnemyState.Chasing:
			process_chasing()
		EnemyState.Searching:
			process_searching()

func update_movement(delta: float) -> void:
	if nav_agent.is_navigation_finished(): return
	var npp:Vector2 = nav_agent.get_next_path_position()
	var dir: Vector2 = global_position.direction_to(npp)
	position += dir * SPEEDS[_state] * delta
	rotation = dir.angle()

func can_see_player() -> bool:
	return player_detect.get_collider() is Player and abs(fov_angle()) < FOV[_state]

func fov_angle() -> float:
	var dir:Vector2 = global_position.direction_to(_player_ref.global_position)
	var atp: float = transform.x.angle_to(dir)
	return rad_to_deg(atp)


func change_state(new_state: EnemyState) -> void:
	if new_state == _state: return
	_state = new_state
	
	match _state:
		EnemyState.Chasing:
			gasp.play()
			animation_player.play("chasing")
		EnemyState.Searching:
			animation_player.play("searching")
		EnemyState.Patrolling:
			animation_player.play("RESET")


func _on_timer_timeout() -> void:
	timer.wait_time = randf_range(1.5,3.0)
	shoot()

func shoot() -> void:
	if _state != EnemyState.Chasing: return
	laser.play()
	var new_b: Bullet = BULLET.instantiate()
	new_b.global_position = global_position
	new_b.setup(global_position.direction_to(_player_ref.global_position))
	get_tree().current_scene.add_child.call_deferred(new_b)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		SignalHub.emit_game_over(false)
