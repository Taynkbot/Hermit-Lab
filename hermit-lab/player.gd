extends CharacterBody2D

@export var speed: int = 200
@export var sprint_speed_multiplier: float = 1.5
@export var hud_path: NodePath  # Assign this to your HUD node in the Inspector

@onready var hud = get_node(hud_path)  # Reference to the HUD node

var inventory: Array = []
var inventory_ui: Node = null
var death_label: Label = null
var is_dead: bool = false
var can_pickup: bool = true
var base_speed = 200  # Adjust this to your normal movement speed
var overfill_penalty = 0.05  # Speed penalty per overfill level

const FOOD_RESTORE_AMOUNT: int = 25


func _ready() -> void:
	# Find UI nodes (adjust paths to match your scene hierarchy)
	if has_node("../UI_Layer/Panel/VBoxContainer"):
		inventory_ui = get_node("../UI_Layer/Panel/VBoxContainer")
	if has_node("../UI_Layer/DeathLabel"):
		death_label = get_node("../UI_Layer/DeathLabel")
		death_label.visible = false

	# Check if the HUD node is assigned
	if hud_path:
		hud = get_node(hud_path)
		if not hud:
			print("Warning: HUD node not found via hud_path!")
	else:
		print("Warning: hud_path is not set!")

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
		if hud.has_node("EatBar"):
			data["food_value"] = hud.get_node("EatBar").universal_food_value
		if hud.has_node("BeEatenBar"):
			data["threat_level"] = hud.get_node("BeEatenBar").value

	return data


func load_save_data(data: Dictionary) -> void:
	if data.has("position"):
		var p = data["position"]
		global_position = Vector2(p["x"], p["y"])

	if data.has("inventory"):
		inventory = data["inventory"]
		update_inventory_ui()

	if hud:
		if data.has("food_value") and hud.has_node("EatBar"):
			hud.get_node("EatBar").set_food_value(data["food_value"])

		if data.has("threat_level") and hud.has_node("BeEatenBar"):
			hud.get_node("BeEatenBar").value = data["threat_level"]






func get_movement_speed() -> float:
	# Check if the HUD and EatBar exist
	if hud and hud.has_node("EatBar"):
		var eat_bar = hud.get_node("EatBar")
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
	
	# Check for starvation: if EatBar is empty, die.
	if hud and hud.has_node("EatBar"):
		var eat_bar = hud.get_node("EatBar")
		if eat_bar.value <= 0:
			die("You starved to death")
	
	# Press F to consume food
	if Input.is_action_just_pressed("pickup"):
		eat_food()
	
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
	if event.is_action_released("pickup"):
		can_pickup = true

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
			if hud and hud.has_node("EatBar"):
				var eat_bar = hud.get_node("EatBar")  # Get the EatBar node
				if eat_bar.has_method("add_food"):
					eat_bar.add_food(FOOD_RESTORE_AMOUNT)  # Add food to the universal food value
					print("Ate: " + inventory[i]["name"] + ", Universal food value updated")
				else:
					print("Error: EatBar does not have an add_food method!")
			else:
				print("Warning: HUD or EatBar not found!")
			inventory.remove_at(i)  # Remove the food item from the inventory
			update_inventory_ui()  # Update the inventory UI
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
		rotation = velocity.angle()
