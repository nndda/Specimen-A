extends Node

@onready var wielder = $"../.."
@onready var weapon = $".."

@onready var line_of_sight = $"../LineOfSight"
@onready var line_of_fire = $"../LineOfSight/LineOfFire"
@onready var bullet_path = $"../BulletPath"
@onready var bullet_spark

@onready var colliding_point = $"../CollidingPoint"

func Fire() -> void:
	randomize()
	line_of_fire.rotation_degrees	= randf_range(-2.25,2.25)
	bullet_path.rotation_degrees	= line_of_fire.rotation_degrees
	cam.ShakeStart

func _physics_process(_delta):
	if wielder.triggered:
			bullet_path.visible		= get_parent().firing
			bullet_path.points[0]	= Vector2(0,0)
			bullet_spark.visible	= line_of_fire.is_colliding()

			line_of_fire.enabled	= $AnimationPlayer.is_playing()

			if line_of_fire.is_colliding():
				colliding_point.global_position	= line_of_fire.get_collision_point()
				bullet_path.points[1]			= colliding_point.position

				bullet_spark.global_position	= colliding_point.global_position
				if line_of_fire.get_collider().has_method("DamagePlayer"):
					line_of_fire.get_collider().DamagePlayer(randf_range(8,12))

			else:
				bullet_path.points[1] = Vector2(0,110)
				bullet_path.points[1] = $CollidingPointDefault.position
