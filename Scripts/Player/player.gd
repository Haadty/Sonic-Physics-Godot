extends Node2D
class_name Player

const Handles = preload("player_handles.gd")
var handle

const Controls = preload("player_controls.gd")
var control

const Movements = preload("player_movement.gd")
var movement

@onready var skin = $Skin as PlayerSkin
@onready var state_machine = $StateMachine as PlayerStateMachine

func _ready():
	control = Controls.new();
	movement = Movements.new();
	handle = Handles.new(control, movement);
	handle.initialize_collider()
	handle.initialize_resources()
	handle.initialize_state_machine()
	handle.initialize_skin()

func _physics_process(delta):
	control.handle_input()
	control.handle_control_lock(delta)
	handle.handle_state_update(delta)
	handle.handle_motion(delta)
	handle.handle_limits()
	handle.handle_state_animation(delta)
	handle.handle_skin(delta)

func _draw():
	var ground_ray_size = handle.current_bounds.height_radius + handle.current_bounds.ground_extension if handle.__is_grounded else handle.current_bounds.height_radius
	var horizontal_origin = Vector2.ZERO - Vector2.UP * handle.current_bounds.push_height_offset if handle.__is_grounded and handle.absolute_ground_angle < 1 else Vector2.ZERO

	draw_line(horizontal_origin, horizontal_origin + Vector2.RIGHT * (handle.current_bounds.width_radius + handle.current_bounds.push_radius), Color.CRIMSON)
	draw_line(horizontal_origin, horizontal_origin - Vector2.RIGHT * (handle.current_bounds.width_radius + handle.current_bounds.push_radius), Color.PINK)
	draw_line(Vector2.RIGHT * handle.current_bounds.width_radius, Vector2.RIGHT * handle.current_bounds.width_radius - Vector2.UP * ground_ray_size, Color.CYAN)
	draw_line(-Vector2.RIGHT * handle.current_bounds.width_radius, -Vector2.RIGHT * handle.current_bounds.width_radius - Vector2.UP * ground_ray_size, Color.GREEN)
	draw_line(Vector2.RIGHT * handle.current_bounds.width_radius, Vector2.RIGHT * handle.current_bounds.width_radius + Vector2.UP * handle.current_bounds.height_radius, Color.YELLOW)
	draw_line(-Vector2.RIGHT * handle.current_bounds.width_radius, -Vector2.RIGHT * handle.current_bounds.width_radius + Vector2.UP * handle.current_bounds.height_radius, Color.BLUE)
