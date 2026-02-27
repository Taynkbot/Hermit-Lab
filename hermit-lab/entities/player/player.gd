extends CharacterBody2D

@export var speed: int = 200
@export var sprint_speed_multiplier: float = 1.5

@onready var hud = get_node("../UI_Layer")  # Reference to the HUD node
@onready var inventory_ui = get_node("../UI_Layer/ui_inventory")  # Reference to the inventory UI container

var inventory: Array = []
var death_label: Label = null
var is_dead: bool = false
var can_eat: bool = true
var can_pickup: bool = true
var base_speed = 200  # Adjust this to your normal movement speed
var overfill_penalty = 0.05  # Speed penalty per overfill level

const FOOD_RESTORE_AMOUNT: int = 25


func _ready() -> void:
	# Find UI nodes (adjust paths to match your scene hierarchy)
	if has_node("../UI_Layer/DeathLabel"):
		death_label = get_node("../UI_Layer/DeathLabel")
		death_label.visible = false

	update_inventory_ui()


func get_save_data() -> Dictionary:
	var data := {
		"position": {
			"x": global_position.x,
			"y": global_position.y
		},
		"inventory": inventory
	}

	if hud:
		if hud.has_node("eat_bar"):
			data["food_value"] = hud.get_node("eat_bar").universal_food_value
		if hud.has_node("BeEatenBar"):
			data["threat_level"] = hud.get_node("BeEatenBar").be_eaten_level
			print("Saving threat_level: ", data["threat_level"])

	return data


func load_save_data(data: Dictionary) -> void:
	if data.has("position"):
		var p = data["position"]
		global_position = Vector2(p["x"], p["y"])

	if data.has("inventory"):
		inventory = data["inventory"]
		update_inventory_ui()

	if hud:
		if data.has("food_value") and hud.has_node("eat_bar"):
			hud.get_node("eat_bar").set_food_value(data["food_value"])

		if data.has("threat_level") and hud.has_node("BeEatenBar"):
			hud.get_node("BeEatenBar").be_eaten_level = data["threat_level"]
			print("Loading threat_level: ", data["threat_level"])





func get_movement_speed() -> float:
	# Check if the HUD and eat_bar exist
	if hud and hud.has_node("eat_bar"):
		var eat_bar = hud.get_node("eat_bar")
		var food_value = eat_bar.universal_food_value

		# Double speed if food is 15 or less
		if food_value <= 15:
			return base_speed * 2.0

		# Gradually decrease speed from 100 to 1000 food
		if food_value >= 100:
			# Map food_value (100-1000) to speed percentage (100%-1%)
			var speed_percentage = lerp(1.0, 0.01, (food_value - 100) / 900.0)
			return base_speed * speed_percentage

	# Default speed if no conditions are met
	return base_speed

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
		input_vector = input_vector.normalized()
		var movement_speed = get_movement_speed()
		if is_sprinting:
			movement_speed *= sprint_speed_multiplier
		velocity = input_vector * movement_speed
	else:
		velocity = Vector2.ZERO

	move_and_slide()
	
	# Check for starvation: if eat_bar is empty, die.
	if hud and hud.has_node("eat_bar"):
		var eat_bar = hud.get_node("eat_bar")
		if eat_bar.value <= 0:
			die("You starved to death")
	
	# Update BeEatenBar: increase while moving
	if is_moving and hud and hud.has_node("BeEatenBar"):
		var be_eaten_bar = hud.get_node("BeEatenBar")
		var increase_amount = be_eaten_bar.be_eaten_rate * delta
		if is_sprinting:
			increase_amount *= be_eaten_bar.sprint_multiplier
		be_eaten_bar.increase(increase_amount)

	# Check if BeEatenBar is full
	if hud and hud.has_node("BeEatenBar"):
		var be_eaten_bar = hud.get_node("BeEatenBar")
		if be_eaten_bar.value >= be_eaten_bar.max_value:
			_on_be_eaten()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("hide"):
		if hud and hud.has_node("BeEatenBar"):
			var be_eaten_bar = hud.get_node("BeEatenBar")
			be_eaten_bar.is_hiding = true
	elif event.is_action_released("hide"):
		if hud and hud.has_node("BeEatenBar"):
			var be_eaten_bar = hud.get_node("BeEatenBar")
			be_eaten_bar.is_hiding = false
	# Check for pickup event
	if event.is_action_released("eat"):
		can_eat = true


# Consumes one food item and restores the eat_bar by amount.
func eat_food(amount: int = FOOD_RESTORE_AMOUNT) -> void:
	print("Attempting to eat food. Amount: ", amount)
	if hud and hud.has_node("eat_bar"):
		var eat_bar = hud.get_node("eat_bar")  # Get the eat_bar node
		if eat_bar.has_method("add_food"):
			eat_bar.add_food(amount)  # Add food to the universal food value
			print("Ate food! Added: ", amount)
		else:
			print("Error: eat_bar does not have an add_food method!")
	else:
		print("No food to eat!")

func pickup_item(item_data: Dictionary) -> void:
	inventory.append(item_data)
	update_inventory_ui()
	# For example, add the treasure's computed color or attributes to an inventory array.

# Updates the inventory UI with current items.
func update_inventory_ui() -> void:
	print("inventory_ui:", inventory_ui)
	print("inventory size:", inventory.size())
	if inventory_ui:
		for child in inventory_ui.get_children():
			child.queue_free()
		for item in inventory:
			var label = Label.new()
			label.text = item["name"]
			inventory_ui.add_child(label)

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
func _process(_delta):
	if velocity.length() > 0:  # Only rotate if moving
		rotation = velocity.angle()
