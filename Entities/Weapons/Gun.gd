extends Node2D

## Base script for ALL gun/projectile addon
# NOTE : Require `FireFunction` Node with variable `animation_player`, containing animation named "Firing"

@export var entity_holder : Node

@export var damage_min : float = 0.85
@export var damage_max : float = 1.9
var firing := false

@export var fire_function : Node
var fire_function_anim : AnimationPlayer

@export var line_of_sight : RayCast2D
@export var obstacle_sight : RayCast2D
@export var friendly_sight : RayCast2D

var fire_paused := false
var on_line := false
var player_on_sight := false
var has_obstacle := false

const player_bodies : Array[StringName] = [&"Head", &"DamageCollision"]

#func add_raycast_exceptions(body : CollisionObject2D) -> void:
    #line_of_sight.add_exception(body)
    #obstacle_sight.add_exception(body)
    #friendly_sight.add_exception(body)

func init_raycast_exceptions(raycast : RayCast2D, ignore_all : bool = true) -> void:
    raycast.add_exception(Global.player_destroy_through)
    raycast.add_exception(Global.player_general_area)

    if ignore_all:
        raycast.add_exception(Global.player_physics_head)
        raycast.add_exception(Global.player_physics_body)

func _on_line_of_fire_tree_entered() -> void:
    $LineOfSight/LineOfFire.enabled = false

func _ready() -> void:
    fire_function_anim = fire_function.animation_player
    init_raycast_exceptions(line_of_sight, false)
    init_raycast_exceptions(obstacle_sight)
    init_raycast_exceptions(friendly_sight)

    fire_function_anim.animation_started.connect(
        entity_holder._on_weapon_animation_started
    )
    fire_function_anim.animation_finished.connect(
        entity_holder._on_weapon_animation_finished
    )

func _process(_delta : float) -> void:
    firing = fire_function_anim.current_animation == &"Firing"
    entity_holder.firing = firing

func _physics_process(_delta : float) -> void:
    if entity_holder.triggered:
        player_on_sight = line_of_sight.is_colliding()

        # there has to be a better way
        if !obstacle_sight.is_colliding():
            has_obstacle = false
            if !firing and fire_paused:
                fire_paused = false
                entity_holder.fire_ready = true
                entity_holder.cooldown_timer.start()
        else:
            has_obstacle =\
                line_of_sight.global_position.distance_to(
                    line_of_sight.get_collision_point()
                ) >\
                line_of_sight.global_position.distance_to(
                    obstacle_sight.get_collision_point()
                )
            if has_obstacle:
                if firing and !fire_paused:
                    fire_paused = true
                    fire_function.fire_stop()

        on_line = player_on_sight and !has_obstacle

func fire() -> void:
    fire_function_anim.play(&"Firing")
