extends Area2D

func is_colliding() -> bool:
	return get_overlapping_areas().size() > 0

func get_push_vector() -> Vector2:
	var push_vector = Vector2.ZERO
	if is_colliding():
		var areas = get_overlapping_areas()
		var area: Area2D = areas[0]
		var random_direction = -1 if randf() < 0.5 else 1
		var random_rotation = random_direction * PI/4
		push_vector = area.global_position.direction_to(global_position).rotated(random_rotation)
	return push_vector
	
