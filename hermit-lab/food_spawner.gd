extends Node2D

@export var food_scene: PackedScene      # Your seagull egg scene
@export var treasure_scene: PackedScene  # Your treasure scene (Treasure.tscn)
@export var spawn_area: Vector2 = Vector2(1000, 1000)
@export var max_food: int = 10
@export var spawn_time: float = 5.0
@export var clump_size: int = 3
@export var treasure_spawn_chance: float = 0.2  # 20% chance per nest
@export var nest_textures: Array[Texture]  # Assign different nest textures in the Inspector

var food_items: Array = []

func _ready() -> void:
	$Timer.wait_time = spawn_time
	$Timer.start()
	$Timer.timeout.connect(Callable(self, "_spawn_food"))
	_spawn_food()

func _spawn_food() -> void:
	if food_items.size() >= max_food:
		return

	# Generate a random base position for a clump.
	var base_position = Vector2(
		randf_range(-spawn_area.x / 2, spawn_area.x / 2),
		randf_range(-spawn_area.y / 2, spawn_area.y / 2)
	) + global_position

	# Spawn a nest sprite with a random texture at the base position.
	var nest_sprite = Sprite2D.new()
	if nest_textures.size() > 0:
		nest_sprite.texture = nest_textures[randi() % nest_textures.size()]  # Pick a random nest texture
	nest_sprite.position = base_position
	add_child(nest_sprite)

	# Spawn food items on top of the nest.
	for i in range(clump_size):
		if food_items.size() >= max_food:
			break
		var offset = Vector2(randf_range(-30, 30), randf_range(-30, 30))
		var food_instance = food_scene.instantiate()
		food_instance.position = base_position + offset

		# Assign a random texture to the food's Sprite2D node.
		if food_instance.has_node("Sprite2D"):
			var egg_sprite = food_instance.get_node("Sprite2D")
			if nest_textures.size() > 0:
				egg_sprite.texture = nest_textures[randi() % nest_textures.size()]  # Pick a random texture

		add_child(food_instance)
		food_items.append(food_instance)

		# Remove from the list when the food is picked up.
		food_instance.tree_exiting.connect(func():
			food_items.erase(food_instance)
		)

	# Rare chance to spawn a treasure at the same base position.
	if randf() < treasure_spawn_chance:
		var treasure_instance = treasure_scene.instantiate()
		treasure_instance.position = base_position
		add_child(treasure_instance)
