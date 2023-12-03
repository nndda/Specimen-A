extends Node

@export_node_path("AnimationPlayer") var animation_player_ : NodePath
@onready var animation_player : AnimationPlayer = get_node(animation_player_)

@onready var wielder := $"../.."
@onready var weapon := $".."

@onready var line_of_sight := $"../LineOfSight"
@onready var line_of_fire := $"../LineOfSight/LineOfFire"
@onready var line_of_fire_const := $"../LineOfSight/LineOfFire/Const"
@onready var bullet_path := $"../BulletPath"
@onready var bullet_spark := $"../BulletSpark"

@onready var colliding_point := $"../CollidingPoint"

var hit := false

func _ready() -> void:
    animation_player.animation_started.connect(firing_started)
    animation_player.animation_finished.connect(firing_ended)

func fire() -> void:
    randomize()
    Camera.shake_start(5.0, 0.09, 32.0)
    line_of_fire.rotation_degrees = randf_range(-2.25, 2.25)
    bullet_path.rotation_degrees = line_of_fire.rotation_degrees

func firing_started(anim : StringName) -> void:
    if anim == &"Firing":
        bullet_path.visible = true
        line_of_fire_const.enabled = true
func firing_ended(anim : StringName) -> void:
    if anim == &"Firing":
        bullet_path.visible = false
        line_of_fire_const.enabled = false

func _physics_process(_delta):
    if wielder.triggered:
            hit = line_of_fire.is_colliding()
            bullet_path.points[0] = Vector2.ZERO
            bullet_spark.visible = hit
            #bullet_path.visible = animation_player.is_playing()# and bullet_spark.visible

            #line_of_fire_const.enabled = animation_player.is_playing()

            if hit:
                colliding_point.global_position = line_of_fire_const.get_collision_point()
                bullet_path.points[1] = colliding_point.position

                bullet_spark.global_position = colliding_point.global_position
                if line_of_fire.get_collider() != null:
                    if line_of_fire.get_collider().has_method(&"damage_player"):
                        line_of_fire.get_collider().damage_player(randf_range(
                                weapon.damage_min, weapon.damage_max))

            else:
                bullet_path.points[1] = Vector2(0, 110)
                bullet_path.points[1] = $"../CollidingPointDefault".position
