extends Area2D

# Number of attributes for the treasure.
const NUM_ATTRIBUTES = 8

# Array to hold the 8 attribute values.
var attributes: Array = []

# Reference to the Sprite2D node.
@onready var sprite: Sprite2D = $Sprite2D

# Define 8 hues (in degrees) evenly spaced around the circle.
# For example: red (0°), orange (45°), yellow (90°), green (135°), cyan (180°), blue (225°), purple (270°), magenta (315°)
var hues: Array = [0.0, 45.0, 90.0, 135.0, 180.0, 225.0, 270.0, 315.0]

@export var texture: Texture
var player_in_area: bool = false

func _ready() -> void:
	# Generate random attributes.
	_generate_attributes()
	
	# Compute the final color based on attributes.
	var final_color = _compute_treasure_color()
	
	# If a texture is assigned, set it to the sprite.
	if texture:
		sprite.texture = texture
	else:
		print("Warning: No texture assigned!")
	
	# Apply the final color to the treasure sprite.
	sprite.modulate = final_color

	# Connect collision signals.
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))
	
	# Ensure the Prompt (if exists) is hidden initially.
	if has_node("Prompt"):
		$Prompt.visible = false

func _process(_delta: float) -> void:
	# Only allow pickup if the player is in range and presses the pickup action.
	if player_in_area and Input.is_action_just_pressed("pickup"):
		pickup()

func _on_body_entered(body: Node) -> void:
	# Check if the body is the player (or in the "player" group).
	if body.is_in_group("player"):
		player_in_area = true
		if has_node("Prompt"):
			$Prompt.visible = true

func _on_body_exited(body: Node) -> void:
	# Check if the body is the player (or in the "player" group).
	if body.is_in_group("player"):
		player_in_area = false
		if has_node("Prompt"):
			$Prompt.visible = false

func pickup() -> void:
	# Iterate over overlapping bodies to find the player.
	var bodies = get_overlapping_bodies()
	var player_node = null
	for b in bodies:
		# Ensure b is an object and in the "player" group.
		if b is Node and b.is_in_group("player"):
			player_node = b
			break
	if player_node and player_node.has_method("add_treasure"):
		player_node.add_treasure(self)
	else:
		print("Player not found or add_treasure() missing!")
	queue_free()

# Generate random attributes (each between 0 and 1).
func _generate_attributes() -> void:
	attributes.clear()
	for i in range(NUM_ATTRIBUTES):
		attributes.append(randf())

# Compute the final treasure color by blending the colors corresponding to each attribute.
func _compute_treasure_color() -> Color:
	var total_weight: float = 0.0
	var final_r: float = 0.0
	var final_g: float = 0.0
	var final_b: float = 0.0
	
	for i in range(NUM_ATTRIBUTES):
		var weight = attributes[i]
		total_weight += weight
		# Convert the hue to a color. Hue must be normalized (0 to 1).
		var hue_norm = hues[i] / 360.0
		# Use the attribute value as saturation, and full brightness (value = 1).
		var col = Color.from_hsv(hue_norm, weight, 1.0)
		
		# Accumulate weighted RGB values.
		final_r += col.r * weight
		final_g += col.g * weight
		final_b += col.b * weight
	
	# Normalize the accumulated color.
	if total_weight > 0:
		final_r /= total_weight
		final_g /= total_weight
		final_b /= total_weight
	
	return Color(final_r, final_g, final_b, 1.0)
