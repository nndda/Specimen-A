extends Node2D

var damage = 8.25

onready var on_line = false

func _ready():
	$LineOfSight.add_exception($"..")
	$LineOfSight.add_exception($"../TriggerArea")

	$LineOfSight/LineOfFire.add_exception($"..")
	$LineOfSight/LineOfFire.add_exception($"../TriggerArea")

func _physics_process(_delta):
	$BulletPath.visible = get_parent().firing
	$BulletPath.points[0] = Vector2(0,0)
	$BulletSpark.visible = $LineOfSight/LineOfFire.is_colliding()

	$LineOfSight/LineOfFire.enabled = $AnimationPlayer.is_playing()

	if $LineOfSight/LineOfFire.is_colliding():
		$CollidingPoint.global_position = $LineOfSight/LineOfFire.get_collision_point()
		$BulletPath.points[1] = $CollidingPoint.position# - Vector2(14,5)

		$BulletSpark.global_position = $CollidingPoint.global_position
		if $LineOfSight/LineOfFire.get_collider().has_method("DamagePlayer"):
			$LineOfSight/LineOfFire.get_collider().DamagePlayer(damage)

#			if $LineOfSight/LineOfFire.get_collider().get_name() == "DamageCollision":
#				glbl.PopUpPoints(
#					( damage * 0.08 )
#					,$LineOfSight/LineOfFire.get_collision_point())
#			else:
#				glbl.PopUpPoints(
#					( damage * 1.25 )
#					,$LineOfSight/LineOfFire.get_collision_point())

	else:
		$BulletPath.points[1] = Vector2(0,110)
		if get_node_or_null("CollidingPointDefault") != null:
			$BulletPath.points[1] = $CollidingPointDefault.position

	on_line = $LineOfSight.is_colliding()

func Fire() -> void:
#	$BulletSpark.emitting = true
	randomize()
	$LineOfSight/LineOfFire.rotation_degrees = rand_range(-2.25,2.25)
	$BulletPath.rotation_degrees = $LineOfSight/LineOfFire.rotation_degrees


