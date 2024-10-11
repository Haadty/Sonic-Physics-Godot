extends PlayerBase

class_name PlayerControls

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