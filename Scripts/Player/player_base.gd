extends Node2D
class_name PlayerBase

signal ground_enter

@export var bounds: Array[Resource]
@export var stats: Array[Resource]

@export_flags_2d_physics var wall_layer: int = 1
@export_flags_2d_physics var ground_layer: int = 1
@export_flags_2d_physics var ceiling_layer: int = 1

@onready var initial_parent = get_parent()

var world: World2D
var current_bounds: PlayerCollision
var current_stats: PlayerStats

var collider: Area2D
var collider_shape: RectangleShape2D

var velocity: Vector2
var ground_normal: Vector2
var input_direction: Vector2

var ground_angle: float
var absolute_ground_angle: float
var input_dot_velocity: float
var control_lock_timer: float

var limit_left: float
var limit_right: float

var is_jumping: bool
var is_rolling: bool
var is_crouch: bool
var is_control_locked: bool
var is_locked_to_limits: bool

var __is_grounded: bool
var is_pushing: bool

var isnt_grounded_left: bool
var isnt_grounded_right: bool
var isnt_grounded_center: bool

var last_rotation: float