extends StaticBody2D

var health = 300.0
var destroyed = false
var health_gunner = 60.0
var dead = false

var on_sight = false

var triggered = true

func _physics_process(_delta):
	if triggered and !(destroyed or dead):
		$Seeker.look_at(glbl.head_pos)
		$Seeker.rotation_degrees = wrapf($Seeker.rotation_degrees,-180,180)
		
#		if $Gun.rota
#		$Gun.rotation_degrees += (15.0 * sign($Seeker.rotation_degrees)) * delta
#		$Gun.rotation_degrees = wrapf($Gun.rotation_degrees,-180,180)

		$Gun.rotation = lerp_angle(
			$Gun.rotation, (
				glbl.head_pos - $Gun.global_position
				).normalized().angle(), 0.2)

		$Gun/Gunner/Head.look_at(glbl.head_pos)
		$Gun/Gunner/Head.rotation_degrees = wrapf($Gun/Gunner/Head.rotation_degrees,-60,60)




func Shot(start:bool=true) -> void:
	$Gun/Shot/GunDamage.monitorable = start
	$Gun/Shot/GunDamage.monitoring = start
