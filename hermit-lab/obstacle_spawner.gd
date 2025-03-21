extends Node2D

@export var obstacle_scene: PackedScene
@export var spawn_area: Vector2 = Vector2(1000, 1000)  # Define spawn area size
@export var grid_size: float = 100.0  # Distance between spawn points
@export var num_obstacles: int = 20  # Adjust as needed

@onready var player: Node2D = get_tree().get_first_node_in_group("player")  # Ensure player is in "player" group

func _ready():
	if not player:
		print("Warning: Player not found in scene!")
		return

	var spawn_positions = generate_spawn_positions()
	spawn_positions.shuffle()  # Shuffle to randomize placement

	for i in range(min(num_obstacles, spawn_positions.size())):
		var spawn_pos = spawn_positions[i]
		var obstacle = obstacle_scene.instantiate() as Node2D
		obstacle.global_position = spawn_pos
		add_child(obstacle)

func generate_spawn_positions() -> Array:
	var positions = []
	var half_area = spawn_area / 2

	for x in range(-half_area.x, half_area.x, grid_size):
		for y in range(-half_area.y, half_area.y, grid_size):
			var pos = Vector2(x, y) + global_position

			# Ensure it does not spawn on the player
			if player and pos.distance_to(player.global_position) >= grid_size * 1.5:
				positions.append(pos)

	return positions
