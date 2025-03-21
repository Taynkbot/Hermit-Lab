extends CharacterBody2D

@export var speed: int = 200
@export var sprint_speed_multiplier: float = 1.5
@export var be_eaten_bar_path: NodePath  # Assign this to your BeEatenBar node in the Inspector
@export var eat_bar_path: NodePath       # Assign this to your EatBar node in the Inspector
#@onready var smell_arrow = $"../UI_Layer/SmellArrow"  # Adjust path as needed
#@export var smell_range: float = 500  # Maximum distance to detect food

var inventory: Array = []

var inventory_ui: Node = null
var eat_bar: ProgressBar = null
var death_label: Label = null
var is_dead: bool = false
var be_eaten_bar: BeEatenBar = null  # Requires your ui_eaten_bar.gd to have "class_name BeEatenBar"
var can_pickup: bool = true


const FOOD_RESTORE_AMOUNT: int = 25

func _ready() -> void:
	# Find UI nodes (adjust paths to match your scene hierarchy)
	if has_node("../UI_Layer/Panel/VBoxContainer"):
		inventory_ui = get_node("../UI_Layer/Panel/VBoxContainer")
	if eat_bar_path:
		eat_bar = get_node(eat_bar_path)
	else:
		print("Warning: eat_bar_path not set!")
	if has_node("../UI_Layer/DeathLabel"):
		death_label = get_node("../UI_Layer/DeathLabel")
		death_label.visible = false

	# Get the BeEatenBar using the exported node path
	if be_eaten_bar_path:
		be_eaten_bar = get_node(be_eaten_bar_path)
		if be_eaten_bar:
			be_eaten_bar.connect("eaten", Callable(self, "_on_be_eaten"))
		else:
			print("Warning: BeEatenBar node not found via be_eaten_bar_path!")
	else:
		print("Warning: be_eaten_bar_path is not set!")
	
	update_inventory_ui()

func _physics_process(delta: float) -> void:
	if is_dead:
		return  # Stop processing if dead

	var input_vector = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)

	var is_moving = input_vector != Vector2.ZERO
	var is_sprinting = Input.is_action_pressed("sprint")
	
	if is_moving:
		input_vector = input_vector.normalized() * speed
		if is_sprinting:
			input_vector *= sprint_speed_multiplier
	velocity = input_vector
	move_and_slide()
	
	# Check for starvation: if EatBar is empty, die.
	if eat_bar and eat_bar.value <= 0:
		die("You starved to death")
	
	# Press F to consume food
	if Input.is_action_just_pressed("pickup"):
		eat_food()
	
	# Update BeEatenBar: increase while moving
	if is_moving and be_eaten_bar:
		var increase_amount = be_eaten_bar.be_eaten_rate * delta
		if is_sprinting:
			increase_amount *= be_eaten_bar.sprint_multiplier
		be_eaten_bar.increase(increase_amount)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("hide"):
		if be_eaten_bar:
			be_eaten_bar.is_hiding = true
	elif event.is_action_released("hide"):
		if be_eaten_bar:
			be_eaten_bar.is_hiding = false
	# Check for pickup event
	if event.is_action_released("pickup"):
		can_pickup = true
	# ... your other input handling (e.g., hide) remains here.


# Adds an item to the inventory.
# When adding food, call add_item("Morsel of Food", true)
func add_item(item_name: String, is_food: bool = false) -> void:
	inventory.append({"name": item_name, "is_food": is_food})
	print("Picked up: " + item_name + " (food: " + str(is_food) + ")")
	update_inventory_ui()

func add_treasure(treasure: Node) -> void:
	# You could store treasure data, update an inventory, etc.
	print("Treasure picked up!")
	# For example, add the treasure's computed color or attributes to an inventory array.


# Updates the inventory UI with current items.
func update_inventory_ui() -> void:
	if inventory_ui:
		for child in inventory_ui.get_children():
			child.queue_free()
		for item in inventory:
			var label = Label.new()
			label.text = item["name"]
			inventory_ui.add_child(label)

# Consumes one food item and restores the EatBar by FOOD_RESTORE_AMOUNT.
func eat_food() -> void:
	print("Attempting to eat food. Inventory size: " + str(inventory.size()))
	for i in range(inventory.size()):
		if inventory[i]["is_food"]:
			if eat_bar:
				var old_value = eat_bar.value
				eat_bar.value = min(eat_bar.max_value, eat_bar.value + FOOD_RESTORE_AMOUNT)
				print("Ate: " + inventory[i]["name"] + ", EatBar: " + str(old_value) + " -> " + str(eat_bar.value))
			else:
				print("Warning: EatBar not found!")
			inventory.remove_at(i)
			update_inventory_ui()
			return
	print("No food to eat!")

# Callback for BeEatenBar signal.
func _on_be_eaten() -> void:
	die("You were eaten by a seagull")

# Death function with delay.
func die(reason: String = "You dead Dingus") -> void:
	if is_dead:
		return
	is_dead = true
	print("You died! Reason: " + reason)
	if death_label:
		death_label.text = reason
		death_label.visible = true
	await get_tree().create_timer(3.0).timeout
	get_tree().reload_current_scene()

# Assuming you're using a CharacterBody2D
func _process(delta):
	if velocity.length() > 0:  # Only rotate if moving
		rotation = velocity.angle ()
