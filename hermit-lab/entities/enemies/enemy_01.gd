extends CharacterBody2D

# simple enemy that will chase the player when they come within a radius

@export var speed: float = 100.0            # movement speed of the enemy
@export var chase_radius: float = 300.0      # how close the player must be before the enemy starts following

# unique identifier for saving/loading; fill manually in the inspector or leave blank to auto‑assign
@export var enemy_id: String = ""

# a cached reference to the player node, looked up in _ready()
@onready var player: CharacterBody2D = null

func _ready() -> void:
	# ensure we're part of the enemy group so the save manager sees us
	if not is_in_group("enemy"):
		add_to_group("enemy")
		print("[Enemy] added to group 'enemy' path=", get_path())
	else:
		print("[Enemy] already in group 'enemy' path=", get_path())

	# give ourselves a unique id if none was supplied
	# using the node's path ensures it stays stable between runs as long as the scene layout
	# doesn't change. you can still override manually in the inspector if needed.
	if enemy_id == "":
		enemy_id = str(get_path())
	print("[Enemy] ready with id=", enemy_id)

	# locate the player by group (ensure your player node is added to "player" group)
	# this avoids runtime errors with scene lookups
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0] as CharacterBody2D
	if not player:
		push_warning("Enemy01: could not locate Player node in group 'player'")

func _physics_process(delta: float) -> void:
	if player:
		var to_player = player.global_position - global_position
		var distance = to_player.length()
		if distance <= chase_radius:
			# move directly toward the player
			var dir = to_player.normalized()
			velocity = dir * speed
			# rotate to face movement direction (optional)
			if velocity.length() > 0:
				rotation = velocity.angle()
		else:
			velocity = Vector2.ZERO
	else:
		# if we lost the player reference, try to find it again occasionally
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			player = players[0] as CharacterBody2D

	move_and_slide()

# ----------------- save/load support --------------------------------
# return a dictionary that can be stored by the save manager
func get_save_data() -> Dictionary:
	return {
		"id": enemy_id,
		"position": {"x": global_position.x, "y": global_position.y}
	}

# apply saved properties back to this enemy
func load_save_data(data: Dictionary) -> void:
	if data.has("position"):
		var p = data["position"]
		global_position = Vector2(p["x"], p["y"])
