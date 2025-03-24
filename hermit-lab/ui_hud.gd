# ui_hud.gd - attach this to your UI_Hud node (the root of your UI scene)
extends CanvasLayer
class_name HUD

@export var eat_bar_path: NodePath  # Assign this to the EatBar node in the Inspector
@export var overfill_bar_path: NodePath  # Assign this to the OverfillBar node in the Inspector
@export var player_path: NodePath  # Assign this to the Player node in the Inspector

@onready var overfill_bar = get_node(overfill_bar_path)

var eat_bar: Eat_Bar = null
var player: Node = null

func _ready() -> void:
    # Assign eat_bar using the exported NodePath
    if eat_bar_path:
        eat_bar = get_node(eat_bar_path)
        if not eat_bar:
            print("Error: eat_bar node not found!")
    else:
        print("Error: eat_bar_path is not assigned!")

    # Assign player using the exported NodePath
    if player_path:
        print("player_path is assigned: " + str(player_path))
        player = get_node(player_path)
        if not player:
            print("Error: player node not found at path: " + str(player_path))
        else:
            print("Player node successfully assigned: " + str(player))
    else:
        print("Error: player_path is not assigned!")

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
