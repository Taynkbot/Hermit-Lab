extends Area2D

@export var egg_textures: Array[Texture] = []  # Assign different egg textures in the Inspector
@onready var egg_sprite: Sprite2D = $Sprite2D  # Reference to the Sprite2D node
@export var food_amount: int = 25  # Amount of food this egg gives when picked up

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
	# When player is nearby and presses "eat", check the flag.
	if is_nearby and Input.is_action_just_pressed("eat"):
		if player_ref and player_ref.can_eat:
			player_ref.can_eat = false  # Consume the eat event.
			# Directly add food to the player's eat bar (skip inventory)
			if player_ref.has_method("eat_food"):
				player_ref.eat_food(food_amount)
			elif player_ref.hud and player_ref.hud.has_node("eat_bar"):
				player_ref.hud.get_node("eat_bar").add_food(food_amount)
			else:
				print("food_egg: WARNING - couldn't add food to player (no method or eat_bar found)")
			queue_free()  # Remove this item.
