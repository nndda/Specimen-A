extends KinematicBody2D

var easer					= 0.0
var speed					= 360.0

var face_obstacle			= false

var allow_attack			= true

var attacking				= false
var attack_strength			: float
var attack_out				: int
var attack_dir				: Vector2
var attack_cooldown			= 3.25

var attack_speed			= 22.0

var attack_distance_max		: float = 32.0 * 12.0
var attack_pos : PoolVector2Array = [Vector2(),Vector2()]

func OpenMouth(n:float) -> void:
	$Mouth/Jaw_0.rotation_degrees = n*-30
	$Mouth/Jaw_0.rotation_degrees = clamp($Mouth/Jaw_0.rotation_degrees,-30.0,0.0)
	$Mouth/Jaw_1.rotation_degrees = n*30
	$Mouth/Jaw_1.rotation_degrees = clamp($Mouth/Jaw_1.rotation_degrees+n*30,0.0,30.0)


func AttackHandler() -> void:

	$"../UI/AttackIndicator".visible = Input.is_action_pressed("Attack") and allow_attack

	if allow_attack:

		attack_out	+= 2 if Input.is_action_pressed("Attack") else -2
		attack_out	= int(clamp(attack_out,0,100))
		OpenMouth(float(attack_out)/100)

		if Input.is_action_pressed("Attack"):
			$"../UI/Arrow".look_at(get_viewport().get_mouse_position())
			$"../UI/Arrow".position		= glbl.head_canvas_pos
			$"../UI/Arrow".modulate.a	= float(attack_out)/100
			$"../UI/Arrow".offset.x		= (float(attack_out)/100 * 60) + 68

			$FaceObstacle.look_at(get_global_mouse_position())
			self.look_at(get_global_mouse_position())

		if Input.is_action_just_released("Attack"):
			$AreaShake/CollisionShape2D.set_deferred("disabled",false)
			attacking			= true
			attack_dir			= glbl.head_pos.direction_to(get_global_mouse_position())
			attack_strength		= float(attack_out)
			$AttackCooldown.start(
				3.25 * ( float( attack_out ) / 100 ) )
			attack_pos[0] = glbl.head_pos

			allow_attack = false

	$"../UI/AttackIndicator".value		= attack_out
	$"../UI/AttackCooldown".max_value	= 100
	$"../UI/AttackCooldown".value		= (($AttackCooldown.time_left / $AttackCooldown.wait_time) * 100)


func _ready():
	$AreaShake/CollisionShape2D.set_deferred("disabled",true)
	print($AreaShake/CollisionShape2D.disabled)
	
	$DestroyThrough.add_exception($FaceObstacle)
	$FaceObstacle.add_exception($DestroyThrough)


func _process(delta):

	glbl.health += ( 2.5 * delta ) * 1 if !invincible else 0.5

	glbl.head_pos				= global_position
	glbl.head_canvas_pos		= get_global_transform_with_canvas().origin


	$"../UI/Arrow".look_at(get_viewport().get_mouse_position())
	$"../UI/Arrow".position		= glbl.head_canvas_pos
	$"../UI/Arrow".modulate.a	= glbl.moving_f
	$"../UI/Arrow".offset.x		= (glbl.moving_f * 60) + 68


	$"../UI/AttackIndicator".rect_position = glbl.head_canvas_pos - $"../UI/AttackIndicator".rect_size / 2
	$"../UI/AttackCooldown".rect_position = glbl.head_canvas_pos - $"../UI/AttackCooldown".rect_size / 2


	$FaceObstacle.look_at(get_global_mouse_position())
	glbl.allow_move = !$FaceObstacle.is_colliding()
	$"../UI/FaceObstacleIcon".visible = $FaceObstacle.is_colliding()
	if $FaceObstacle.is_colliding():
		if Input.is_action_just_pressed("Move"):
			$"FaceObstacle-Pos".global_position = $FaceObstacle.get_collision_point()
			$"../UI/FaceObstacleIcon".position = $"FaceObstacle-Pos".get_global_transform_with_canvas().origin
			$"../UI/FaceObstacleIcon/AnimationPlayer".play("Blink")

	AttackHandler()


var velo
var attack_velo	: Vector2
func _physics_process(delta):

	easer += ( 0.1 * 1.0 if glbl.moving else -1.0 )
	easer = clamp(easer,0.0,1.0)

	attack_distance_max = (12.0 * 32.0) * (attack_strength / 60)

	if !attacking:
		velo = move_and_slide(
			( float(glbl.moving_f) *
			( ( speed ) * global_position.direction_to(get_global_mouse_position()) ) )
		)
	else:
		velo = attack_speed * attack_dir
		var collision = move_and_collide(velo)

		attack_pos[1] = glbl.head_pos

		if $DestroyThrough.is_colliding():
			if $DestroyThrough.get_collider().has_method("Damage"):

				if $DestroyThrough.get_collider().health - attack_strength <= 0:
					$DestroyThrough.get_collider().Damage( $DestroyThrough.get_collider().health )
					$"Mouth/ImpactParticles-Blood".emitting = true
#					ResetAtkDmg()
					ShakeCam()
					$AreaShake/CollisionShape2D.set_deferred("disabled",true)

				else:
					if collision != null:
						if collision.collider.has_method("Damage"):
							$"Mouth/ImpactParticles-Blood".emitting = true
							collision.collider.Damage(attack_strength)
							ResetAtkDmg()

						ShakeCam()
						$AreaShake/CollisionShape2D.set_deferred("disabled",true)

		if collision != null:
			ShakeCam()
			$AreaShake/CollisionShape2D.set_deferred("disabled",true)
			velo = velo.bounce(collision.normal)
			ResetAtkDmg()
			attacking = false

		if attack_pos[0].distance_to(attack_pos[1]) >= attack_distance_max:
			ResetAtkDmg()
			velo.x -= 2.0 * delta
			velo.y -= 2.0 * delta
			$AreaShake/CollisionShape2D.set_deferred("disabled",true)
			attacking = false

		velo.x = clamp(velo.x,0.0,attack_speed * attack_dir.x)
		velo.y = clamp(velo.y,0.0,attack_speed * attack_dir.y)

	if glbl.moving_f > 0 and !attacking:
		self.look_at(get_global_mouse_position())

	$"../UI/AttackCooldown".visible = ($AttackCooldown.time_left > 0)

func ShakeCam() -> void:
	glbl.camera.ShakeStart(
		15 + ( 25 * ( attack_strength / 100 ) ),
		0.95,
		16 + 8 * ( attack_strength / 100 ) )

func ResetAtkDmg() -> void:
#	if reset:
	OpenMouth(0)
	attack_strength = 0
	attack_out = 0

func _on_AttackCooldown_timeout():
	allow_attack = true



var invincible = false
func DamagePlayer(power:float) -> void:
	if !invincible:
		print("DamagePlayer: " + str(power*1.85))
		glbl.health -= power*1.85
		$"../Body/AnimationPlayer/Hit".play("Hit")
