extends Node2D

## Base script for ALL gun/projectile addon
# NOTE : Require `FireFunction` Node with variable `animation_player`, containing animation named "Firing"

@export_category("Stats")
@export var damage_min : float = 0.85
@export var damage_max : float = 1.9

@export_category("Timing")
@export_range(0.8, 5.0, 0.1) var cooldown_min : float = 0.8
@export_range(0.8, 5.0, 0.1) var cooldown_max : float = 0.8
var cooldown_timer := Timer.new()

@export_category("Components")
@export var fire_function : Node
var fire_function_anim : AnimationPlayer

@export var line_of_sight : RayCast2D
@export var obstacle_sight : RayCast2D
@export var friendly_sight : RayCast2D

var firing := false
var fire_ready := false
var fire_clear := false
var fire_paused := false

var on_line := false
var player_on_sight := false
var has_obstacle := false

func add_raycast_exceptions(raycast : RayCast2D, ignore_all : bool = true) -> void:
    raycast.add_exception(Global.player_destroy_through)
    raycast.add_exception(Global.player_general_area)

    if ignore_all:
        raycast.add_exception(Global.player_physics_head)
        raycast.add_exception(Global.player_physics_body)

func init_raycast_exceptions() -> void:
    add_raycast_exceptions(line_of_sight, false)
    add_raycast_exceptions(obstacle_sight)
    add_raycast_exceptions(friendly_sight)

func _on_line_of_fire_tree_entered() -> void:
    $LineOfSight/LineOfFire.enabled = false

func _on_cooldown_timeout() -> void:
    fire_ready = true

func _enter_tree() -> void:
    cooldown_timer.wait_time = randf_range(cooldown_min, cooldown_max)
    cooldown_timer.timeout.connect(_on_cooldown_timeout)

    call_deferred(&"add_child", cooldown_timer)

func _ready() -> void:
    fire_function_anim = fire_function.animation_player
    fire_function.damage_min = damage_min
    fire_function.damage_max = damage_max

    fire_function_anim.animation_started.connect(
        _on_weapon_animation_started
    )
    fire_function_anim.animation_finished.connect(
        _on_weapon_animation_finished
    )

func _process(_delta : float) -> void:
    firing = fire_function_anim.current_animation == &"Firing"
    fire_clear = fire_ready and on_line

    if fire_clear:
        if cooldown_timer.time_left <= 0.0:
            cooldown_timer.start()
        fire()
        fire_ready = false

func _physics_process(_delta : float) -> void:
    player_on_sight = line_of_sight.is_colliding()

    # there has to be a better way
    if !obstacle_sight.is_colliding():
        has_obstacle = false
        if !firing and fire_paused:
            fire_paused = false
            cooldown_timer.start(randf_range(cooldown_min, cooldown_max))
    else:
        has_obstacle =\
            line_of_sight.global_position.distance_squared_to(
                line_of_sight.get_collision_point()
            ) >\
            line_of_sight.global_position.distance_squared_to(
                obstacle_sight.get_collision_point()
            )

        if has_obstacle:
            if firing and !fire_paused:
                fire_paused = true
                fire_function.fire_stop()

    on_line = player_on_sight and !has_obstacle

func initiate() -> void:
    cooldown_timer.start(randf_range(cooldown_min, cooldown_max))

func fire() -> void:
    fire_function_anim.play(&"Firing")

func _on_weapon_animation_started(anim : StringName) -> void:
    if anim == &"Firing":
        cooldown_timer.stop()
func _on_weapon_animation_finished(anim : StringName) -> void:
    if anim == &"Firing":
        initiate()
