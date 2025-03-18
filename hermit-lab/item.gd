extends Area2D

var is_nearby: bool = false
var player_ref: Node = null

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))
	$Prompt.visible = false

func _on_body_entered(body: Node) -> void:
	if body.name == "Player":
		is_nearby = true
		player_ref = body
		$Prompt.visible = true

func _on_body_exited(body: Node) -> void:
	if body.name == "Player":
		is_nearby = false
		player_ref = null
		$Prompt.visible = false

func _process(delta: float) -> void:
	if is_nearby and Input.is_action_just_pressed("pickup"):
		# Call the player's add_item function if it exists
		if player_ref and player_ref.has_method("add_item"):
			player_ref.add_item("Mysterious Trinket")
		queue_free()
