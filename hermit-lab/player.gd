extends CharacterBody2D

@export var speed: int = 200
var inventory: Array = []

var inventory_ui: Node = null
var eat_bar: ProgressBar = null

func _ready() -> void:
	# Try to find UI nodes. These lines will work when you add them under CanvasLayer.
	if has_node("../CanvasLayer/Panel/VBoxContainer"):
		inventory_ui = get_node("../CanvasLayer/Panel/VBoxContainer")
	if has_node("../CanvasLayer/EatBar"):
		eat_bar = get_node("../CanvasLayer/EatBar")
	
	update_inventory_ui()

func _physics_process(delta: float) -> void:
	var input_vector = Vector2.ZERO

	# Handle movement input.
	if Input.is_action_pressed("ui_right"):
		input_vector.x += 1
	if Input.is_action_pressed("ui_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("ui_down"):
		input_vector.y += 1
	if Input.is_action_pressed("ui_up"):
		input_vector.y -= 1

	if input_vector != Vector2.ZERO:
		input_vector = input_vector.normalized() * speed

	velocity = input_vector
	move_and_slide()

	# When pressing F (pickup), simulate picking up a food item.
	if Input.is_action_just_pressed("pickup"):
		add_item("Morsel of Food", true)

# Adds an item to the inventory.
# If is_food is true, it will also restore 25% of the Eat bar.
func add_item(item_name: String, is_food: bool = false) -> void:
	inventory.append(item_name)
	print("Picked up: " + item_name)
	update_inventory_ui()
	
	if is_food and eat_bar:
		eat_bar.value = min(eat_bar.max_value, eat_bar.value + 25)

# Updates the inventory UI with current items.
func update_inventory_ui() -> void:
	if inventory_ui:
		for child in inventory_ui.get_children():
			child.queue_free()
		for item in inventory:
			var label = Label.new()
			label.text = item
			inventory_ui.add_child(label)

# Called when the player dies.
func die() -> void:
	print("You died!")
	get_tree().reload_current_scene()
