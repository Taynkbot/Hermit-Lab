extends TextureRect

@export var player: Node2D
@export var food_spawner: Node

func _process(delta: float) -> void:
	if not player or not food_spawner:
		return

	var closest_food = get_closest_food()
	var viewport_rect = get_viewport_rect()  # Screen rectangle in UI coordinates.
	var camera = get_viewport().get_camera_2d()
	var screen_center = viewport_rect.size / 2

	if closest_food:
		# Convert food's world position to screen coordinates.
		var food_screen_pos = camera.project_position(closest_food.global_position)
		
		# If food is on-screen, hide the arrow.
		if viewport_rect.has_point(food_screen_pos):
			hide()
		else:
			show()
			# Calculate direction from the screen center to the food's screen position.
			var direction = (food_screen_pos - screen_center).normalized()
			# Calculate the intersection point of a ray (from screen center in that direction) with the viewport's edge.
			var arrow_screen_pos = get_ray_rect_intersection(screen_center, direction, viewport_rect)
			# Adjust the arrow so its center aligns with that point.
			rect_position = arrow_screen_pos - (rect_size / 2)
			# Rotate the arrow to point in that direction.
			rotation = direction.angle()
	else:
		hide()

# Returns the closest food node from food_spawner.
func get_closest_food() -> Node:
	var closest_food = null
	var min_dist = INF
	for food in food_spawner.get_children():
		if not food or not food.is_inside_tree():
			continue
		var dist = player.global_position.distance_to(food.global_position)
		if dist < min_dist:
			min_dist = dist
			closest_food = food
	return closest_food

# Returns the intersection point of a ray (origin, direction) with the edge of a rectangle.
func get_ray_rect_intersection(ray_origin: Vector2, ray_direction: Vector2, rect: Rect2) -> Vector2:
	var intersections: Array = []
	
	# Left edge
	if ray_direction.x != 0:
		var t = (rect.position.x - ray_origin.x) / ray_direction.x
		if t >= 0:
			var y = ray_origin.y + ray_direction.y * t
			var point = Vector2(rect.position.x, y)
			if point.y >= rect.position.y and point.y <= rect.position.y + rect.size.y:
				intersections.append(point)
	# Right edge
	if ray_direction.x != 0:
		var t = ((rect.position.x + rect.size.x) - ray_origin.x) / ray_direction.x
		if t >= 0:
			var y = ray_origin.y + ray_direction.y * t
			var point = Vector2(rect.position.x + rect.size.x, y)
			if point.y >= rect.position.y and point.y <= rect.position.y + rect.size.y:
				intersections.append(point)
	# Top edge
	if ray_direction.y != 0:
		var t = (rect.position.y - ray_origin.y) / ray_direction.y
		if t >= 0:
			var x = ray_origin.x + ray_direction.x * t
			var point = Vector2(x, rect.position.y)
			if point.x >= rect.position.x and point.x <= rect.position.x + rect.size.x:
				intersections.append(point)
	# Bottom edge
	if ray_direction.y != 0:
		var t = ((rect.position.y + rect.size.y) - ray_origin.y) / ray_direction.y
		if t >= 0:
			var x = ray_origin.x + ray_direction.x * t
			var point = Vector2(x, rect.position.y + rect.size.y)
			if point.x >= rect.position.x and point.x <= rect.position.x + rect.size.x:
				intersections.append(point)
				
	if intersections.size() > 0:
		# Return the intersection closest to the origin.
		intersections.sort_custom(func(a, b): return a.distance_to(ray_origin) < b.distance_to(ray_origin) ? -1 : 1)
		return intersections[0]
	return ray_origin
