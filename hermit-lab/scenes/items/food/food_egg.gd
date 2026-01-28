extends Area2D

@export var egg_textures: Array[Texture] = []  # Assign different egg textures in the Inspector
@onready var egg_sprite: Sprite2D = $Sprite2D  # Reference to the Sprite2D node

var is_nearby: bool = false
var player_ref: Node = null

func _ready() -> void:
	# Connect collision signals
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))
	
	# Ensure the prompt is hidden initially
	if has_node("Prompt"):
		$Prompt.visible = false

	# Assign a random texture to the egg_sprite
	if egg_textures.size() > 0:
		egg_sprite.texture = egg_textures[randi() % egg_textures.size()]  # Pick a random texture

func _on_body_entered(body: Node) -> void:
	if body.name == "Player":
		is_nearby = true
		player_ref = body
		if has_node("Prompt"):
			$Prompt.visible = true

func _on_body_exited(body: Node) -> void:
	if body.name == "Player":
		is_nearby = false
		player_ref = null
		if has_node("Prompt"):
			$Prompt.visible = false

func _process(delta: float) -> void:
	# When player is nearby and presses "pickup", check the flag.
	if is_nearby and Input.is_action_just_pressed("pickup"):
		if player_ref and player_ref.can_pickup:
			player_ref.can_pickup = false  # Consume the pickup event.
			# Add the food item; ensure the parameters are as expected.
			player_ref.add_item("Morsel of Food", true)
			queue_free()  # Remove this item.
