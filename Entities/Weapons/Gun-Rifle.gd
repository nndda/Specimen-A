extends Node

@export var spread_degrees : float = 1.98
@export var animation_player : AnimationPlayer

@export_category("Sights")
@export var line_of_sight : RayCast2D
@export var line_of_fire : RayCast2D
@export var line_of_fire_const : RayCast2D
var line_of_fire_collider : Object

@export_category("Visuals")
@export var bullet_path : Line2D
@export var bullet_path_default_pos : Marker2D
@export var bullet_spark : GPUParticles2D

@export var colliding_point : Marker2D

var firing := false

var damage_min : float
var damage_max : float

var hit := false
var damage_output : float

func _ready() -> void:
    animation_player.animation_started.connect(firing_started)
    animation_player.animation_finished.connect(firing_ended)

func fire() -> void:
    Camera.shake_start(5.0, 0.09, 32.0)
    line_of_fire.rotation_degrees = randf_range(-spread_degrees, spread_degrees)
    bullet_path.rotation_degrees = line_of_fire.rotation_degrees

func fire_stop() -> void:
    animation_player.stop()
    animation_player.play(&"RESET")

    line_of_fire.enabled = false
    line_of_fire_const.enabled = false

    bullet_spark.emitting = false
    bullet_spark.visible = false
    bullet_path.visible = false
    bullet_path.points[1] = bullet_path_default_pos.position

func firing_started(anim : StringName) -> void:
    if anim == &"Firing":
        line_of_fire.enabled = true
        line_of_fire_const.enabled = true

        bullet_spark.visible = true
        bullet_path.visible = true

func firing_ended(anim : StringName) -> void:
    if anim == &"Firing":
        bullet_path.visible = false
        line_of_fire_const.enabled = false
        bullet_path.points[1] = bullet_path_default_pos.position

func _process(_delta: float) -> void:
    firing = animation_player.current_animation == &"Firing"

func _physics_process(_delta : float) -> void:
    if firing:
        hit = line_of_fire.is_colliding()
        bullet_path.points[0] = Vector2.ZERO
        bullet_spark.emitting = hit

        if hit:
            colliding_point.global_position = line_of_fire_const.get_collision_point()
            bullet_path.points[1] = colliding_point.position
            line_of_fire_collider = line_of_fire.get_collider()

            bullet_spark.global_position = colliding_point.global_position
            if line_of_fire_collider != null:
                damage_output = randf_range(damage_min, damage_max)

                if line_of_fire_collider.has_method(&"damage_player"):
                    line_of_fire_collider.damage_player(damage_output)
                elif line_of_fire_collider.has_method(&"damage_prop"):
                    line_of_fire_collider.damage_prop(damage_output)
