extends ProgressBar

# Base consumption: full (100 units) drains over 1800 seconds (30 minutes)
const BASE_RATE: float = 100.0 / 100.0  # units per second

var player: Node = null

func _ready() -> void:
	# Instead of using onready, we assign the player node in _ready().
	if has_node("/root/Node2D/Player"):
		player = get_node("/root/Node2D/Player")
	else:
		print("Player node not found!")

func _process(delta: float) -> void:
	var consumption_rate = BASE_RATE

	# Check if the player is moving
	if player:
		# Assume the player has a "velocity" property.
		if player.velocity.length() > 0:
			consumption_rate *= 2  # Decrease twice as fast when moving.
			# Check for sprinting (make sure you have an input action "sprint").
			if Input.is_action_pressed("sprint"):
				consumption_rate *= 2  # 4x as fast when sprinting.
	
	# Decrease the bar's value over time, clamping it to a minimum of 0.
	value = max(0, value - consumption_rate * delta)
