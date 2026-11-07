extends Control

var _pills_count = 0
var _collected = 0
var _time: float = 0

@onready var time_label: Label = $MC/TimeLabel
@onready var collected_label: Label = $MC/CollectedLabel
@onready var exit_label: Label = $MC/ExitLabel
@onready var game_over_rect: ColorRect = $GameOverRect
@onready var game_over_label: Label = $GameOverRect/GameOverLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().paused = false
	SignalHub.pill_collected.connect(on_pill_collected)
	SignalHub.game_over.connect(on_game_over)
	_pills_count = get_tree().get_nodes_in_group("pill").size()
	updated_collected_label()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().reload_current_scene()

func on_pill_collected() -> void:
	_collected += 1
	updated_collected_label()
	if _collected == _pills_count:
		exit_label.show()
		SignalHub.emit_show_exit()

func _process(delta: float) -> void:
	_time += delta
	time_label.text = "%.1fs" % _time


func on_game_over(won: bool) -> void:
	if won:
		game_over_label.text = "You win in %.1fs, Well done!" % _time
	game_over_rect.show()
	get_tree().paused = true
	

func updated_collected_label() -> void:
	collected_label.text = "%s/%s" % [
		_collected, _pills_count
	]
