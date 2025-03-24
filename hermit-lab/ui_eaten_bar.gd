extends ProgressBar
class_name BeEatenBar

signal eaten  # Signal emitted when bar reaches 100

@export var be_eaten_rate: float = 20.0  # Base rate increase per second
@export var sprint_multiplier: float = 2.0
@export var hide_reduction: float = 40.0
@export var be_eaten_bar_path: NodePath  # Assign this to the BeEatenBar node in the Inspector

var be_eaten_level: float = 0.0
var is_hiding: bool = false
var be_eaten_bar: ProgressBar = null

func _ready() -> void:
    # Assign the BeEatenBar node using the exported NodePath
    if be_eaten_bar_path:
        be_eaten_bar = get_node(be_eaten_bar_path)
    else:
        print("Error: be_eaten_bar_path is not assigned!")

func _process(delta: float) -> void:
    if is_hiding:
        be_eaten_level = max(0, be_eaten_level - hide_reduction * delta)
    self.value = be_eaten_level

func increase(amount: float) -> void:
    be_eaten_level = min(100, be_eaten_level + amount)
    self.value = be_eaten_level
    if be_eaten_level >= 100:
        emit_signal("eaten")
