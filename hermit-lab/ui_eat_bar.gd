extends ProgressBar
class_name Eat_Bar

@export var eat_bar_path: NodePath  # Assign this to the EatBar node in the Inspector
@export var overfill_bar_path: NodePath  # Assign this to the OverfillBar node in the Inspector

# BASE_RATE is set so that a full (100) bar drains over 18
const BASE_RATE: float = 100.0 / 18.0
const OVERFILL_DECAY_RATE: float = 50.0 / 18.0  # Overfill bar drains faster than the eat bar

var eat_bar: ProgressBar = null
var overfill_bar: ProgressBar = null
var universal_food_value: float = 125  # Universal food value representing total food

func _ready() -> void:
	# Assign eat_bar and overfill_bar using the exported NodePaths
	if eat_bar_path:
		eat_bar = get_node(eat_bar_path)
		if not eat_bar:
			print("Error: eat_bar node not found!")
	else:
		print("Error: eat_bar_path is not assigned!")

	if overfill_bar_path:
		overfill_bar = get_node(overfill_bar_path)
		if not overfill_bar:
			print("Error: overfill_bar node not found!")
	else:
		print("Error: overfill_bar_path is not assigned!")

func update_bars() -> void:
	# Update the EatBar based on universal_food_value (0-100)
	if eat_bar:
		eat_bar.value = clamp(universal_food_value, 0, 100)

	# Update the OverfillBar based on universal_food_value (100-200)
	if overfill_bar:
		overfill_bar.value = clamp(universal_food_value - 100, 0, 100)

func add_food(amount: float) -> void:
	# Add food to the universal food value
	universal_food_value += amount
	universal_food_value = min(universal_food_value, 200)  # Cap the universal food value at 200

	# Debugging: Print once when food is added
	print("Food added. Universal food value: ", universal_food_value)

	# Update the bars
	update_bars()

func consume(delta: float, consumption_rate: float) -> void:
	# Calculate the amount to consume
	var consumption = consumption_rate * delta

	# Reduce the universal food value
	universal_food_value = max(0, universal_food_value - consumption)

	# Update the bars
	update_bars()
