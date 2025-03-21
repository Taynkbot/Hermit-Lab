extends ProgressBar
class_name BeEatenBar

signal eaten  # Signal emitted when bar reaches 100

@export var be_eaten_rate: float = 20.0  # Base rate increase per second
@export var sprint_multiplier: float = 2.0
@export var hide_reduction: float = 40.0

var be_eaten_level: float = 0.0
var is_hiding: bool = false

func _process(delta: float) -> void:
    if is_hiding:
        be_eaten_level = max(0, be_eaten_level - hide_reduction * delta)
    self.value = be_eaten_level

func increase(amount: float) -> void:
    be_eaten_level = min(100, be_eaten_level + amount)
    self.value = be_eaten_level
    if be_eaten_level >= 100:
        emit_signal("eaten")
