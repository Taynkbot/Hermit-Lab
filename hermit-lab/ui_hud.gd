# ui_hud.gd - attach this to your UI_Hud node (the root of your UI scene)
extends CanvasLayer
class_name HUD

@export var eat_bar_path: NodePath  # Assign this to the EatBar node in the Inspector
@export var overfill_bar_path: NodePath  # Assign this to the OverfillBar node in the Inspector
@export var player_path: NodePath  # Assign this to the Player node in the Inspector
@export var be_eaten_bar_path: NodePath  # Assign this to the BeEatenBar node in the Inspector

@onready var eat_bar: Eat_Bar = get_node(eat_bar_path)
@onready var overfill_bar = get_node(overfill_bar_path)
@onready var be_eaten_bar = get_node(be_eaten_bar_path)
@onready var player: Node = get_node(player_path)

func _ready() -> void:
	# Debugging: Ensure all nodes are assigned correctly
	if not eat_bar:
		print("Error: eat_bar node not found!")
	if not overfill_bar:
		print("Error: overfill_bar node not found!")
	if not be_eaten_bar:
		print("Error: be_eaten_bar node not found!")
	if not player:
		print("Error: player node not found!")

func _process(delta: float) -> void:
	if player and eat_bar:
		# Calculate the consumption rate based on player movement
		var consumption_rate = eat_bar.BASE_RATE
		if player.velocity.length() > 0:
			consumption_rate *= 2  # Double the rate if the player is moving
			if Input.is_action_pressed("sprint"):
				consumption_rate *= 2  # Quadruple the rate if the player is sprinting

		# Debugging: Remove this print statement to stop spamming the console
		# print("Calling consume with delta: ", delta, " and consumption_rate: ", consumption_rate)

		# Update the eat bar
		eat_bar.consume(delta, consumption_rate)

func eat_food(food_amount: float) -> void:
	if eat_bar:
		print("Calling add_food with amount: ", food_amount)
		eat_bar.add_food(food_amount)
	else:
		print("Error: eat_bar is not assigned!")
