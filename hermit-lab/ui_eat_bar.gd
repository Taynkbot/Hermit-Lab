extends ProgressBar
class_name Eat_Bar

@export var eat_bar_path: NodePath  # Assign this to the EatBar node in the Inspector
@export var overfill_bar_paths: Array = []  # Assign this to all OverfillBar nodes in the Inspector

# BASE_RATE is set so that a full (100) bar drains over 18
const BASE_RATE: float = 100.0 / 18.0
const OVERFILL_DECAY_RATE: float = 50.0 / 18.0  # Overfill bars drain faster than the eat bar

var eat_bar: ProgressBar = null
var overfill_bars: Array = []  # Stores references to all OverfillBar nodes
var universal_food_value: float = 125  # Universal food value representing total food

func _ready() -> void:
	# Assign eat_bar using the exported NodePath
	if eat_bar_path:
		eat_bar = get_node(eat_bar_path)
		if not eat_bar:
			print("Error: eat_bar node not found!")
	else:
		print("Error: eat_bar_path is not assigned!")

	# Manually assign OverfillBar nodes
	overfill_bars.append($OverfillBar)
	overfill_bars.append($OverfillBar2)
	overfill_bars.append($OverfillBar3)
	overfill_bars.append($OverfillBar4)
	overfill_bars.append($OverfillBar5)
	overfill_bars.append($OverfillBar6)
	overfill_bars.append($OverfillBar7)
	overfill_bars.append($OverfillBar8)
	overfill_bars.append($OverfillBar9)

	print("Overfill bars initialized: ", overfill_bars.size(), " bars found.")

func update_bars() -> void:
	# Update the EatBar based on universal_food_value (0-100)
	if eat_bar:
		eat_bar.value = clamp(universal_food_value, 0, 100)

	# Update each OverfillBar based on its respective range
	for i in range(overfill_bars.size()):
		var bar = overfill_bars[i]
		var range_start = 100 + (i * 100)
		var range_end = range_start + 100
		bar.value = clamp(universal_food_value - range_start, 0, 100)


func get_food_value() -> float:
	return universal_food_value

func set_food_value(value: float) -> void:
	universal_food_value = clamp(value, 0, 1000)
	update_bars()


func add_food(amount: float) -> void:
	# Add food to the universal food value
	universal_food_value += amount
	universal_food_value = min(universal_food_value, 1000)  # Cap the universal food value at 1000

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
