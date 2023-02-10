extends Node2D

func _ready():
	$LineOfSight.add_exception($"..")
	$LineOfSight.add_exception($"../TriggerArea")

	$LineOfSight/LineOfFire.add_exception($"..")
	$LineOfSight/LineOfFire.add_exception($"../TriggerArea")

func _physics_process(_delta):
	$BulletPath.visible = get_parent().firing
	$BulletPath.points[0] = Vector2(0,0)
	$BulletSpark.visible = $LineOfSight/LineOfFire.is_colliding()

	if $LineOfSight/LineOfFire.is_colliding():
		$CollidingPoint.global_position = $LineOfSight/LineOfFire.get_collision_point()
		$BulletPath.points[1] = $CollidingPoint.position# - Vector2(14,5)

		$BulletSpark.global_position = $CollidingPoint.global_position
		if $LineOfSight/LineOfFire.get_collider().has_method("DamagePlayer"):
			$LineOfSight/LineOfFire.get_collider().DamagePlayer(15.0)
	else:
		$BulletPath.points[1] = Vector2(0,110)

func Fire() -> void:
#	$BulletSpark.emitting = true
	randomize()
	$LineOfSight/LineOfFire.rotation_degrees = rand_range(-2.25,2.25)
	$BulletPath.rotation_degrees = $LineOfSight/LineOfFire.rotation_degrees


