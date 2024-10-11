extends PlayerMovement

class_name PlayerHandles

func initialize_collider():
	var collision: CollisionShape2D = CollisionShape2D.new()
	collider_shape = RectangleShape2D.new()
	collider = Area2D.new()
	collision.shape = collider_shape
	collider.add_child(collision)
	add_child(collider)

func initialize_resources():
	world = get_world_2d()
	set_bounds(0)
	set_stats(0)

func initialize_state_machine():
	state_machine.initialize()

func initialize_skin():
	remove_child(skin)
	get_parent().call_deferred("add_child", skin)

func get_player_position():
	return global_position + current_bounds.offset

func set_bounds(index: int):
	if index >= 0 and index < bounds.size():
		var last_bounds: PlayerCollision = current_bounds
		current_bounds = bounds[index]
		collider_shape.extents.x = current_bounds.width_radius + current_bounds.push_radius
		collider_shape.extents.y = current_bounds.height_radius
		
		if last_bounds and last_bounds != current_bounds:
			position += last_bounds.offset

func set_stats(index: int):
	if index >= 0 and index < bounds.size():
		current_stats = stats[index]

func handle_collision():
	handle_wall_collision()
	handle_ground_collision()
	handle_ceiling_collision()

func is_grounded():
	return __is_grounded and velocity.y >= 0

func handle_state_update(delta: float):
	state_machine.update_state(delta)

func handle_motion(delta: float):
	var offset: float = velocity.length() * delta
	var max_motion_size: float = current_bounds.width_radius
	var motion_steps: float = ceil(offset / max_motion_size)
	var step_motion: Vector2 = velocity / motion_steps
	
	while motion_steps > 0:
		apply_motion(step_motion, delta)
		handle_collision()
		motion_steps -= 1

func handle_limits():
	if is_locked_to_limits:
		var offset: float = current_bounds.width_radius
		if global_position.x + offset > limit_right:
			global_position.x = limit_right - offset
			velocity.x = 0
		if global_position.x - offset < limit_left:
			global_position.x = limit_left + offset
			velocity.x = 0

func handle_state_animation(delta):
	state_machine.animate_state(delta)

func handle_skin(delta):
	skin.position = global_position
	
	var target_angle: float = 0
	var rotation_speed: float = skin.AIR_ROTATION_SPEED
	
	if __is_grounded:
		rotation_speed = skin.GROUND_ROTATION_SPEED
		if absolute_ground_angle > 23:
			target_angle = GoUtils.get_radian_from(ground_normal)
	
	if not is_rolling:
		target_angle = lerp_angle(last_rotation, target_angle, rotation_speed * delta)
		skin.rotation = target_angle
	
	last_rotation = target_angle

func apply_motion(desired_velocity: Vector2, delta: float):
	if __is_grounded:
		var global_velocity: Vector2 = GoUtils.ground_to_global_velocity(desired_velocity, ground_normal)
		position += global_velocity * delta
	else:
		position += desired_velocity * delta

func handle_input():
	var horizontal: float = Input.get_axis("player_left", "player_right")
	var vertical: float = Input.get_axis("player_down", "player_up")
	if __is_grounded:
		horizontal = 0.0 if is_control_locked else horizontal
	input_direction = Vector2(horizontal, vertical)
	input_dot_velocity = input_direction.dot(velocity)

func lock_controls(lock_duration: float):
	if not is_control_locked:
		input_direction.x = 0
		is_control_locked = true
		control_lock_timer = lock_duration

func unlock_controls():
	if is_control_locked:
		is_control_locked = false
		control_lock_timer = 0

func handle_control_lock(delta: float):
	if is_control_locked:
		control_lock_timer -= delta
		if abs(velocity.x) == 0 or control_lock_timer <= 0:
			unlock_controls()

func handle_fall():
	if __is_grounded and absolute_ground_angle > current_stats.slide_angle and abs(velocity.x) <= current_stats.min_speed_to_fall:
		lock_controls(current_stats.CONTROL_LOCK_DURATION)

		if absolute_ground_angle > current_stats.fall_angle:
			exit_ground()

func handle_slope(delta: float):
	if __is_grounded:
		var down_hill: bool = velocity.dot(ground_normal) > 0
		var rolling_factor: float = current_stats.slope_roll_down if down_hill else current_stats.slope_roll_up
		var amount: float = rolling_factor if is_rolling else current_stats.slope_factor
		velocity.x += amount * ground_normal.x * delta

func handle_gravity(delta: float):
	if not __is_grounded:
		velocity.y += current_stats.gravity * delta

func handle_acceleration(delta: float):
	if input_direction.x != 0:
		if sign(input_direction.x) == sign(velocity.x) or not __is_grounded:
			var amount: float = current_stats.acceleration if __is_grounded else current_stats.air_acceleration
			if abs(velocity.x) < current_stats.top_speed:
				velocity.x += input_direction.x * amount * delta
				velocity.x = clamp(velocity.x, -current_stats.top_speed, current_stats.top_speed)
		else:
			velocity.x += input_direction.x * current_stats.deceleration * delta

func handle_deceleration(delta: float):
	if input_direction.x != 0 and sign(input_direction.x) != sign(velocity.x):
		var amount: float = current_stats.roll_deceleration if is_rolling else current_stats.deceleration
		velocity.x = move_toward(velocity.x, 0, amount * delta)

func handle_friction(delta: float):
	if __is_grounded and (input_direction.x == 0 or is_rolling):
		var amount: float = current_stats.roll_friction if is_rolling else current_stats.friction
		velocity.x = move_toward(velocity.x, 0, amount * delta)

func handle_jump():
	if __is_grounded and Input.is_action_just_pressed("player_a"):
		is_jumping = true
		is_rolling = true
		velocity.y = -current_stats.max_jump_height

	if is_jumping and Input.is_action_just_released("player_a") and velocity.y < -current_stats.min_jump_height:
		velocity.y = -current_stats.min_jump_height

func lock_to_limits(left: float, right: float):
	limit_left = left
	limit_right = right
	is_locked_to_limits = true