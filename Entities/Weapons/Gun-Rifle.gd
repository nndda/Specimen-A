extends Node

@export_node_path( "AnimationPlayer" ) var animation_player_ : NodePath
@onready var animation_player : AnimationPlayer = get_node( animation_player_ )

@onready var wielder = $"../.."
@onready var weapon = $".."

@onready var line_of_sight = $"../LineOfSight"
@onready var line_of_fire = $"../LineOfSight/LineOfFire"
@onready var bullet_path = $"../BulletPath"
@onready var bullet_spark = $"../BulletSpark"

@onready var colliding_point = $"../CollidingPoint"

func fire() -> void:
    randomize()
    cam.shake_start( 5.0, 0.09, 32.0 )
    line_of_fire.rotation_degrees   = randf_range( -2.25, 2.25 )
    bullet_path.rotation_degrees    = line_of_fire.rotation_degrees

func _physics_process(_delta):
    if wielder.triggered:

            bullet_path.points[0]   = Vector2.ZERO
            bullet_spark.visible    = line_of_fire.is_colliding()
            bullet_path.visible     = animation_player.is_playing()# and bullet_spark.visible

            line_of_fire.enabled    = animation_player.is_playing()

            if line_of_fire.is_colliding():
                colliding_point.global_position = line_of_fire.get_collision_point()
                bullet_path.points[1] = colliding_point.position

                bullet_spark.global_position = colliding_point.global_position
                if line_of_fire.get_collider() != null:
                    if line_of_fire.get_collider().has_method( "damage_player" ):
                        line_of_fire.get_collider().damage_player( randf_range( 8, 12 ) )

            else:
                bullet_path.points[1] = Vector2(0,110)
                bullet_path.points[1] = $"../CollidingPointDefault".position


#func _on_animation_player_started(anim_name):
#   if anim_name == "Firing":
#       cam.shake_start( 5.0, 0.09, 32.0 )
