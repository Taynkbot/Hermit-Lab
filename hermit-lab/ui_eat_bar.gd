extends ProgressBar
class_name Eat_Bar

# BASE_RATE is set so that a full (100) bar drains over 1800 seconds (30 minutes)
const BASE_RATE: float = 100.0 / 18.0

var player: Node = null

func _ready() -> void:
	# Look for the player at the specified path.
	if has_node("/root/Node2D/Player"):
		player = get_node("/root/Node2D/Player")
	else:
		print("Player node not found!")

func _process(delta: float) -> void:
	var consumption_rate = BASE_RATE
	
	if player:
		# Double the consumption rate if the player is moving.
		if player.velocity.length() > 0:
			consumption_rate *= 2
			# Quadruple it if the player is sprinting (make sure "sprint" is set in Input Map)
			if Input.is_action_pressed("sprint"):
				consumption_rate *= 2

	# Decrease the bar's value (clamped at 0).
	value = max(0, value - consumption_rate * delta)
	
	# Check if food has run out.
	if value <= 0:
		# Call the player's die() method if it exists.
		if player and player.has_method("die"):
			player.die()
