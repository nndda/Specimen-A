extends Node2D

var damage = 12.8

var on_line

var on_sight = false

var firing_line : Array
var bullet_path_ends : PoolVector2Array

func _ready():
	for lchd in $FiringLine.get_children():
		firing_line.append(lchd)
		lchd.add_exception($"..")
		lchd.add_exception($"../TriggerArea")
		lchd.add_exception($FiringSight)

	for pchd in $BulletPaths.get_children():
		bullet_path_ends.append(pchd.points[1])

	for fchd in $FiringLine.get_child_count():
		if $FiringLine.get_child(fchd) != firing_line[fchd]:
			$FiringLine.get_child(fchd).add_execption(firing_line[fchd])

func _physics_process(_delta):
	$BulletPaths.visible = get_parent().firing
#	$BulletPath.points[0] = Vector2(0,0)
#	$BulletSpark.visible = $LineOfSight/LineOfFire.is_colliding()


#	for cpts in $CollidingPoints.get_child_count():

#		$CollidingPoints.get_child(cpts).get_node("BulletSpark").modulate.a = $FiringLine.modulate.a
	$CollidingPoints.modulate.a = $BulletPaths.modulate.a


	if on_sight and get_parent().firing:
		for cpts in $CollidingPoints.get_child_count():

			$CollidingPoints.get_child(cpts).get_node("BulletSpark").modulate.a = $FiringLine.get_child(cpts).modulate.a

			if $FiringLine.get_child(cpts).is_colliding():

				$CollidingPoints.get_child(cpts).global_position = $FiringLine.get_child(cpts).get_collision_point()
				$BulletPaths.get_child(cpts).points[1] = $CollidingPoints.get_child(cpts).position
				$CollidingPoints.get_child(cpts).get_node("BulletSpark").visible = true

				if $FiringLine.get_child(cpts).get_collider().has_method("DamagePlayer"):

					$FiringLine.get_child(cpts).get_collider().DamagePlayer(damage)

			else:
				$CollidingPoints.get_child(cpts).get_node("BulletSpark").visible = false
#		$CollidingPoint.global_position = $LineOfSight/LineOfFire.get_collision_point()
#		$BulletPath.points[1] = $CollidingPoint.position# - Vector2(14,5)

#		$BulletSpark.global_position = $CollidingPoint.global_position

#		if $LineOfSight/LineOfFire.get_collider().has_method("DamagePlayer"):
#			$LineOfSight/LineOfFire.get_collider().DamagePlayer(damage)

	else:
		for cpts in $CollidingPoints.get_child_count():
			if !$FiringLine.get_child(cpts).is_colliding():
				$BulletPaths.get_child(cpts).points[1] = bullet_path_ends[cpts]
			$CollidingPoints.get_child(cpts).get_node("BulletSpark").visible = false

#		$BulletPath.points[1] = Vector2(0,110)
#		if get_node_or_null("CollidingPointDefault") != null:
#			$BulletPath.points[1] = $CollidingPointDefault.position

	on_line = on_sight

func Fire() -> void:
#	$BulletSpark.emitting = true
	randomize()
	
#	$LineOfSight/LineOfFire.rotation_degrees = rand_range(-2.25,2.25)
#	$BulletPath.rotation_degrees = $LineOfSight/LineOfFire.rotation_degrees




func _on_FiringSight_body_entered(body):
	if body.get_name() == "Head" or body.get_name() == "DamageCollision":
		on_sight = true
func _on_FiringSight_body_exited(body):
	if body.get_name() == "Head" or body.get_name() == "DamageCollision":
		on_sight = false
