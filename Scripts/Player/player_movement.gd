extends PlayerBase

class_name PlayerMovement

func handle_wall_collision():
	var ray_size: float = current_bounds.width_radius + current_bounds.push_radius
	var origin: Vector2 = global_position + transform.y * current_bounds.push_height_offset if __is_grounded and absolute_ground_angle < 10 else global_position
	var right_ray: Dictionary = GoPhysics.cast_ray(world, origin, transform.x, ray_size, [self], wall_layer)
	var left_ray: Dictionary = GoPhysics.cast_ray(world, origin, -transform.x, ray_size, [self], wall_layer)
	
	if right_ray or left_ray:
		is_pushing = true
		if right_ray:
			handle_contact(right_ray.collider, "player_right_wall_collision")
			
			if not right_ray.collider is SolidObject or right_ray.collider.is_enabled():
				velocity.x = min(velocity.x, 0)
				position -= transform.x * (right_ray.penetration + GoPhysics.EPSILON)
		
		if left_ray:
			handle_contact(left_ray.collider, "player_left_wall_collision")
			
			if not left_ray.collider is SolidObject or left_ray.collider.is_enabled():
				velocity.x = max(velocity.x, 0)
				position += transform.x * (left_ray.penetration + GoPhysics.EPSILON)
	else:
		is_pushing = false

func handle_ceiling_collision():
	var ray_size: float = current_bounds.height_radius
	var ray_offset: Vector2 = transform.x * current_bounds.width_radius
	var hits: Dictionary = GoPhysics.cast_parallel_rays(world, global_position, ray_offset, -transform.y, ray_size, [self], ceiling_layer)
	
	if hits:
		handle_contact(hits.closest_hit.collider, "player_ceiling_collision")
		
		if not __is_grounded and (not hits.closest_hit.collider is SolidObject or hits.closest_hit.collider.is_enabled()):
			var ceiling_normal: Vector2 = hits.closest_hit.normal
			var ceiling_angle: float = GoUtils.get_angle_from(ceiling_normal)
			
			if velocity.y < 0:
				if abs(ceiling_angle) < 135:
					set_ground_data(ceiling_normal)
					rotate_to(ceiling_angle)
					enter_ground(hits.closest_hit)
				else:
					velocity.y = 0
		
			position += transform.y * hits.closest_hit.penetration

func handle_ground_collision():
	var ray_offset: Vector2 = transform.x * current_bounds.width_radius
	var ray_size: float = current_bounds.height_radius + current_bounds.ground_extension if __is_grounded else current_bounds.height_radius
	var hits: Dictionary = GoPhysics.cast_parallel_rays(world, global_position, ray_offset, transform.y, ray_size, [self], ground_layer)
	
	if hits and velocity.y >= 0:
		handle_contact(hits.closest_hit.collider, "player_ground_collision")
		
		if not hits.closest_hit.collider is SolidObject or hits.closest_hit.collider.is_enabled():
			isnt_grounded_center = GoPhysics.cast_ray(world, global_position, transform.y, ray_size, [self], ground_layer).is_empty()
			
			if not __is_grounded and velocity.y >= 0:
				set_ground_data(hits.closest_hit.normal)
				rotate_to(ground_angle)
				position -= transform.y * hits.closest_hit.penetration
				enter_ground(hits.closest_hit)
			elif hits.left_hit or hits.right_hit:
				isnt_grounded_left = hits.left_hit.is_empty()
				isnt_grounded_right = hits.right_hit.is_empty()
				
				var safe_distance: float = hits.closest_hit.penetration - current_bounds.ground_extension
				set_ground_data(hits.closest_hit.normal)
				rotate_to(ground_angle)
				position -= transform.y * safe_distance
	else:
		exit_ground()

func set_ground_data(normal: Vector2 = Vector2.UP):
	ground_normal = normal
	ground_angle = GoUtils.get_angle_from(normal)
	absolute_ground_angle = abs(ground_angle)

func exit_ground():
	if __is_grounded:
		__is_grounded = false
		reparent_player(initial_parent)
		velocity = GoUtils.ground_to_global_velocity(velocity, ground_normal)
		rotate_to(0)

func handle_contact(static_body: Object, signal_name: String):
	if static_body is SolidObject:
		static_body.emit_signal(signal_name, self)

func reparent_player(new_parent: Node):
	var current_parent = get_parent()
	if new_parent != current_parent:
		var old_transform = global_transform
		current_parent.remove_child(self)
		new_parent.add_child(self)
		global_transform = old_transform

func enter_ground(ground_data: Dictionary):
	if not __is_grounded:
		is_jumping = false
		is_rolling = false
		__is_grounded = true
		velocity = GoUtils.global_to_ground_velocity(velocity, ground_normal)
		emit_signal("ground_enter")

func rotate_to(angle: float):
	var closest_angle: int = snapped(angle, 90)
	rotation_degrees = closest_angle
