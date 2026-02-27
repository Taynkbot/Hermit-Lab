extends Node

@onready var shell_sprite: Sprite2D = $Sprite2D  # Reference to the Sprite2D node

var is_nearby: bool = false
var player_ref: Node = null
var player_in_area: bool = false
		


func _ready() -> void:
	# Connect collision signals
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))
	
	# Ensure the prompt is hidden initially
	if has_node("Prompt"):
		$Prompt.visible = false

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
