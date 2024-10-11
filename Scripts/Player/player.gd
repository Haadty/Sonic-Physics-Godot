extends PlayerHandles
class_name Player

func _ready():
	initialize_collider()
	initialize_resources()
	initialize_state_machine()
	initialize_skin()

func _physics_process(delta):
	control.handle_input()
	control.handle_control_lock(delta)
	handle_state_update(delta)
	handle_motion(delta)
	handle_limits()
	handle_state_animation(delta)
	handle_skin(delta)

func _draw():
	var ground_ray_size = current_bounds.height_radius + current_bounds.ground_extension if __is_grounded else current_bounds.height_radius
	var horizontal_origin = Vector2.ZERO - Vector2.UP * current_bounds.push_height_offset if __is_grounded and absolute_ground_angle < 1 else Vector2.ZERO

	draw_line(horizontal_origin, horizontal_origin + Vector2.RIGHT * (current_bounds.width_radius + current_bounds.push_radius), Color.CRIMSON)
	draw_line(horizontal_origin, horizontal_origin - Vector2.RIGHT * (current_bounds.width_radius + current_bounds.push_radius), Color.PINK)
	draw_line(Vector2.RIGHT * current_bounds.width_radius, Vector2.RIGHT * current_bounds.width_radius - Vector2.UP * ground_ray_size, Color.CYAN)
	draw_line(-Vector2.RIGHT * current_bounds.width_radius, -Vector2.RIGHT * current_bounds.width_radius - Vector2.UP * ground_ray_size, Color.GREEN)
	draw_line(Vector2.RIGHT * current_bounds.width_radius, Vector2.RIGHT * current_bounds.width_radius + Vector2.UP * current_bounds.height_radius, Color.YELLOW)
	draw_line(-Vector2.RIGHT * current_bounds.width_radius, -Vector2.RIGHT * current_bounds.width_radius + Vector2.UP * current_bounds.height_radius, Color.BLUE)
